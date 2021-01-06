import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';

class CurrentItem extends StatelessWidget {
  final CrossAxisAlignment alignment;
  const CurrentItem({this.alignment = CrossAxisAlignment.center});
  @override
  Widget build(BuildContext context) {
    var currentItem = context.select<UKProvider, Item?>((p) => p.currentItem);
    final theme = Theme.of(context).textTheme;
    switch (currentItem.runtimeType) {
      case VideoItem:
        final item = currentItem as VideoItem;
        String headline = "Nothing is playing";
        List<Widget> children = [];
        if (item.type == "movie") {
          headline = item.label;
          children = [
            item.director.nullIf(
                Hero(
                    tag: HERO_CURRENT_ITEM_CAPTION,
                    child: Text(item.director.separateFold(', '),
                        style: theme.subtitle1)),
                (d) => d.isNotEmpty),
            item.year.nullOr(Hero(
                tag: HERO_CURRENT_ITEM_YEAR,
                child: Text(item.year.toString(), style: theme.caption))),
          ].nonNulls() as List<Widget>;
        } else if (item.type == "episode") {
          headline = item.showTitle ?? item.label;
          children = [
            Hero(
              tag: HERO_CURRENT_ITEM_CAPTION,
              child: Text("S${item.season} E${item.episode} - ${item.label}",
                  style: theme.subtitle1),
            ),
            Hero(
              tag: HERO_CURRENT_ITEM_YEAR,
              child: Text(
                  (item.director.nullIf(item.director.separateFold(', '),
                              (d) => d.isNotEmpty) ??
                          "") +
                      (item.year != null ? " - " + item.year.toString() : ""),
                  style: theme.caption),
            )
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
                crossAxisAlignment: alignment,
                children: [
                  Hero(
                      tag: HERO_CURRENT_ITEM_HEADLINE,
                      child: AutoSizeText(
                        headline,
                        style: theme.headline5,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )),
                  ...children
                ]));
      case AudioItem:
        return Text("Audio");
      default:
        return const Padding(
            padding: EdgeInsets.all(10.0), child: Text("Nothing is Playing"));
    }
  }
}
