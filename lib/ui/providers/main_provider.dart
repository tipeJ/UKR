import 'dart:async';
import 'package:async/async.dart';

import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';

class MainProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();
  Stream<PlayerProperties> _playerPropsStream;

  StreamSubscription<PlayerProperties> _properties;

  final Player _player;
  MainProvider(this._player) {
    _playerPropsStream = _api.playerPropertiesStream(_player);
    update();
  }

  @override
  void dispose() {
    _properties.cancel();
    super.dispose();
  }

  PlayerProperties playerProperties = EmptyPlayerProperties;

  bool get playing => playerProperties.playing;

  void update() async {
    _properties = _playerPropsStream.listen((props) {
      if (props != playerProperties) {
        playerProperties = props;
        notifyListeners();
      }
    });
  }

  void togglePlay() => _api.playPause(_player);
  void stop() => _api.stop(_player);
  void seek(double percentage) => _api.seek(_player, percentage: percentage);

  void toggleRepeat() => _api.toggleRepeat(_player);
}
