import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
              builder: (_, hasSearched, __) =>
                FlatButton(
                      child: Text(hasSearched ? "Search Again" : "Search for Players"),
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
      body: Selector<PlayersProvider, Stream<List<Player>>?>(
        selector: (_, p) => p.networkDiscoveryPlayers,
        builder: (_, stream, __) {
          if (stream != null) {
            return StreamBuilder<List<Player>>(
              stream: stream,
              builder: (_, snapshot) {
                return snapshot.connectionState != ConnectionState.none &&
                        snapshot.hasData &&
                        snapshot.data!.isNotEmpty
                    ? ListView.builder(
                        itemCount: snapshot.data!.length,
                        itemBuilder: (_, i) =>
                            PlayerListItem(snapshot.data![i]))
                    : CircularProgressIndicator();
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
