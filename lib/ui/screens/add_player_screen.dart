import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddPlayerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Selector<PlayersProvider, Stream<List<Player>>?>(
        selector: (_, p) => p.networkDiscoveryPlayers,
        builder: (_, stream, __) {
          if (stream != null) {
            return StreamBuilder<List<Player>>(
              stream: stream,
              builder: (_, snapshot) {
                return snapshot.connectionState != ConnectionState.none &&
                        snapshot.hasData && snapshot.data!.isNotEmpty
                    ? ListView.builder(itemCount: snapshot.data!.length, itemBuilder: (_, i) => PlayerListItem(snapshot.data![i]))
                    : CircularProgressIndicator();
              },
            );
          }
          return Center(
            child: Column(
              children: [
                Text("STREAM NULL"),
                FlatButton(
                    child: Text("START NETWORK DISCOVERY"),
                    onPressed: () => context.read<PlayersProvider>().discoVERY())
              ],
            ),
          );
        },
      ),
    );
  }
}
