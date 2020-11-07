import 'dart:ui';
import 'dart:math';
import 'package:UKR/models/models.dart';
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
  static const maxSize = 200.0;
  static const _startTextStyle = TextStyle(fontSize: 14.0);
  static const _endTextStyle = TextStyle(fontSize: 20.0);
  static const _tapAnimateDuration = const Duration(milliseconds: 350);
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
            onTap: () {
              if (_controller.value == 0.0) {
                _controller.animateTo(1.0,
                    duration: _tapAnimateDuration, curve: Curves.ease);
              } else if (_controller.value == 1.0) {
                _controller.animateTo(0.0,
                    duration: _tapAnimateDuration, curve: Curves.ease);
              }
            },
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
  static const _containerPadding = const EdgeInsets.symmetric(horizontal: 10.0);

  const _BottomControlButtons(this._lerp);

  static IconData _getRepeatIcon(Repeat repeat) {
    switch (repeat) {
      case Repeat.One:
        return Icons.repeat_one;
      default:
        return Icons.repeat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final _contSize = min(40.0, MediaQuery.of(context).size.width / 6 - 20.0);
    return Material(
        color: Colors.transparent,
        child: Container(
            height: 40.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                    onTap: () {
                      context.read<MainProvider>().toggleRepeat();
                    },
                    child: Container(
                        width: _lerp(0.0, _contSize),
                        margin:
                            EdgeInsets.symmetric(horizontal: _lerp(0.0, 10.0)),
                        child: Icon(
                            _getRepeatIcon(context.watch<MainProvider>().playerProperties.repeat),
                            size: _lerp(0.0, _maxSize)))),
                InkWell(
                    onTap: () {
                      print("ss");
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(Icons.skip_previous,
                            size: _lerp(_minSize, _maxSize)))),
                InkWell(
                    onTap: () {
                      print("nax");
                    },
                    child: Container(
                        width: _lerp(0.0, _contSize),
                        margin:
                            EdgeInsets.symmetric(horizontal: _lerp(0.0, 10.0)),
                        child: Icon(Icons.skip_previous_sharp,
                            size: _lerp(0.0, _maxSize)))),
                InkWell(
                    onTap: () {
                      context.read<MainProvider>().togglePlay();
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(
                            context
                                    .watch<MainProvider>()
                                    .playerProperties
                                    .playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: _lerp(_minSize, _maxSize * 1.2)))),
                InkWell(
                    onTap: () {
                      print("PPPP");
                    },
                    child: Container(
                        width: _lerp(0.0, _contSize),
                        margin:
                            EdgeInsets.symmetric(horizontal: _lerp(0.0, 10.0)),
                        child: Icon(Icons.skip_next_sharp,
                            size: _lerp(0.0, _maxSize)))),
                InkWell(
                    onTap: () {
                      print("PPPP");
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(Icons.skip_next,
                            size: _lerp(_minSize, _maxSize)))),
                InkWell(
                    onTap: () {
                      print("STOP");
                      context.read<MainProvider>().stop();
                    },
                    child: Container(
                        width: _lerp(0.0, _contSize),
                        margin:
                            EdgeInsets.symmetric(horizontal: _lerp(0.0, 10.0)),
                        child: Icon(Icons.stop, size: _lerp(0.0, _maxSize)))),
              ],
            )));
  }
}

class _BottomVolumeSlider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          Container(
            width: 35.0,
            alignment: Alignment.center,
            child: InkWell(
                onTap: () => context.read<ApplicationProvider>().toggleMute(),
                child: context.watch<ApplicationProvider>().muted
                    ? const Icon(Icons.volume_off)
                    : Text(context
                        .watch<ApplicationProvider>()
                        .currentTemporaryVolume.round()
                        .toString())),
          ),
          Expanded(
            child: Slider(
              min: 0.0,
              max: 100.0,
              value:
                  context.watch<ApplicationProvider>().currentTemporaryVolume,
              onChanged: (newValue) {
                context.read<ApplicationProvider>().setVolume(newValue);
              },
            ),
          ),
        ]));
  }
}

class _SeekBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final props = context.watch<MainProvider>().playerProperties;
    final progress = props.time.inSeconds / props.totalTime.inSeconds;

    return progress > 1.0
        ? const Text("LIVE")
        : Slider(
            min: 0.0,
            max: 1.0,
            value: progress,
            onChanged: (_) {},
            onChangeEnd: (newValue) {
              context.read<MainProvider>().seek(newValue);
            },
          );
  }
}
