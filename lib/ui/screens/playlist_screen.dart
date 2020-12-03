import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playList = context.select<UKProvider, List<Item>>((p) => p.playList);
    return ListView.builder(
        itemCount: playList.length,
        itemBuilder: (_, i) => ListItem(playList[i], onTap: () {
              print("Clicked ${playList[i].label}");
    }));
  }
}
