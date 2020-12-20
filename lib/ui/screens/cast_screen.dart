
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CastScreen extends StatelessWidget {
  final VideoItem item;
  const CastScreen(this.item);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: item.cast.length,
        itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: CastItem(
                name: item.cast.keys.elementAt(i),
                role: item.cast.values.elementAt(i))));
  }
}
