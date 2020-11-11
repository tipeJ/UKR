import 'package:UKR/models/item.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class CurrentItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final item = context.watch<ItemProvider>().item;
    return item == null
        ? Text("Nothing is Playing")
        : Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(item.label),
              // Text((item as VideoItem).fanart)
            ],
          );
  }
}
