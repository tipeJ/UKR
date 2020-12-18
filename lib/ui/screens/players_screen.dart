import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';

class PlayersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final players = context.watch<PlayersProvider>().players;
    return Scaffold(
        appBar: AppBar(title: const Text("Manage Players")),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await showDialog(
                context: context, builder: (_) => AddPlayerDialog());
            if (result != null) {
              context.read<PlayersProvider>().addPlayer(result);
            }
          },
          child: const Icon(Icons.add),
        ),
        body: ListView(
            children: List<Widget>.generate(
                players.length, (i) => PlayerListItem(players[i]))));
  }
}

class PlayerListItem extends StatefulWidget {
  final Player player;
  final bool compact;
  const PlayerListItem(this.player, {this.compact = false});

  @override
  State<StatefulWidget> createState() => PlayerListItemState();
}

class PlayerListItemState extends State<PlayerListItem> {
  bool? verified;
  get _player => widget.player;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: () {
          context.read<PlayersProvider>().setPlayer(_player);
          Navigator.of(context).pop();
        },
        child: Container(
            padding: const EdgeInsets.all(5.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.compact
                      ? [
                          Text(_player.name,
                              style: Theme.of(context).textTheme.bodyText1),
                          Text("${_player.address}:${_player.port}",
                              style: TextStyle(fontWeight: FontWeight.w200))
                        ]
                      : [
                          Text(_player.name,
                              style: Theme.of(context).textTheme.headline6),
                          Text(_player.address,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w300)),
                          Text(_player.port.toString(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.w200))
                        ],
                ),
                Padding(
                    padding: EdgeInsets.all(widget.compact ? 5.0 : 20.0),
                    child: Center(
                        child: FutureBuilder<bool>(
                      future:
                          context.watch<PlayersProvider>().testPlayer(_player),
                      builder: (context, snapshot) {
                        Widget child;
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          child = snapshot.data ?? false
                              ? const Icon(Icons.check,
                                  color: Colors.greenAccent)
                              : const Icon(Icons.close,
                                  color: Colors.redAccent);
                        } else {
                          child = Container();
                        }
                        return Container(
                          width: 35.0,
                          height: 35.0,
                          alignment: Alignment.center,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 750),
                            child: child,
                          ),
                        );
                      },
                    )))
              ],
            )),
      );
}
