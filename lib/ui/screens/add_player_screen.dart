import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AddPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Player")),
      bottomNavigationBar: Container(
        width: MediaQuery.of(context).size.width,
        height: kBottomNavigationBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Selector<PlayersProvider, bool>(
              selector: (_, p) => p.networkDiscoveryPlayers != null,
              builder: (_, hasSearched, __) => FlatButton(
                  child:
                      Text(hasSearched ? "Search Again" : "Search for Players"),
                  onPressed: () => context.read<PlayersProvider>().discoVERY()),
            ),
            FlatButton(
                child: Text("Add Manually"),
                onPressed: () async {
                  final r = await showDialog(
                      context: context, builder: (_) => AddPlayerDialog());
                  if (r != null) Navigator.pop(context, r);
                })
          ],
        ),
      ),
      body: Selector<PlayersProvider, Stream<List<Tuple2<Player, bool>>>?>(
        selector: (_, p) => p.networkDiscoveryPlayers,
        builder: (_, stream, __) {
          if (stream != null) {
            return StreamBuilder<List<Tuple2<Player, bool>>>(
              stream: stream,
              builder: (_, snapshot) {
                final data = snapshot.data ?? const [];
                Widget loadingIndicator = Container(
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    data.isEmpty) {
                  return const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                          "No players Found. You can try adding a player manually below"));
                } else if (snapshot.hasData) {
                  return ListView.builder(
                    itemCount:
                        snapshot.connectionState == ConnectionState.active
                            ? data.length + 1
                            : data.length,
                    itemBuilder: (_, i) =>
                        snapshot.connectionState == ConnectionState.active &&
                                i == data.length
                            ? loadingIndicator
                            : _DiscoveryPlayerListItem(
                                data[i].item1, data[i].item2),
                  );
                }
                return Align(alignment: Alignment.topCenter, child: loadingIndicator);
              },
            );
          }
          // Return empty container
          return Container();
        },
      ),
    );
  }
}

class _DiscoveryPlayerListItem extends StatelessWidget {
  final Player player;
  final bool auth;
  const _DiscoveryPlayerListItem(this.player, this.auth);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(player.name),
      subtitle: Text(player.port.toString()),
      onTap: () async {
        if (auth) {
          Navigator.of(context).pop(player);
        } else {
          final result = await showDialog(
              context: context,
              builder: (_) => _PlayerAuthDialog(player: player));
          if (result != null) {
            final authResult = await ApiProvider.getApplicationProperties(
                Player(
                    address: player.address,
                    id: player.id,
                    name: player.name,
                    port: player.port,
                    username: result.item1,
                    password: result.item2));
            if (authResult['error'] == null) {
              // Success!
              Navigator.of(context).pop(Player(
                  address: player.address,
                  id: player.id,
                  name: authResult['name'] + " (${player.name})",
                  port: player.port,
                  username: result.item1,
                  password: result.item2));
            }
          }
        }
      },
    );
  }
}

class _PlayerAuthDialog extends StatefulWidget {
  const _PlayerAuthDialog({
    Key? key,
    required this.player,
  }) : super(key: key);

  final Player player;

  @override
  __PlayerAuthDialogState createState() => __PlayerAuthDialogState();
}

class __PlayerAuthDialogState extends State<_PlayerAuthDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _nameController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _passwordController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Authentification for ${widget.player.name}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: "Password"),
          ),
        ],
      ),
      actions: [
        FlatButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(context).pop()),
        FlatButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context)
                .pop(Tuple2(_nameController.text, _passwordController.text))),
      ],
    );
  }
}
