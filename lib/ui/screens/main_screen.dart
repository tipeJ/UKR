import 'package:UKR/models/player.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MainProvider? mainProvider;
    ApplicationProvider? applicationProvider;
    ItemProvider? itemProvider;
    return Selector<PlayersProvider, Player>(
        selector: (context, provider) => provider.selectedPlayer,
        builder: (_, value, __) {
          if (value == null) return PlayersScreen();
          if (mainProvider == null) {
            mainProvider = new MainProvider(value);
          } else {
            mainProvider!.initialize(value);
          }
          if (applicationProvider == null) {
            applicationProvider = new ApplicationProvider(value);
          } else {
            applicationProvider!.initialize(value);
          }
          if (itemProvider == null) {
            itemProvider = new ItemProvider(value);
          } else {
            itemProvider!.initialize(value);
          }
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<MainProvider>(create: (_) => mainProvider),
              ChangeNotifierProvider<ItemProvider>(create: (_) => itemProvider),
              ChangeNotifierProvider<ApplicationProvider>(
                  create: (_) => applicationProvider)
            ],
            builder: (context, child) => RemoteScreen(),
          );
        });
  }

  MainProvider newMethod(Player value) {
    print("BLBLBLB");
    return new MainProvider(value);
  }
}
