import 'package:UKR/resources/resources.dart';
import 'package:flutter/cupertino.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class BackgroundVolume extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    final maxWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        final endPos = maxHeight - 56.0;
        final clampedP =
            details.globalPosition.dy.clamp(56.0, maxHeight - 56.0);
        final newVolume = ((endPos - clampedP).abs() / (endPos - 56.0));
        context.read<UKProvider>().setVolume(newVolume * 100);
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            if (event.scrollDelta.dy < 0) {
              context.read<UKProvider>().increaseVolumeSmall();
            } else {
              context.read<UKProvider>().decreaseVolumeSmall();
            }
          }
        },
        child: Container(
          width: maxWidth,
          height: maxHeight,
          color: Colors.transparent,
          child: Stack(
            children: [
              BackgroundImageWrapper(),
              Container(
                  width: maxWidth,
                  height: maxHeight,
                  color: Color.fromARGB(125, 0, 0, 0)),
              BackgroundVolumeWrapper()
            ],
          ),
        ),
      ),
    );
  }
}

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
    String? url;
    Widget? child;
    if (item != null || art.isNotEmpty || art['poster'] != null) {
      url = retrieveOptimalImage(item!);
      if (url.isNotEmpty){
        final fit = MediaQuery.of(context).size.aspectRatio > 1.0
            ? BoxFit.fitWidth
            : BoxFit.fitHeight;
        child = CachedNetworkImage(fit: fit, imageUrl: art['poster']);
      }
    }
    return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black38,
        child: child ?? Container());
  }
}
