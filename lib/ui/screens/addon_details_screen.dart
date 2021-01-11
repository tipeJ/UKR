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
            title: Hero(
              tag: HERO_CONTENT_ADDON_TITLE + addon.addonID,
              child: Text(addon.name)
            ),
            expandedHeight: 150,
            flexibleSpace: addon.thumbnail != null
                ? Stack(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: CachedNetworkImage(
                          fit: BoxFit.cover, imageUrl: addon.thumbnail),
                    ),
                    Container(color: Colors.black26)
                  ],
                )
                : Container()),
        if (addon.description != null)
          SliverToBoxAdapter(
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(addon.description!))),
        if (addon.disclaimer != null) SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Text(addon.disclaimer!)
            )),
        SliverToBoxAdapter(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (addon.type == KODI_PLUGIN_TYPE_PLUGINSOURCE) TextButton(
                  child: const Text("Content"),
                  onPressed: () {
                    var args = Tuple3<Player, String, String>(
                        context.read<PlayersProvider>().selectedPlayer,
                        "plugin://${addon.addonID}/",
                        addon.name
                      );
                    Navigator.of(context)
                        .pushNamed(ROUTE_FILELIST, arguments: args);
                  }),
              TextButton(
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
