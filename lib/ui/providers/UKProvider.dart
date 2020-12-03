import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UKProvider extends ChangeNotifier {
  final _api = ApiProvider();
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
  static const _resultTimeout = const Duration(milliseconds: 5000);
  StreamController<Map<String, dynamic>> _resultSink =
      StreamController.broadcast();

  /// Returns an encoded version of the given command. Encoded in an isolate.
  static Future<String> _encodeCommand(
          String method, Map<String, dynamic> params) =>
      compute(jsonEncode, {"method": method, "params": params, ...defParams});

  Future<Map<String, dynamic>> _getResult() => _resultSink.stream.first
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

  void initialize(Player player) async {
    this._player = player;
    this._ws?.close();
    this._ws = await _api.getWS(player);

    this
        ._w
        .asyncMap<Map<String, dynamic>>(
            (data) => compute(_convertJsonData, data.toString()))
        .listen((data) => _handleJsonResponse(data));

    // Refresh the initial values.
    await _refreshPlayerProperties();
    await _refreshApplicationProperties();
    await _refreshPlayerItem();
    await _refreshPlayList();
    await _fetchSystemProperties();
    notifyListeners();
  }

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
      case "Other.PlaybackStarted":
        _refreshPlayerProperties();
        await _refreshPlayerItem();
        _updateTimeTimer();
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
        await _refreshPlayerProperties();
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
        speed = d['player']['speed'];
        _updateTimeTimer();
        await _refreshPlayerItem();
        return;
      case "Player.OnSeek":
        this.time = PlayerTime.fromJson(d['player']['time']);
        _updateTemporaryProgress();
        _updateTimeTimer();
        break;
      case "Playlist.OnClear":
        this.playList = [];
        break;
    }
    notifyListeners();
  }

  // * Endpoints
  // ** Player Item Endpoints
  Future<void> _refreshPlayerItem() async {
    final result = await _api.getPlayerItem(player);
    if (result.isNotEmpty) {
      this.currentItem = VideoItem.fromJson(result);
      notifyListeners();
    }
  }

  // ** Playlist Endpoints
  Future<void> _refreshPlayList() async {
    if (playlistID != -1) {
      this.playList = await _api.getPlayList(player, id: playlistID);
      notifyListeners();
    }
  }

  // ** Player Property Endpoints
  Future<void> _refreshPlayerProperties() async {
    final r = await _api.getPlayerProperties(player);
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

  void toggleRepeat() => _api.toggleRepeat(player);

  void playPause() => _api.playPause(player);

  /// Navigate forward/backwards in the playlist. False for previous, true for next
  void goto({bool direction = true}) async => _w.add(await _encodeCommand(
      "Player.GoTo",
      {"playerid": _playerID, "to": direction ? "next" : "previous"}));

  void stopPlayback() => _api.stop(player);

  void _updateTemporaryProgress() {
    final ctime = time.inSeconds;
    final ttime = totalTime.inSeconds;
    this.currentTemporaryProgress = ctime > ttime ? -1 : ctime / (ttime * 1.0);
  }

  void seek(double percentage) {
    currentTemporaryProgress = percentage;
    if (_seekTimer == null) {
      _seekTimer = new Timer(_seekTimeout, () async {
        _api.seek(player, percentage: currentTemporaryProgress);
        _seekTimer = null;
      });
    }
    notifyListeners();
  }

  /// Skip ahead (positive) or behind (negative) by the given [amount] of seconds
  void skip(int amount) {
    var params = {"time": time.increment(amount)};
    _api.skip(player, params);
  }

  // ** Application Property Endpoints

  Future<void> _refreshApplicationProperties() async {
    final r = await _api.getApplicationProperties(player);
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
        _api.adjustVolume(player,
            newVolume: currentTemporaryVolume.round().clamp(0, 100));
        _volAdjustTimer = null;
      });
    }
    notifyListeners();
  }

  void increaseVolumeSmall() => setVolume(currentTemporaryVolume + 5);
  void decreaseVolumeSmall() => setVolume(currentTemporaryVolume - 5);

  void toggleMute() => _api.toggleMute(player, !this.muted);

  // ** Navigation Endpoints

  void navigate(String command) => _api.navigate(player, command);

  // ** System Endpoints
  Future<void> _fetchSystemProperties() async {
    final result = await _api.getSystemProperties(player);
    if (result.isNotEmpty) {
      systemProps = Map<String, bool>.from(result);
      notifyListeners();
    }
  }

  void toggleSystemProperty(String property) {
    if (systemProps[property] ?? false)
      _api.toggleSystemProperty(player, property.substring(3).capitalize());
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
  List<Item> playList = [];
}

Map<String, dynamic> _convertJsonData(String json) =>
    jsonDecode(json) as Map<String, dynamic>;
