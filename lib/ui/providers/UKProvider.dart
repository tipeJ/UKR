import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/dialogs/dialogs.dart';
import 'package:UKR/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class UKProvider extends ChangeNotifier {
  Player? _player;
  Player get player => _player!;

  static const _playerID = 1;
  static const defParams = {"jsonrpc": "2.0", "id": 27928};
  Timer? _volAdjustTimer;
  Timer? _timeUpdateTimer;
  Timer? _seekTimer;
  static const _volumeSetTimeout = const Duration(milliseconds: 300);
  static const _seekTimeout = const Duration(milliseconds: 800);

  WebSocket? _ws;
  WebSocket get _w => _ws!;
  String? get socketCloseReason => _ws?.closeReason;
  String? error;

  static const _resultTimeout = const Duration(milliseconds: 5000);
  StreamSubscription<Map<String, dynamic>>? _propertiesStream;
  StreamController<Map<String, dynamic>> _resultSink =
      StreamController.broadcast();

  /// Returns an encoded version of the given command. Encoded in an isolate.
  static Future<String> _encodeCommand(
          String method, Map<String, dynamic> params) =>
      compute(jsonEncode, {"method": method, "params": params, ...defParams});

  Future<Map<String, dynamic>> _getResult(int id) => _resultSink.stream
      .firstWhere((r) => r['id'] == id)
      .timeout(_resultTimeout, onTimeout: () => const {});
  UKProvider(Player p) {
    initialize(p);
  }

  @override
  void dispose() {
    _ws?.close();
    _resultSink.close();
    _volAdjustTimer?.cancel();
    _timeUpdateTimer?.cancel();
    _seekTimer?.cancel();
    super.dispose();
  }

  // * Initialize Function
  /// Call this function every time the player object should change.
  void initialize(Player player) async {
    this._player = player;
    this._ws?.close();
    this._ws = await ApiProvider.getWS(player)
      ..handleError((e) => print("YEP: $e"))
      ..asyncMap<Map<String, dynamic>>(
              (data) => compute(_convertJsonData, data.toString()))
          .listen((data) => _handleJsonResponse(data));

    // Refresh the initial values.
    await _refreshPlayerProperties();
    await _refreshApplicationProperties();
    await _refreshPlayerItem();
    await _refreshPlayList();
    await _fetchSystemProperties();

    // Start the properties ping stream.
    _propertiesStream?.pause();
    _propertiesStream =
        ApiProvider.playerPropertiesStream(player).handleError((e) async {
      if (e.runtimeType == SocketException) {
        await _w.close(1001, "Lost connection to ${player.name}");
        error = "Lost connection to ${player.name}";
        notifyListeners();
        _propertiesStream!.pause();
      }
    }).listen((data) {
      if (data.isNotEmpty) {
        print("Update Player Properties");
        _updatePlayerProps(data);
      }
    });
    notifyListeners();
  }

  Future<void> reconnect() async {
    final pingResult = await ApiProvider.testPlayerConnection(player);
    if (pingResult) {
      error = null;
      notifyListeners();
      initialize(player);
    }
  }

  DialogService _dialogService = GetIt.instance<DialogService>();
  void _handleJsonResponse(Map<String, dynamic> j) async {
    final result = j['result'];
    if (result != null && !(result is String)) {
      // Send the result to the result Sink, to be picked up by the sending function:
      _resultSink.add(result);
      return;
    }
    if (j['params'] == null) return;
    final p = j['params'];
    final d = p['data'];
    print("RESPONSE: " + j.toString());
    switch (j['method']) {
      case "System.OnQuit":
        _timeUpdateTimer?.cancel();
        this.currentItem = null;
        this.canSeek = false;
        this.playList = [];
        break;
      case "Other.PlaybackStarted":
        await _refreshPlayerProperties();
        await _refreshPlayerItem();
        return;
      case "Input.OnInputRequested":
        _dialogService.dismissDialog();
        _dialogService.dialogComplete();
        var input = Input.fromJson(d);
        var dialogResult = await _dialogService.showDialog(input);
        if (dialogResult != null) {
          ApiProvider.sendTextInput(player, data: dialogResult);
        }
        return;
      case "Input.OnInputFinished":
        _dialogService.dismissDialog();
        _dialogService.dialogComplete();
        return;
      case "Application.OnVolumeChanged":
        if (_volAdjustTimer == null) {
          currentTemporaryVolume = d['volume'];
          muted = d['muted'];
        }
        break;
      case "Player.OnPropertyChanged":
        _updatePlayerProps(d['property']);
        return;
      case "Player.OnResume":
        speed = d['player']['speed'];
        _updateTimeTimer();
        break;
      case "Player.OnPause":
        speed = 0;
        _updateTimeTimer();
        break;
      case "Player.OnStop":
        speed = 0;
        time = PlayerTime.empty();
        totalTime = PlayerTime.empty();
        currentItem = null;
        _timeUpdateTimer?.cancel();
        break;
      case "Player.OnPlay":
        _timeUpdateTimer?.cancel();
        speed = d['player']['speed'];
        await _refreshPlayerItem();
        await _refreshPlayerProperties();
        break;
      case "Player.OnAVStart":
        _timeUpdateTimer?.cancel();
        speed = d['player']['speed'];
        await _refreshPlayerItem();
        await _refreshPlayerProperties();
        return;
      case "Player.OnSeek":
        _timeUpdateTimer?.cancel();
        this.time = PlayerTime.fromJson(d['player']['time']);
        _updateTemporaryProgress();
        _updateTimeTimer();
        break;
      case "Playlist.OnClear":
        this.playList = [];
        break;
      case "Playlist.OnRemove":
        this.playList.removeAt(d['position']);
        break;
      case "Playlist.OnAdd":
        int pos = d['position'];
        var list = await ApiProvider.getPlayList(player,
            id: d['playlistid'], lowerLimit: pos, upperLimit: pos + 1);
        this.playList.add(list.first);
        break;
    }
    notifyListeners();
  }

  // * Endpoints
  // ** Player Item Endpoints
  Future<void> _refreshPlayerItem() async {
    final result = await ApiProvider.getPlayerItem(player);
    if (result.isNotEmpty) {
      if (result['label'].isEmpty) {
        this.currentItem = null;
      } else {
        this.currentItem = VideoItem.fromJson(result);
      }
      notifyListeners();
    }
  }

  // ** Playlist Endpoints
  Future<void> _refreshPlayList() async {
    if (playlistID != -1) {
      this.playList = await ApiProvider.getPlayList(player, id: playlistID);
      notifyListeners();
    }
  }

  // ** Player Property Endpoints
  Future<void> _refreshPlayerProperties() async {
    final r = await ApiProvider.getPlayerProperties(player);
    if (r.isNotEmpty) _updatePlayerProps(r);
  }

  void _updatePlayerProps(Map<String, dynamic> r) {
    bool timeChanged = false;
    bool speedChanged = false;
    if (r['time'] != null) {
      time = PlayerTime.fromJson(r['time']);
      timeChanged = true;
    }
    if (r['totaltime'] != null) {
      print("TOTALTIME: " + r['totaltime'].toString());
      totalTime = PlayerTime.fromJson(r['totaltime']);
    }
    type = r['type'] ?? type;
    if (r['speed'] != null) {
      speed = r['speed'];
      speedChanged = true;
    }
    canSeek = r['canseek'] ?? canSeek;
    if (r['repeat'] != null) {
      repeat = enumFromString(Repeat.values, r['repeat'] ?? "off");
    }
    playlistID = r['playlistid'] ?? playlistID;
    if (r['currentvideostream'] != null) {
      currentVideoStream = VideoStream.fromJson(r['currentvideostream']);
    }
    if (r['videostreams'] != null) {
      videoStreams = r['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList();
    }
    if (timeChanged || speedChanged) {
      _timeUpdateTimer?.cancel();
      _updateTimeTimer();
      if (timeChanged) _updateTemporaryProgress();
    }
    notifyListeners();
  }

  void _updateTimeTimer() {
    _timeUpdateTimer?.cancel();
    if (speed != 0) {
      _timeUpdateTimer =
          Timer.periodic(Duration(milliseconds: (1000 / speed).round()), (t) {
        if (_seekTimer == null) {
          this.time = this.time.increment(1);
          _updateTemporaryProgress();
          notifyListeners();
        }
      });
    }
  }

  void toggleRepeat() => ApiProvider.toggleRepeat(player);

  void playPause() => ApiProvider.playPause(player);

  /// Navigate forward/backwards in the playlist. False for previous, true for next
  void goto(dynamic to) async => ApiProvider.goTo(player, to);

  void stopPlayback() => ApiProvider.stop(player);

  void _updateTemporaryProgress() {
    final ctime = time.inSeconds;
    final ttime = totalTime.inSeconds;
    this.currentTemporaryProgress = ctime > ttime ? -1 : ctime / (ttime * 1.0);
  }

  void seek(double percentage) {
    currentTemporaryProgress = percentage;
    if (_seekTimer == null) {
      _seekTimer = new Timer(_seekTimeout, () async {
        ApiProvider.seek(player, percentage: currentTemporaryProgress);
        _seekTimer = null;
      });
    }
    notifyListeners();
  }

  /// Skip ahead (positive) or behind (negative) by the given [amount] of seconds
  void skip(int amount) {
    var params = {"time": time.increment(amount)};
    ApiProvider.skip(player, params);
  }

  // ** Application Property Endpoints

  Future<void> _refreshApplicationProperties() async {
    final r = await ApiProvider.getApplicationProperties(player);
    if (r.isNotEmpty) {
      currentTemporaryVolume =
          r['volume']?.toDouble() ?? currentTemporaryVolume;
      muted = r['muted'] ?? muted;
      notifyListeners();
    }
  }

  void setVolume(double newVolume) {
    currentTemporaryVolume = newVolume.clamp(0.0, 100.0);
    if (_volAdjustTimer == null) {
      _volAdjustTimer = new Timer(_volumeSetTimeout, () {
        ApiProvider.adjustVolume(player,
            newVolume: currentTemporaryVolume.round().clamp(0, 100));
        _volAdjustTimer = null;
      });
    }
    notifyListeners();
  }

  void increaseVolumeSmall() => setVolume(currentTemporaryVolume + 5);
  void decreaseVolumeSmall() => setVolume(currentTemporaryVolume - 5);

  void toggleMute() => ApiProvider.toggleMute(player, !this.muted);

  // ** Navigation Endpoints

  void navigate(String command) => ApiProvider.navigate(player, command);

  // ** System Endpoints
  Future<void> _fetchSystemProperties() async {
    final result = await ApiProvider.getSystemProperties(player);
    if (result.isNotEmpty) {
      systemProps = Map<String, bool>.from(result);
      notifyListeners();
    }
  }

  void toggleSystemProperty(String property) {
    if (systemProps[property] ?? false)
      ApiProvider.toggleSystemProperty(
          player, property.substring(3).capitalize());
  }

  // ** Playlist actions

  // *** Move Playlist Item
  /// Move item in the current playlist. NOTE: Call syncPlaylistMove after the swap has been finished in the widget tree. This function does not sync the change with the remote Player.
  void movePlaylistItem(int from, int to) {
    if (from != -1 && to != -1 && from != to) {
      final draggedItem = playList[from];
      playList.removeAt(from);
      playList.insert(to, draggedItem);
      if (_oldLocation == null) _oldLocation = from;
      notifyListeners();
    }
  }

  int? _oldLocation;

  // *** Sync Playlist Move
  /// Syncronizes the most recent move event (As determined by the private variable oldLocation) with the remote Player instance.
  void syncMovePlaylistItem(int newLocation) async {
    if (_oldLocation != null) {
      // Notify the Kodi instance.
      while (_oldLocation! != newLocation) {
        var step = _oldLocation! < newLocation ? 1 : -1;
        await ApiProvider.swapPlaylistItems(player,
            playListID: playlistID,
            from: _oldLocation!,
            to: _oldLocation! + step);
        _oldLocation = _oldLocation! + step;
      }
      _oldLocation = null;
    }
  }

  /// *** Remove item from playlist
  /// Removes the given item from the current playlist.
  void removePlaylistItem(Key item) async {
    ApiProvider.removePlaylistItem(player,
        playlistID: playlistID,
        location: playList.indexWhere((i) => i.id == item));
  }

  // * Properties
  // ** Application Properties
  bool muted = false;
  double currentTemporaryVolume = 0.0;

  // ** System Properties
  Map<String, bool> systemProps = const {};

  // ** Player Properties
  PlayerTime time = PlayerTime.empty();
  PlayerTime totalTime = PlayerTime.empty();
  double currentTemporaryProgress = -1;
  int playlistID = -1;
  int speed = 0;
  String type = "Null";
  bool canSeek = false;
  Repeat repeat = Repeat.Off;

  List<VideoStream> videoStreams = [];
  VideoStream? currentVideoStream;

  bool get playing => speed > 0;

  // ** Player Item Properties
  Item? currentItem;

  // ** Playlist Properties
  List<PlaylistItemModel> playList = [];
}

Map<String, dynamic> _convertJsonData(String json) =>
    jsonDecode(json) as Map<String, dynamic>;
