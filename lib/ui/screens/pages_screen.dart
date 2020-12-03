import 'package:UKR/ui/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.only(bottom: kBottomNavigationBarHeight),
      child: PageView(
        dragStartBehavior: DragStartBehavior.down,
        allowImplicitScrolling: true,
        children: [
          Container(
            color: Colors.black45,
            child: Text("Content be here")
          ),
          GestureDetector(
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
              child: _RemotePage(),
            ),
          ),
          ListView.builder(
              itemCount: 5000,
              itemBuilder: (_, i) => ListTile(title: Text(i.toString())))
        ],
      ),
    );
  }
}

class _RemotePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max,
        children: [
          CurrentItem(),
          RemoteButtons(),
        ],
      ),
    );
  }
}
