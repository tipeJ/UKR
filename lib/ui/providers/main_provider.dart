import 'dart:async';
import 'package:async/async.dart' show StreamZip;

import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';

class MainProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();

  Stream<ApplicationProperties> _applicationPropsStream;
  Stream<PlayerProperties> _playerPropsStream;

  StreamSubscription<List<dynamic>> _properties;

  final Player _player;
  MainProvider(this._player) {
    _applicationPropsStream = _api.applicationPropertiesStream(_player);
    _playerPropsStream = _api.playerPropertiesStream(_player);
    update();
  }

  @override
  void dispose() {
    _properties.cancel();
    super.dispose();
  }

  PlayerProperties playerProperties = EmptyPlayerProperties;
  ApplicationProperties applicationProperties = EmptyApplicationProperties;

  int get volume =>
      applicationProperties != null ? applicationProperties.volume : 0;

  void update() async {
    _properties = StreamZip([_applicationPropsStream, _playerPropsStream])
        .listen((props) {
      this.applicationProperties = props[0] as ApplicationProperties;
      this.playerProperties = props[1] as PlayerProperties;
      notifyListeners();
    });
  }

  void setVolume(int newVolume) async {
    final vol = newVolume.clamp(0, 100);
    await _api.adjustVolume(_player, newVolume: vol);
  }

  void adjustVolume(int diff) async {
    final newVolume = (applicationProperties.volume + diff);
    setVolume(newVolume);
  }
}
