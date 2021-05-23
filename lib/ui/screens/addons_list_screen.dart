import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AddonsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<PlayersProvider, Player?>(
        selector: (_, p) => p.selectedPlayer,
        builder: (_, player, __) => player != null
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: Hero(
                          tag: HERO_CONTENT_ADDONS_HEADER,
                          child: Text("Addons",
                              style: Theme.of(context).textTheme.headline5))),
                  _addonsHeader(context, "Video Addons"),
                  _addonsSubList(context, "video", player),
                  _addonsHeader(context, "Audio Addons"),
                  _addonsSubList(context, "audio", player),
                  _addonsHeader(context, "Image Addons"),
                  _addonsSubList(context, "image", player),
                  _addonsHeader(context, "Executable Addons"),
                  _addonsSubList(context, "executable", player),
                  _addonsHeader(context, "Other Addons"),
                  _addonsSubList(context, "unknown", player)
                ],
              )
            : const Center(child: Text("No Player Selected")));
  }

  static Widget _addonsHeader(BuildContext context, String title) =>
      SliverToBoxAdapter(
          child: Text(title, style: Theme.of(context).textTheme.headline6));

  static Widget _addonsSubList(
          BuildContext context, String content, Player player) =>
      FutureBuilder<List<Addon>>(
          future: ApiProvider.fetchAddons(player, content: content),
          builder: (_, snapshot) => snapshot.hasData &&
                  snapshot.connectionState != ConnectionState.waiting
              ? SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _AddonListTile(snapshot.data![i]),
                    childCount: snapshot.data?.length ?? 200,
                  ),
                )
              : const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator())));
}

class _AddonListTile extends StatelessWidget {
  final Addon addon;
  const _AddonListTile(this.addon);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => Navigator.of(context).pushNamed(ROUTE_ADDON_DETAILS, arguments: addon),
      leading: addon.thumbnail != null
          ? SizedBox(
            width: 40,
            height: 40,
            child: CachedNetworkImage(
                imageUrl: addon.thumbnail!,
              ),
          )
          : null,
          title: Hero(
            tag: HERO_CONTENT_ADDON_TITLE + addon.addonID,
            child: Text(addon.name)
          ),
      subtitle: addon.description != null ? Text(addon.description!, maxLines: 2, overflow: TextOverflow.ellipsis,) : null,
    );
  }
}
