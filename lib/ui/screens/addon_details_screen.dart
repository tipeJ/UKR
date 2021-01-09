import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class AddonDetailsScreen extends StatelessWidget {
  final Addon addon;

  const AddonDetailsScreen(this.addon);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
            automaticallyImplyLeading: false,
            title: Text(addon.name),
            expandedHeight: 150,
            flexibleSpace: addon.thumbnail != null
                ? CachedNetworkImage(
                    fit: BoxFit.cover, imageUrl: addon.thumbnail)
                : Container()),
        if (addon.description != null)
          SliverToBoxAdapter(
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(addon.description!))),
        SliverToBoxAdapter(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FlatButton(
                  child: const Text("Content"),
                  onPressed: () {
                    var args = Tuple2<Player, String>(
                        context.read<PlayersProvider>().selectedPlayer,
                        "plugin://${addon.addonID}/");
                    Navigator.of(context)
                        .pushNamed(ROUTE_FILELIST, arguments: args);
                  }),
              FlatButton(
                child: const Text("Launch"),
                onPressed: () async {
                  final p = context.read<PlayersProvider>().selectedPlayer;
                  final g = await ApiProvider.executeAddon(p!,
                      addonID: addon.addonID);
                  print("AWAITED: $g");
                },
              )
            ],
          ),
        )
      ],
    );
  }
}
