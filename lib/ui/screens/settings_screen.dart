import 'package:UKR/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';

const SETTINGS_THEME = "theme";
const SETTINGS_THEME_AUTO = 0;
const SETTINGS_THEME_DARK = 1;
const SETTINGS_THEME_LIGHT = 2;
class SettingsProvider extends ChangeNotifier {
  late Box _box;

  Brightness get brightness {
    int theme = _box.get(SETTINGS_THEME, defaultValue: SETTINGS_THEME_AUTO);
    switch (theme) {
      case SETTINGS_THEME_AUTO:
        return SchedulerBinding.instance?.window.platformBrightness ?? Brightness.light;
      case SETTINGS_THEME_LIGHT:
        return Brightness.light;
      default:
        return Brightness.dark;
    }
  } 
  Future<SettingsProvider> initialize() async {
    _box = await Hive.openBox(BOX_SETTINGS);
    return this;
  }

  void putSetting(String key, dynamic value) {
    _box.put(key, value);
    notifyListeners();
  }
}
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Center(
        child: Text('Settings'),
      ),
    );
  }
}
