import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RemoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _buildAppBar(context),
        drawer: Drawer(child: _PlayersBar()),
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
    Widget title;
    List<Widget> actions = [];
    final player = context.watch<PlayersProvider>().selectedPlayer;
    if (player == null) {
      title = const Text("TEST");
    } else {
      title = Text(player.address);
      actions.add(_PlayerPowerOptions());
    }
    return AppBar(title: title, actions: actions);
  }
}

class _PlayerPowerOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<ApplicationProvider, Map<String, bool>>(
        selector: (context, provider) => provider.systemProps,
        builder: (_, values, __) {
          if (values.values.contains(true)) {
            return PopupMenuButton<String>(
                icon: const Icon(Icons.power_settings_new),
                tooltip: "Power Menu",
                onSelected: (newValue) {
                  context
                      .read<ApplicationProvider>()
                      .toggleSystemProperty(newValue);
                },
                itemBuilder: (_) => values.keys.map((String property) {
                      return PopupMenuItem<String>(
                        value: property,
                        enabled: values[property] ?? false,
                        child: Text(property.substring(3).capitalize()));
                  }).toList());
          }
          return Container();
        });
  }
}

class _PlayersBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayersProvider>().players;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text("Players",
                    style: Theme.of(context).textTheme.headline5),
              )),
              SliverList(
                  delegate: SliverChildListDelegate(
                      List<PlayerListItem>.generate(
                          players.length, (i) => PlayerListItem(players[i])))),
              SliverToBoxAdapter(
                  child: InkWell(
                      onTap: () async {
                        final result = await showDialog(
                            context: context,
                            builder: (_) => AddPlayerDialog());
                        if (result != null) {
                          context.read<PlayersProvider>().addPlayer(result);
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: const Text("Add Player",
                              style: TextStyle(fontWeight: FontWeight.w200)))))
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("UKR (ALPHA)",
                    style: TextStyle(fontWeight: FontWeight.w200)),
                IconButton(icon: const Icon(Icons.settings), onPressed: () {})
              ],
            ))
      ],
    );
  }
}
