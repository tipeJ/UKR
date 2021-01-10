import 'dart:ui';
import 'package:UKR/utils/utils.dart';
import 'dart:math';
import 'package:UKR/models/models.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';

class RemoteControlsBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RemoteControlsBarState();
}

const minSize = 56.0;
const maxSize = 200.0;

class _RemoteControlsBarState extends State<RemoteControlsBar>
    with SingleTickerProviderStateMixin {
  static const _tapAnimateDuration = const Duration(milliseconds: 350);
  late final AnimationController _controller;
  late final PageController _pageController;
  double _lerp(double min, double max) =>
      lerpDouble(min, max, _controller.value) ?? 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(value: 0.0, vsync: this)
      ..addListener(() {
        setState(() {});
      });
    _pageController = PageController(initialPage: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: _lerp(minSize, maxSize),
        child: GestureDetector(
            onTap: () {
              if (_pageController.page == 1.0) {
                if (_controller.value == 0.0) {
                  _controller.animateTo(1.0,
                      duration: _tapAnimateDuration, curve: Curves.ease);
                } else if (_controller.value == 1.0) {
                  _controller.animateTo(0.0,
                      duration: _tapAnimateDuration, curve: Curves.ease);
                }
              }
            },
            onVerticalDragUpdate: (details) {
              if (_pageController.page == 1.0)
                _controller.value -= (details.delta.dy / maxSize);
            },
            onVerticalDragEnd: (details) {
              if (_pageController.page == 1.0)
                _controller.fling(
                    velocity: -details.primaryVelocity! / maxSize);
            },
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  _BottomBackground(_lerp),
                  PageView(
                      physics: _controller.value == 1.0
                          ? AlwaysScrollableScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      controller: _pageController,
                      children: [
                        _RemoteButtonsLite(),
                        Stack(
                          children: [
                            _BottomPlaybackInfo(_lerp),
                            Align(
                                alignment: Alignment.lerp(Alignment.centerRight,
                                    Alignment.center, _controller.value)!,
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
                                            children: [
                                              _BottomVolumeSlider()
                                            ]))))
                          ],
                        ),
                        _ChannelControlsBar()
                      ])
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

  static Color _getRepeatColor(Repeat repeat, BuildContext context) {
    if (repeat == Repeat.Off) return Colors.white;
    return Theme.of(context).accentColor;
  }

  @override
  Widget build(BuildContext context) {
    final _contSize = min(40.0, (MediaQuery.of(context).size.width / 6) - 32.0);
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
                      context.read<UKProvider>().toggleRepeat();
                    },
                    child: Container(
                        width: _lerp(0.0, _contSize),
                        margin:
                            EdgeInsets.symmetric(horizontal: _lerp(0.0, 10.0)),
                        child: Icon(
                            _getRepeatIcon(context
                                .select<UKProvider, Repeat>((p) => p.repeat)),
                            color: _getRepeatColor(
                                context.select<UKProvider, Repeat>(
                                    (p) => p.repeat),
                                context),
                            size: _lerp(0.0, _maxSize)))),
                InkWell(
                    onTap: () {
                      context.read<UKProvider>().goto("previous");
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(Icons.skip_previous,
                            size: _lerp(_minSize, _maxSize)))),
                Selector<UKProvider, bool>(
                  selector: (_, p) => p.canSeek,
                  builder: (_, canSeek, __) => InkWell(
                      onTap: () {
                        if (canSeek) context.read<UKProvider>().skip(-10);
                      },
                      onLongPress: () {
                        // Skip 1 min
                        if (canSeek) context.read<UKProvider>().skip(-60);
                      },
                      child: Container(
                          width: _lerp(0.0, _contSize),
                          margin: EdgeInsets.symmetric(
                              horizontal: _lerp(0.0, 10.0)),
                          child: Icon(Icons.replay_10,
                              size: _lerp(0.0, _maxSize),
                              color: canSeek ? null : Colors.grey))),
                ),
                InkWell(
                    onTap: () {
                      context.read<UKProvider>().playPause();
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(
                            context.select<UKProvider, bool>((p) => p.playing)
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: _lerp(_minSize, _maxSize * 1.2)))),
                Selector<UKProvider, bool>(
                  selector: (_, p) => p.canSeek,
                  builder: (_, canSeek, __) => InkWell(
                      onTap: () {
                        if (canSeek) context.read<UKProvider>().skip(30);
                      },
                      onLongPress: () {
                        // Skip 3 min
                        if (canSeek) context.read<UKProvider>().skip(180);
                      },
                      child: Container(
                          width: _lerp(0.0, _contSize),
                          margin: EdgeInsets.symmetric(
                              horizontal: _lerp(0.0, 10.0)),
                          child: Icon(Icons.forward_30,
                              size: _lerp(0.0, _maxSize),
                              color: canSeek ? null : Colors.grey))),
                ),
                InkWell(
                    onTap: () {
                      context.read<UKProvider>().goto("next");
                    },
                    child: Container(
                        width: _contSize,
                        margin: _containerPadding,
                        child: Icon(Icons.skip_next,
                            size: _lerp(_minSize, _maxSize)))),
                InkWell(
                    onTap: () {
                      print("STOP");
                      context.read<UKProvider>().stopPlayback();
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
        margin: const EdgeInsets.only(left: 10.0),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          InkWell(
            onTap: () => context.read<UKProvider>().toggleMute(),
            child: Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.center,
              child: context.select<UKProvider, bool>((p) => p.muted)
                  ? const Icon(Icons.volume_off, size: 15.0)
                  : Text(context
                      .select<UKProvider, double>(
                          (p) => p.currentTemporaryVolume)
                      .round()
                      .toString()),
            ),
          ),
          Expanded(
            child: Slider(
              min: 0.0,
              max: 100.0,
              value: context.watch<UKProvider>().currentTemporaryVolume,
              onChanged: (newValue) {
                context.read<UKProvider>().setVolume(newValue);
              },
            ),
          ),
        ]));
  }
}

class _BottomPlaybackInfo extends StatelessWidget {
  final Function(double, double) _lerp;

  const _BottomPlaybackInfo(this._lerp);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final _contSize = min(40.0, width / 6 - 28.0);
    final props = context
        .select<UKProvider, Tuple5<PlayerTime, PlayerTime, double, bool, bool>>(
            (p) => Tuple5(
                p.time,
                p.totalTime,
                p.currentTemporaryProgress,
                p.currentItem?.type != "Null" &&
                    (p.currentItem?.label.isNotEmpty ?? false),
                p.canSeek));
    if (props.item4) {
      return Positioned(
          left: _lerp(minSize, 0.0),
          child: Container(
              width: width,
              padding: const EdgeInsets.all(5.0),
              child: Row(
                children: [
                  Container(
                    width: _lerp(65.0, 100.0),
                    child: _TimeDisplay(props.item1, props.item2, _lerp),
                  ),
                  Visibility(
                    visible: width > 400 || _lerp(0.0, 1.0) > 0.5,
                    child: _SeekBar(props.item5, props.item3),
                  ),
                  Container(width: (_contSize + 30.0) * _lerp(3.0, 0.2))
                ],
              )));
    } else {
      return Container();
    }
  }
}

class _SeekBar extends StatelessWidget {
  final bool canSeek;
  final double progress;

  const _SeekBar(this.canSeek, this.progress);

  @override
  Widget build(BuildContext context) {
    if (canSeek) {
      if (progress < 1.0 && progress > 0)
        return Expanded(
          child: Slider(
            min: 0.0,
            max: 1.0,
            value: progress,
            onChanged: (newValue) {
              context.read<UKProvider>().seek(newValue);
            },
          ),
        );
    }
    return Container(
      child: const Text("LIVE"),
      padding:
          const EdgeInsets.only(left: 5.0, right: 5.0, top: 3.0, bottom: 3.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Theme.of(context).errorColor),
    );
  }
}

class _TimeDisplay extends StatelessWidget {
  const _TimeDisplay(this.time, this.totalTime, this._lerp);

  final PlayerTime time;
  final PlayerTime totalTime;
  final Function(double p1, double p2) _lerp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(time.toString(),
            style: TextStyle(
                fontWeight: FontWeight.w500, fontSize: _lerp(14.0, 20.0))),
        Text(totalTime.toString(),
            style: TextStyle(fontWeight: FontWeight.w300))
      ],
    );
  }
}

class _BottomBackground extends StatelessWidget {
  final Function(double, double) _lerp;

  const _BottomBackground(this._lerp);

  @override
  Widget build(BuildContext context) {
    var item = context.select<UKProvider, Item?>((p) => p.currentItem);
    String url;

    if (item == null || item.artwork.isEmpty) return Container();

    url = item.artwork['thumb'] ?? retrieveOptimalImage(item);

    if (url.isEmpty) return Container();

    return Container(
        //TODO: MONITOR PERFORMANCE OF SHADERMASK, CONSIDER STATIC SWITCH INSTEAD
        height: _lerp(minSize, maxSize),
        width: _lerp(minSize, maxSize),
        child: ShaderMask(
            shaderCallback: (rect) => LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.centerRight,
                        colors: [
                      Color.fromRGBO(0, 0, 0, 0.5),
                      Color.fromRGBO(0, 0, 0, _lerp(0.5, 0.0))
                    ])
                    .createShader(Rect.fromLTRB(0, 0, rect.width, rect.height)),
            blendMode: BlendMode.dstIn,
            child: CachedNetworkImage(imageUrl: url, fit: BoxFit.cover)));
  }
}

class _ChannelControlsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<
            UKProvider,
            Tuple6<AudioStream, List<AudioStream>, VideoStream,
                List<VideoStream>, Subtitle, List<Subtitle>>>(
        selector: (_, p) => Tuple6(
            p.currentAudioStream ?? AudioStream(),
            p.audioStreams,
            p.currentVideoStream ?? VideoStream(),
            p.videoStreams,
            p.currentSubtitle,
            p.subtitles),
        builder: (_, value, __) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAudioStreamsTile(context, value.item1, value.item2),
                _buildVideoStreamsTile(context, value.item3, value.item4),
                _buildSubtitlesTile(context, value.item5, value.item6)
              ]);
        });
  }

  static Widget _buildAudioStreamsTile(
      BuildContext context, AudioStream current, List<AudioStream> streams) {
    return ListTile(
      title: const Text("Audio Stream"),
      subtitle: Text(current.index == -1
          ? "None"
          : "${current.bitrate.toKbps()}kbps ${current.codec?.toUpperCase()}"),
      trailing: DropdownButton<AudioStream>(
        items: streams
            .map<DropdownMenuItem<AudioStream>>((i) => DropdownMenuItem(
                child: Text(i.name ?? i.index.toString()), value: i))
            .toList(),
        value: current,
        onChanged: (current.index != -1 && streams.length > 1)
            ? (newAudioStream) {}
            : null,
      ),
    );
  }

  static Widget _buildVideoStreamsTile(
      BuildContext context, VideoStream current, List<VideoStream> streams) {
    return ListTile(
      title: const Text("Video Stream"),
      subtitle: Text(current.index == -1 ? "None" : "$current"),
      trailing: DropdownButton<VideoStream>(
        items: streams
            .map<DropdownMenuItem<VideoStream>>(
                (i) => DropdownMenuItem(child: Text("$i"), value: i))
            .toList(),
        value: current,
        onChanged: (current.index != -1 && streams.length > 1)
            ? (newVideoStream) {}
            : null,
      ),
    );
  }

  static Widget _buildSubtitlesTile(
      BuildContext context, Subtitle current, List<Subtitle> streams) {
    return ListTile(
        title: const Text("Subtitles"),
        subtitle: Text(current.index == -1 ? "None" : "$current"),
        trailing: DropdownButton<Subtitle>(
          items: streams
              .map<DropdownMenuItem<Subtitle>>((i) => DropdownMenuItem(
                  child: Text(i.index == -1 ? "None" : "$i"), value: i))
              .toList(),
          value: current,
          onChanged: (current.index != -1 && streams.length > 1)
              ? (newSubtitle) {}
              : null,
        ));
  }
}

class _RemoteButtonsLite extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.keyboard_arrow_down),
              onPressed: () {},
            ),
          ],
        )
      ],
    );
  }
}
