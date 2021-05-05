import 'dart:math';
import 'dart:ui';
import 'package:UKR/resources/constants.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/// Screen for video details. Includes plot, tagline and cast widgets.
class VideoDetailsScreen extends StatelessWidget {
  static const _padding = EdgeInsets.symmetric(horizontal: 16.0);
  final VideoItem item;
  final bool isCurrentItem;
  const VideoDetailsScreen(this.item, {this.isCurrentItem = false});

  @override
  Widget build(BuildContext context) {
    String image = retrieveOptimalImage(item);
    TextTheme theme = Theme.of(context).textTheme;
    Color background = Color.fromARGB(80, 0, 0, 0);
    return Scaffold(
      floatingActionButton: isCurrentItem ? null : FloatingActionButton.extended(
        onPressed: () => context.read<UKProvider>().openFile(item.fileUrl),
        label: const Text("Play"),
        icon: const Icon(Icons.play_arrow),
      ),
      body: Stack(
        children: [
          // Blurred image background wrapper.
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(image)
            )),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                color: Colors.black.withOpacity(0.45),
              )
            ),
          ),
          CustomScrollView(
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
                    Expanded(child: isCurrentItem ? CurrentItem(alignment: CrossAxisAlignment.start) : _VideoDetailsTitle(item)),
                  ].nonNulls() as List<Widget>,
                ),
              )),
              SliverToBoxAdapter(
                  child: Container(
                padding: const EdgeInsets.all(16.0),
                color: background,
                child:
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (item.tagline != null)
                    Row(
                      children: [
                        Expanded(child: Text(item.tagline!, style: theme.bodyText1)),
                        if (item.rating != null && item.rating != 0.0)
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
                  if (item.genres.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(item.genres.separateFold(","),
                          style: theme.caption?.apply(color: Colors.white)),
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
          ),
        ],
      ),
    );
  }
}

// A non-animated version of CurrentItem
class _VideoDetailsTitle extends StatelessWidget {
  final VideoItem item;
  const _VideoDetailsTitle(this.item);

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    String headline = "Nothing is playing";
    List<Widget> children = [];
    if (item.type == "movie") {
      headline = item.label;
      children = [
        item.director.nullIf(
            Text(item.director.separateFold(', '), style: theme.subtitle1),
            (d) => d.isNotEmpty),
        item.year.nullOr(Text(item.year.toString(), style: theme.caption)),
      ].nonNulls() as List<Widget>;
    } else if (item.type == "episode") {
      headline = item.showTitle ?? item.label;
      children = [
        Text("S${item.season} E${item.episode} - ${item.label}",
            style: theme.subtitle1),
        Text(
            (item.director.nullIf(item.director.separateFold(', '),
                        (d) => d.isNotEmpty) ??
                    "") +
                (item.year != null ? " - " + item.year.toString() : ""),
            style: theme.caption)
      ];
    } else if (item.type == "unknown") {
      headline = item.label;
    } else if (item.type == "song") {
      headline = item.label;
    }
    return Container(
        padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(headline,
                  style: theme.headline5,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              ...children
            ]));
  }
}
