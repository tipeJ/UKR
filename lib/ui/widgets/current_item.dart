import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/models/models.dart';

class CurrentItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentItem = context.select<UKProvider, Item>((p)=> p.currentItem);
    switch (currentItem.runtimeType) {
      case VideoItem:
        final item = currentItem as VideoItem;
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(item.label),
              ]),
        );
      case AudioItem:
        return Text("Audio");
      default:
        return const Text("Nothing is Playing");
    }
  }
}
