import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // return ReorderableList(
    //     onReorder: (_, __) {
    //       return true;
    //     },
    //     onReorderDone: (_) {},
    //     child: ListView.separated(
    //         itemCount: playList.length,
    //         separatorBuilder: (_, __) => const Divider(),
    //         itemBuilder: (_, i) => PlaylistItem(playList[i], onTap: () {
    //               print("Clicked ${playList[i].fileUrl}");
    //             })));
    return Selector<UKProvider, List<Item>>(
      selector: (_, p) => p.playList.toList(),
        builder: (_, playList, __) {
          return ListView.separated(
              itemCount: playList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, i) => PlaylistItem(playList[i], onTap: () {
                    print("Clicked ${playList[i].fileUrl}");
                  }));
        });
  }
}
