import 'package:flutter/material.dart';
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
        List<Widget> children = [const Text("Nothing is playing")];
        if (item.type == "movie") {
          children = [
            Text(item.label, style: theme.headline5),
            item.director.nullIf(
                Text(item.director.separateFold(', '), style: theme.subtitle1),
                (d) => d.isNotEmpty),
            item.year.nullOr(Text(item.year.toString(), style: theme.caption)),
          ].nonNulls() as List<Widget>;
        } else if (item.type == "episode") {
          children = [
            Text(item.showTitle ?? item.label, style: theme.headline5),
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
          children = [Text(item.label, style: theme.headline6)];
        }
        return Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0, top: 10.0),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: children));
      case AudioItem:
        return Text("Audio");
      default:
        return const Padding(
            padding: EdgeInsets.all(10.0), child: Text("Nothing is Playing"));
    }
  }
}
