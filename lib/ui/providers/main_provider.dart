import 'dart:async';

import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';

class MainProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();
  final Player _player;

  late final Stream<PlayerProperties> _playerPropsStream;
  late final StreamSubscription<PlayerProperties> _properties;

  MainProvider(this._player) {
    _playerPropsStream = _api.playerPropertiesStream(_player);
    _properties = _playerPropsStream.listen((props) {
      if (props != playerProperties) {
        playerProperties = props;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _properties.cancel();
    super.dispose();
  }

  /// Initialized with empty player properties
  PlayerProperties playerProperties = PlayerProperties();

  bool get playing => playerProperties.playing;

  void togglePlay() => _api.playPause(_player);
  void stop() => _api.stop(_player);
  void seek(double percentage) => _api.seek(_player, percentage: percentage);

  void toggleRepeat() => _api.toggleRepeat(_player);
}
