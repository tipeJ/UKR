import 'dart:math';
import 'package:UKR/resources/constants.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Screen for video details. Includes plot, tagline and cast widgets.
class VideoDetailsScreen extends StatelessWidget {
  static const _padding = EdgeInsets.symmetric(horizontal: 8.0);
  final VideoItem item;
  const VideoDetailsScreen(this.item);

  @override
  Widget build(BuildContext context) {
    String image = retrieveOptimalImage(item);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: Container(height: 100)),
        SliverToBoxAdapter(
            child: Padding(
          padding: _padding,
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
          margin: _padding,
          padding: const EdgeInsets.all(8.0),
          // color: Color.fromARGB(80, 0, 0, 0),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                item.tagline != null
                    ? Text(item.tagline!,
                        style: Theme.of(context).textTheme.bodyText1)
                    : null,
                item.tagline != null ? Divider() : null,
                item.plot != null
                    ? Text(item.plot!,
                        style: Theme.of(context).textTheme.caption)
                    : null,
              ].nonNulls() as List<Widget>),
        )),
        if (item.cast.isNotEmpty)
          SliverToBoxAdapter(
              child: Container(
            padding: _padding,
            margin: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cast", style: Theme.of(context).textTheme.headline6),
                Divider()
              ],
            ),
          )),
        SliverList(
          delegate: SliverChildBuilderDelegate(
              (context, i) => Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: i == min(item.cast.length, 10) + 1
                ? InkWell(child: Text("View Entire Cast (${item.cast.length})"), onTap:() => Navigator.of(context).pushNamed(ROUTE_CAST_SCREEN, arguments: item))
                : CastItem(
                    name: item.cast.keys.elementAt(i),
                    role: item.cast.values.elementAt(i))
              ),
              childCount: min(item.cast.length, 10) + 2),
        )
      ],
    );
  }
}

