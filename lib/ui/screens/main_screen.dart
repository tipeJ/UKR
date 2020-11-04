import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PlayersProvider>();
    return prov.selectedPlayer == null
        ? PlayersScreen()
        : Scaffold(
            appBar: AppBar(title: const Text("Remote Screen Titlte")),
            body: MultiProvider(
              providers: [
                ChangeNotifierProvider<MainProvider>(create: (_) => MainProvider(prov.selectedPlayer)),
                ChangeNotifierProvider<ApplicationProvider>(create: (_) => ApplicationProvider(prov.selectedPlayer))
              ],
              builder: (context, child) => RemoteScreen(),
            ));
  }
}
