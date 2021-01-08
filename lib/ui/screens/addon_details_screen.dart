import 'package:UKR/models/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
              fit: BoxFit.cover,
              imageUrl: addon.thumbnail
            )
            : Container()
        ),
        if (addon.description != null)
          SliverToBoxAdapter(
              child: Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(addon.description!))),
              SliverList(delegate: SliverChildBuilderDelegate((_, i) => Text(i.toString())),)
      ],
    );
  }
}
