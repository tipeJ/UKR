import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';

class CurrentItem extends StatelessWidget {
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
        }
        return Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AutoSizeText(headline, style: theme.headline5, maxLines: 1),
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
