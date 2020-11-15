import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class RemoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        bottomSheet: RemoteControlsBar(),
        body: Stack(
          children: [
            BackgroundVolume(),
            Align(alignment: Alignment.topCenter, child: CurrentItem()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: EdgeInsets.only(bottom: 50.0),
                  child: RemoteButtons()),
            )
          ],
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    Widget leading = IconButton(
      icon: const Icon(Icons.menu),
      onPressed: (){

      },
    );
    Widget title;
    List<Widget> actions = [];
    final player = context.watch<PlayersProvider>().selectedPlayer;
    if (player == null) {
      title = const Text("TEST");
    } else {
      title = Text(player.address);
      actions.add(
          IconButton(icon: const Icon(Icons.power_outlined), onPressed: () {}));
    }
    return AppBar(leading: leading, title: title, actions: actions);
  }
}
