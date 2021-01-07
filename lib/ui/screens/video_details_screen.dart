import 'dart:math';
import 'package:UKR/resources/constants.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Screen for video details. Includes plot, tagline and cast widgets.
class VideoDetailsScreen extends StatelessWidget {
  static const _padding = EdgeInsets.symmetric(horizontal: 16.0);
  final VideoItem item;
  const VideoDetailsScreen(this.item);

  @override
  Widget build(BuildContext context) {
    String image = retrieveOptimalImage(item);
    final theme = Theme.of(context).textTheme;
    Color background = Color.fromARGB(80, 0, 0, 0);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Container(height: 100)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
            child: Row(
              children: [
                image.isNotEmpty
                    ? Container(
                        width: 50,
                        height: 50 * (16.0 / 9.0),
                        child: CachedNetworkImage(
                            imageUrl: image, fit: BoxFit.cover),
                      )
                    : null,
                Expanded(child: CurrentItem(alignment: CrossAxisAlignment.start)),
              ].nonNulls() as List<Widget>,
            ),
        )),
        SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              color: background,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (item.tagline != null) Row(
                            children: [
                              Expanded(child: Text(item.tagline!, style: theme.bodyText1)),
                              if (item.rating != null)
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: item.rating!.toStringAsPrecision(3),
                                      style: theme.subtitle1),
                                  TextSpan(text: "/10", style: theme.caption)
                                ]))
                            ],
                          ),
                    if (item.tagline != null) Divider(),
                    if (item.plot != null) Text(item.plot!, style: theme.caption),
                    if (item.genres.isNotEmpty) Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(item.genres.separateFold(","), style: theme.caption?.apply(color: Colors.white)),
                    )
                  ]),
        )),
        if (item.cast.isNotEmpty)
          SliverToBoxAdapter(
              child: Container(
            padding: _padding,
            color: background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text("Cast", style: theme.headline6), Divider()],
            ),
          )),
        if (item.cast.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
                (context, i) => Container(
                    padding: const EdgeInsets.only(left: 16.0),
                    color: background,
                    child: i == min(item.cast.length, 10) + 1
                        ? InkWell(
                            child: Text(
                                "View Entire Cast (${item.cast.length})",
                                style: theme.subtitle2),
                            onTap: () => Navigator.of(context)
                                .pushNamed(ROUTE_CAST_SCREEN, arguments: item))
                        : CastItem(
                            name: item.cast.keys.elementAt(i),
                            role: item.cast.values.elementAt(i))),
                childCount: min(item.cast.length, 10) + 2),
          )
      ],
    );
  }
}
