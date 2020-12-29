import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BackgroundVolumeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height - 2 * 56.0;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        color: Color.lerp(
            Colors.black12,
            Colors.black26,
            context.select<UKProvider, double>(
                    (p) => p.currentTemporaryVolume) /
                100),
        width: MediaQuery.of(context).size.width,
        height: (maxHeight -
                (maxHeight *
                    (context.select<UKProvider, double>(
                            (p) => p.currentTemporaryVolume) /
                        100)))
            .clamp(0.0, maxHeight),
      ),
    );
  }
}

class BackgroundImageWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var item = context.select<UKProvider, Item?>((p) => p.currentItem);
    var art = item?.artwork ?? {};
    Widget? child;
    return LayoutBuilder(builder: (_, constraints) {
      if (item != null && art.isNotEmpty) {
        String url = retrieveOptimalImage(item);
        if (url.isNotEmpty) {
          child =
              CachedNetworkImage(fit: BoxFit.cover, imageUrl: url);
        }
      }
      return Stack(
        children: [
          Container(
              width: constraints.biggest.width,
              height: constraints.biggest.height,
              child: child ?? Container()),
          Container(color: Colors.black45)
        ],
      );
    });
  }
}
