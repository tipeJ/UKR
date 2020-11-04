import 'dart:async';

import 'package:UKR/models/models.dart';
import 'package:UKR/models/player.dart';
import 'package:UKR/resources/api_provider.dart';
import 'package:flutter/material.dart';

class ApplicationProvider extends ChangeNotifier {
  final _api = ApiProvider();
  final Player _player;
  StreamSubscription<ApplicationProperties> _stream;

  Timer _volAdjustTimer;
  double currentTemporaryVolume = 0.0;
  static const _volumeSetTimeout = const Duration(milliseconds: 300);

  ApplicationProperties properties = EmptyApplicationProperties;

  int get volume => properties.volume;

  @override
  void dispose() {
    _stream.cancel();
    _volAdjustTimer.cancel();
    super.dispose();
  }

  ApplicationProvider(this._player) {
    this._stream = _api.applicationPropertiesStream(_player).listen((props) {
      if (this.properties != props) {
        this.properties = props;
        notifyListeners();
      }
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
    final newVolume = (properties.volume + diff);
    setVolume(newVolume);
  }
}
