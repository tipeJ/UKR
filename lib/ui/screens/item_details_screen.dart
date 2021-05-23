import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ItemDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<UKProvider, Item?>(
        selector: (_, p) => p.currentItem,
        builder: (_, item, __) {
          switch (item.runtimeType) {
            case VideoItem:
              return VideoDetailsScreen(item as VideoItem, isCurrentItem: true);
            default:
              return const Text("Unknown item");
          }
        });
  }
}

