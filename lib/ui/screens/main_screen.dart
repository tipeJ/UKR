import 'package:UKR/models/player.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/remote_screen.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  final _key = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await _key.currentState?.maybePop();
          return Future.value(false);
        },
        child: Navigator(
          onGenerateRoute: _Router.generateRoute,
          initialRoute: ROUTE_MAIN,
          key: _key,
        ));
  }
}

class _Router {
  static Route generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Widget child = Center(child: Text("No Router found for ${settings.name}"));
    switch (settings.name) {
      case ROUTE_MAIN:
        UKProvider? ukProvider;
        child = Selector<PlayersProvider, Player?>(
            selector: (context, provider) => provider.selectedPlayer,
            builder: (_, value, __) {
              if (value == null) return PlayersScreen();
              if (ukProvider == null) {
                ukProvider = new UKProvider(value);
              } else {
                ukProvider!.initialize(value);
              }
              return MultiProvider(
                providers: [
                  ChangeNotifierProvider<UKProvider>(
                      create: (_) => ukProvider!),
                ],
                builder: (context, child) => RemoteScreen(),
              );
            });
        break;
      case ROUTE_PLAYERS:
        child = PlayersScreen();
        break;
      case ROUTE_ADD_PLAYER:
        child = AddPlayerScreen();
        break;
      case ROUTE_SETTINGS:
        child = SettingsScreen();
        break;
    }
    return MaterialPageRoute(builder: (context) => child);
  }
}
