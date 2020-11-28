import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UKProvider extends ChangeNotifier {
  final _api = ApiProvider();
  Player? _player;
  Player get player => _player!;

  static const _playerID = 1;
  static const defParams = {"jsonrpc": "2.0", "id": 27928};
  Timer? _volAdjustTimer;
  static const _volumeSetTimeout = const Duration(milliseconds: 300);

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
    _refreshApplicationProperties();
  }

  void _handleJsonResponse(Map<String, dynamic> j) {
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
    if (r['time'] != null) {
      time = PlayerTime.fromJson(r['time']);
    }
    if (r['totaltime'] != null) {
      totalTime = PlayerTime.fromJson(r['totaltime']);
    }
    type = r['type'] ?? type;
    speed = r['speed'] ?? speed;
    canSeek = r['canseek'] ?? canSeek;
    if (r['repeat'] != null) {
      repeat = enumFromString(Repeat.values, r['repeat'] ?? "off");
    }
    if (r['currentvideostream'] != null) {
      currentVideoStream = VideoStream.fromJson(r['currentvideostream']);
    }
    if (r['videostreams'] != null) {
      videoStreams = r['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList();
    }
    notifyListeners();
  }

  void toggleRepeat() async {
    final body = await _encodeCommand(
        "Player.SetRepeat", const {"playerid": _playerID, "repeat": "cycle"});
    _w.add(body);
  }

  // Application Property Endpoints

  void _refreshApplicationProperties() async {
    final body = await _encodeCommand("Application.GetProperties", {
      "properties": const ["muted", "name", "version", "volume"]
    });
    _w.add(body);
    final r = await _getResult();
    if (r.isNotEmpty) {
      print("REC" + r.toString());
      currentTemporaryVolume = r['volume']?.toDouble() ?? currentTemporaryVolume;
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

  // Application Properties
  bool muted = false;
  double currentTemporaryVolume = 0.0;

  // Player Properties
  PlayerTime time = PlayerTime(0, 0, 0);
  PlayerTime totalTime = PlayerTime(0, 0, 0);
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
