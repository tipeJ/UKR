import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/content_screen.dart';
import 'package:UKR/ui/screens/playlist_screen.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PagesScreen extends StatefulWidget {
  @override
  _PagesScreenState createState() => _PagesScreenState();
}

class _PagesScreenState extends State<PagesScreen> {
  late final PageController _controller;

  @override
  void initState() {
    _controller = PageController(initialPage: 1);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height;
    return PageView(
      controller: _controller,
      dragStartBehavior: DragStartBehavior.down,
      allowImplicitScrolling: true,
      children: [
        ContentScreen(),
        GestureDetector(
          onVerticalDragUpdate: (details) {
            final endPos = maxHeight - kBottomNavigationBarHeight;
            final clampedP = details.globalPosition.dy.clamp(
                kBottomNavigationBarHeight,
                maxHeight - kBottomNavigationBarHeight);
            final newVolume = ((endPos - clampedP).abs() /
                (endPos - kBottomNavigationBarHeight));
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
        PlaylistScreen()
      ],
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
          InkWell(
            onTap: () => Navigator.of(context).pushNamed(ROUTE_CURRENT_ITEM_DETAILS),
            child: CurrentItem()
          ),
          RemoteButtons(),
        ],
      ),
    );
  }
}
