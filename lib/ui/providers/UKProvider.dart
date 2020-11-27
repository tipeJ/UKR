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

  Timer? _volAdjustTimer;
  double currentTemporaryVolume = 0.0;
  static const _volumeSetTimeout = const Duration(milliseconds: 300);

  WebSocket? _ws;

  UKProvider(Player p) {
    initialize(p);
  }
  void initialize(Player player) async {
    this._player = player;
    this._ws?.close();
    this._ws = await _api.getWS(player);

    this
        ._ws
        ?.asyncMap<Map<String, dynamic>>(
            (data) => compute(_convertJsonData, data.toString()))
        .listen((data) => _handleJsonResponse(data));
  }

  void _handleJsonResponse(Map<String, dynamic> j) {
    final d = j['params']['data'];
    switch (j['method']) {
      case "Application.OnVolumeChanged":
        if (_volAdjustTimer == null) {
          currentTemporaryVolume = j['params']['data']['volume'];
          muted = j['params']['data']['muted'];
        }
        break;
      case "Player.OnPropertyChanged":
        repeat = enumFromString(Repeat.values, d['property']['repeat']) ?? repeat;

        break;
      case "Player.OnPlay":
        title = d['item']['title'];
        itemType = d['item']['type'];
        break;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ws?.close();
    _volAdjustTimer?.cancel();
    super.dispose();
  }

  // Application Properties
  bool muted = false;

  // Player Properties
  Repeat repeat = Repeat.Off;

  // Player Item Properties
  String? title;
  String? itemType;
}

Map<String, dynamic> _convertJsonData(String json) => jsonDecode(json);
