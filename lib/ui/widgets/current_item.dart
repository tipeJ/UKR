import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:UKR/models/models.dart';

class CurrentItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentItem = context.select<UKProvider, Item>((p) => p.currentItem);
    final theme = Theme.of(context).textTheme;
    switch (currentItem.runtimeType) {
      case VideoItem:
        final item = currentItem as VideoItem;
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(item.label, style: theme.headline6),
                item.director.nullIf(
                    Text(item.director.separateFold(', '),
                        style: theme.subtitle1),
                    (d) => d.isNotEmpty),
                item.year.nullOr(Text(item.year.toString(), style: theme.caption)),
              ].nonNulls() as List<Widget>),
        );
      case AudioItem:
        return Text("Audio");
      default:
        return const Padding(
            padding: EdgeInsets.all(10.0), child: Text("Nothing is Playing"));
    }
  }
}
