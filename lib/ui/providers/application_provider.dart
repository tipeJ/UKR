import 'dart:async';
import 'package:UKR/utils/utils.dart';
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

  String _name = "";
  String get name => _name;

  String _version = "";
  String get version => _version;

  int _volume = 0;
  int get volume => _volume;

  bool _muted = false;
  bool get muted => _muted;

  // System Properties
  Map<String, bool> systemProps;

  bool get canHibernate => systemProps['canhibernate'] ?? false;

  bool get canReboot => systemProps['canreboot'] ?? false;

  bool get canShutdown => systemProps['canshutdown'] ?? false;

  bool get canSuspend => systemProps['cansuspend'] ?? false;

  @override
  void dispose() {
    _stream.cancel();
    _volAdjustTimer.cancel();
    super.dispose();
  }

  ApplicationProvider(this._player) {
    this._stream = _api.applicationPropertiesStream(_player).listen((props) {
      if (_volAdjustTimer == null &&
          (name != props.name ||
              _version != props.version ||
              _volume != props.volume ||
              _muted != props.muted)) {
        _name = props.name;
        _version = props.version;
        _volume = props.volume;
        currentTemporaryVolume = _volume.toDouble();
        _muted = props.muted;
        notifyListeners();
      }
    });
    _fetchSystemProperties();
  }

  void _fetchSystemProperties() async =>
      systemProps = await _api.getSystemProperties(_player);

  void toggleSystemProperty(String property) {
    if (systemProps[property])
      _api.toggleSystemProperty(_player, property.substring(3).capitalize());
  }

  void setVolume(double newVolume) {
    currentTemporaryVolume = newVolume.clamp(0.0, 100.0);
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
    final newVolume = (_volume + diff);
    setVolume(newVolume);
  }

  void increaseVolumeSmall() => setVolume(currentTemporaryVolume + 5);
  void decreaseVolumeSmall() => setVolume(currentTemporaryVolume - 5);

  void toggleMute() async {
    final response = await _api.toggleMute(_player, !this._muted);
    if (response != _muted) {
      _muted = response;
      notifyListeners();
    }
  }

  void navigate(String action) => _api.navigate(_player, action);
}
