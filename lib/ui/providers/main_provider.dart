import 'dart:async';
import 'package:async/async.dart' show StreamZip;

import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';

class MainProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();

  Timer _volAdjustTimer;
  double currentTemporaryVolume = 0.0;
  static const _volumeSetTimeout = const Duration(milliseconds: 300);

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
      this.currentTemporaryVolume = applicationProperties.volume.toDouble();
      notifyListeners();
    });
  }

  void setVolume(double newVolume) {
    currentTemporaryVolume = newVolume;
    if (_volAdjustTimer == null) {
      _volAdjustTimer = new Timer(_volumeSetTimeout, () {
        _api.adjustVolume(_player,
            newVolume: currentTemporaryVolume.round().clamp(0, 100));
        _volAdjustTimer = null;
      });
    }
    notifyListeners();
  }

  void adjustVolume(double diff) {
    final newVolume = (applicationProperties.volume + diff);
    setVolume(newVolume);
  }
}
