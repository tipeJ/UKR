import 'package:UKR/resources/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

const SETTINGS_THEME = "theme";
const SETTINGS_THEME_AUTO = 0;
const SETTINGS_THEME_DARK = 1;
const SETTINGS_THEME_LIGHT = 2;
class SettingsProvider extends ChangeNotifier {
  late Box _box;

  int get brightness => _box.get(SETTINGS_THEME, defaultValue: SETTINGS_THEME_AUTO);

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
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) => ListView(
          children: <Widget>[
            ListTile(
              title: Text('Theme'),
              trailing: DropdownButton<int>(
                value: settings.brightness,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    settings.putSetting(SETTINGS_THEME, newValue);
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: SETTINGS_THEME_AUTO,
                    child: Text('Auto'),
                  ),
                  DropdownMenuItem(
                    value: SETTINGS_THEME_DARK,
                    child: Text('Dark'),
                  ),
                  DropdownMenuItem(
                    value: SETTINGS_THEME_LIGHT,
                    child: Text('Light'),
                  ),
                ],
              ),
              onTap: () => settings.putSetting(SETTINGS_THEME, (settings.brightness + 1) % 3),
            ),
          ],
        ),
      )
    );
  }
}
