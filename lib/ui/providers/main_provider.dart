import 'dart:async';

import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';

class MainProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();
  Player? _player;

  Player get player => _player!;
  StreamSubscription<PlayerProperties>? _properties;

  MainProvider(Player player) {
    initialize(player);
  }

  void initialize(Player player) {
    this._player = player;
    _properties?.pause();
    _properties = _api.playerPropertiesStream(player).listen((props) {
      if (props != playerProperties) {
        playerProperties = props;
        notifyListeners();
      }
    });
    _properties?.resume();
  }

  @override
  void dispose() {
    _properties?.cancel();
    super.dispose();
  }

  /// Initialized with empty player properties
  PlayerProperties playerProperties = PlayerProperties();

  bool get playing => playerProperties.playing;

  void togglePlay() => _api.playPause(player);
  void stop() => _api.stop(player);
  void seek(double percentage) => _api.seek(player, percentage: percentage);

  void toggleRepeat() => _api.toggleRepeat(player);
}
