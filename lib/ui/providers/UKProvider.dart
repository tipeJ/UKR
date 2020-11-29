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
  static const _seekTimeout = const Duration(milliseconds: 700);

  WebSocket? _ws;
  WebSocket get _w => _ws!;
  static const _resultTimeout = const Duration(milliseconds: 1000);
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
    _volAdjustTimer?.cancel();
    _timeUpdateTimer?.cancel();
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
    await _refreshPlayerProperties();
    await _refreshApplicationProperties();
    await _fetchSystemProperties();
  }

  void _handleJsonResponse(Map<String, dynamic> j) {
    print("RECEIVED" + j.toString());
    final result = j['result'];
    if (result != null && !(result is String)) {
      // Send the result to the result Sink, to be picked up by the sending function:
      _resultSink.add(result);
      return;
    }
    if (j['params'] == null) return;
    final p = j['params'];
    final d = p['data'];
    switch (j['method']) {
      case "Other.PlaybackStarted":
        _refreshPlayerProperties();
        return;
      case "Application.OnVolumeChanged":
        if (_volAdjustTimer == null) {
          currentTemporaryVolume = d['volume'];
          muted = d['muted'];
        }
        break;
      case "Player.OnPropertyChanged":
        _updatePlayerProps(d['property']);
        break;
      case "Player.OnPlay":
        title = d['item']['title'];
        itemType = d['item']['type'];
        break;
      case "Player.OnSeek":
        this.time = PlayerTime.fromJson(d['player']['time']);
        _updateTemporaryProgress();
        break;
    }
    notifyListeners();
  }

  // Player Property Endpoints
  Future<void> _refreshPlayerProperties() async {
    final body = await _encodeCommand("Player.getProperties", {
      "playerid": _playerID,
      "properties": const [
        "position",
        "repeat",
        "type",
        "speed",
        "totaltime",
        "time",
        "canseek",
        "videostreams",
        "currentvideostream"
      ]
    });
    _w.add(body);
    final r = await _getResult();
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
    if (r['currentvideostream'] != null) {
      currentVideoStream = VideoStream.fromJson(r['currentvideostream']);
    }
    if (r['videostreams'] != null) {
      print("VIDEOSTREAMS: " + r['videostreams'].toString());
      videoStreams = r['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList();
    }
    if (timeChanged || speedChanged) {
      _timeUpdateTimer?.cancel();
      if (timeChanged) _updateTemporaryProgress();
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
    notifyListeners();
  }

  void toggleRepeat() async {
    final body = await _encodeCommand(
        "Player.SetRepeat", const {"playerid": _playerID, "repeat": "cycle"});
    _w.add(body);
  }

  void playPause() async {
    final body = await _encodeCommand(
        "Player.PlayPause", const {"playerid": _playerID, "play": "toggle"});
    _w.add(body);
  }

  /// Navigate forward/backwards in the playlist. False for previous, true for next
  void goto({bool direction = true}) async => _w.add(await _encodeCommand(
      "Player.GoTo",
      {"playerid": _playerID, "to": direction ? "next" : "previous"}));

  void stopPlayback() async {
    final body =
        await _encodeCommand("Player.Stop", const {"playerid": _playerID});
    _w.add(body);
  }

  void _updateTemporaryProgress() {
    final ctime = time.inSeconds;
    final ttime = totalTime.inSeconds;
    this.currentTemporaryProgress = ctime > ttime ? -1 : ctime / (ttime * 1.0);
  }

  void seek(double percentage) {
    currentTemporaryProgress = (percentage);
    if (_seekTimer == null) {
      _seekTimer = new Timer(_seekTimeout, () async {
        final c = await _encodeCommand("Player.Seek", {
          "playerid": _playerID,
          "value": (currentTemporaryProgress * 100).round()
        });
        _w.add(c);
        _seekTimer = null;
      });
    }
    notifyListeners();
  }

  /// Skip ahead (positive) or behind (negative) by the given [amount] of seconds
  void skip(int amount) async {
    Map<String, dynamic>? params;
    if (amount < 0) {
      params = {"seconds": amount};
    } else {
      final newTime = time.increment(amount);
      params = {"time": newTime.toJson()};
    }
    _w.add(await _encodeCommand(
        "Player.Seek", {"playerid": _playerID, "value": params}));
    await _getResult();
  }

  // Application Property Endpoints

  Future<void> _refreshApplicationProperties() async {
    final body = await _encodeCommand("Application.GetProperties", {
      "properties": const ["muted", "name", "version", "volume"]
    });
    _w.add(body);
    final r = await _getResult();
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

  // Navigation Endpoints

  void navigate(String command) async =>
      _w.add(await _encodeCommand("Input.ExecuteAction", {"action": command}));

  // System Properties

  Future<void> _fetchSystemProperties() async {
    final c = await _encodeCommand("System.GetProperties", const {
      "properties": ["canshutdown", "canhibernate", "canreboot", "cansuspend"]
    });
    _w.add(c);
    final result = await _getResult();
    if (result.isNotEmpty) {
      systemProps = Map<String, bool>.from(result);
      notifyListeners();
    }
  }

  void toggleSystemProperty(String property) {
    if (systemProps[property] ?? false)
      _api.toggleSystemProperty(player, property.substring(3).capitalize());
  }

  // Application Properties
  bool muted = false;
  double currentTemporaryVolume = 0.0;

  // System Properties
  Map<String, bool> systemProps = const {};
  // Player Properties
  PlayerTime time = PlayerTime(0, 0, 0);
  PlayerTime totalTime = PlayerTime(0, 0, 0);
  double currentTemporaryProgress = -1;
  int speed = 0;
  String type = "Null";
  bool canSeek = false;
  Repeat repeat = Repeat.Off;

  List<VideoStream> videoStreams = [];
  VideoStream? currentVideoStream;

  bool get playing => speed > 0;

  // Player Item Properties
  String? title;
  String? itemType;
}

Map<String, dynamic> _convertJsonData(String json) =>
    jsonDecode(json) as Map<String, dynamic>;
