import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class PlayersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayersProvider>().players;
    return Scaffold(
        appBar: AppBar(title: const Text("Manage Players")),
        body: ListView(
            children: List<Widget>.generate(
                players.length, (i) => _PlayerListItem(players[i]))));
  }
}

class _PlayerListItem extends StatefulWidget {
  final Player player;
  const _PlayerListItem(this.player);

  @override
  State<StatefulWidget> createState() => _PlayerListItemState();
}

class _PlayerListItemState extends State<_PlayerListItem> {
  bool verified;
  get _player => widget.player;
  @override
  Widget build(BuildContext context) => Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Column(
            children: [
              Text(_player.name, style: Theme.of(context).textTheme.headline6),
              const Spacer(),
              Text(_player.address),
              Text(_player.port.toString())
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                  child: FutureBuilder(
                future: context.read<PlayersProvider>().testPlayer(_player),
                builder: (context, snapshot) {
                  Widget child;
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData()) {
                    child = snapshot.data
                        ? const Icon(Icons.check, color: Colors.greenAccent)
                        : const Icon(Icons.train, color: Colors.redAccent);
                  } else {
                    child = Container();
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 750),
                    child: child,
                  );
                },
              )))
        ],
      ));
}
