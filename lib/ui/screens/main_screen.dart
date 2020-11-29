import 'package:UKR/models/player.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    UKProvider? ukProvider;
    return Selector<PlayersProvider, Player>(
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
              ChangeNotifierProvider<UKProvider>(create: (_) => ukProvider),
            ],
            builder: (context, child) => RemoteScreen(),
          );
        });
  }
}
