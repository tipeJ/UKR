import 'dart:ui';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';

class RemoteControlsBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RemoteControlsBarState();
}

class _RemoteControlsBarState extends State<RemoteControlsBar>
    with SingleTickerProviderStateMixin {
  static const minSize = 50.0;
  static const maxSize = 150.0;
  static const _startTextStyle = TextStyle(fontSize: 14.0);
  static const _endTextStyle = TextStyle(fontSize: 20.0);
  AnimationController _controller;
  double _lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(value: 0.0, vsync: this);
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: _lerp(minSize, maxSize),
        child: GestureDetector(
            onVerticalDragUpdate: (details) {
              _controller.value -= (details.delta.dy / maxSize);
            },
            onVerticalDragEnd: (details) {
              _controller.fling(velocity: -details.primaryVelocity / maxSize);
            },
            child: Container(
              color: Colors.grey,
              padding: const EdgeInsets.all(10.0),
              child: Stack(
                children: [
                  Container(
                    color: Colors.red,
                    width: minSize,
                    height: minSize,
                    alignment: Alignment.lerp(
                        Alignment.topLeft, Alignment.center, _controller.value),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: _lerp(minSize + 5.0, 5.0)),
                    child: Text(
                      "TEST VIDEO LABELL",
                      style: TextStyle.lerp(
                          _startTextStyle, _endTextStyle, _controller.value),
                    ),
                  ),
                  Align(
                      alignment: Alignment.lerp(Alignment.topRight,
                          Alignment.center, _controller.value),
                      child: _BottomControlButtons(_lerp)),
                  Positioned(
                      bottom: 0.0,
                      width: MediaQuery.of(context).size.width,
                      child: IgnorePointer(
                          ignoring: _controller.value < 0.5,
                          child: Opacity(
                              opacity: _controller.value,
                              child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [_BottomVolumeSlider()]))))
                ],
              ),
            )));
  }
}

class _BottomControlButtons extends StatelessWidget {
  final Function(double, double) _lerp;
  static const _minSize = 22.0;
  static const _maxSize = 34.0;

  const _BottomControlButtons(this._lerp);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous),
          iconSize: _lerp(_minSize, _maxSize),
          onPressed: () {
            print("prev");
          },
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          iconSize: _lerp(_minSize, _maxSize * 1.2),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.skip_next),
          iconSize: _lerp(_minSize, _maxSize),
          onPressed: () {
            print("nxt");
          },
        )
      ],
    );
  }
}

class _BottomVolumeSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Text(context.watch<MainProvider>().volume.toString()),
          Expanded(
              child: Slider(
            min: 0.0,
            max: 100.0,
            value: context.watch<MainProvider>().currentTemporaryVolume,
            onChanged: (newValue) {
              context.read<MainProvider>().setVolume(newValue);
            },
          ))
        ]));
  }
}
