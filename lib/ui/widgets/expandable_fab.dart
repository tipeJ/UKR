import 'package:flutter/material.dart';
import 'dart:math';

@immutable
class ExpandableFab extends StatefulWidget {
  final double distance;
  final List<ExpandableFabButton> children;
  const ExpandableFab({required this.distance, required this.children});

  @override
  _ExpandableFabState createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  static const double _diameter = 56;
  static const _duration = Duration(milliseconds: 250);

  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  // ...

  bool _open = false;

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
        child: Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        _buildTapToCloseFab(),
        ..._buildExpandingActionButtons(),
        _buildTapToOpenFab()
      ],
    ));
  }
  List<Widget> _buildExpandingActionButtons() {
      final children = <Widget>[];
      final count = widget.children.length;
      final step = 90.0 / (count - 1);
      for (var i = 0, angleInDegrees = 0.0;
          i < count;
          i++, angleInDegrees += step) {
        children.add(
          ExpandingActionButton(
            directionInDegrees: angleInDegrees,
            maxDistance: widget.distance,
            progress: _expandAnimation,
            child: Listener(
              onPointerDown: (_) => _toggle(),
              child: widget.children[i]),
          ),
        );
      }
      return children;
  }
  Widget _buildTapToCloseFab() => SizedBox(
        width: _diameter,
        height: _diameter,
        child: Center(
            child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: InkWell(
            onTap: _toggle,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child:
                    Icon(Icons.close, color: Theme.of(context).primaryColor)),
          ),
        )),
      );

  Widget _buildTapToOpenFab() => IgnorePointer(
        ignoring: _open,
        child: AnimatedContainer(
            transformAlignment: Alignment.center,
            transform: Matrix4.diagonal3Values(
                _open ? 0.7 : 1.0, _open ? 0.7 : 1.0, 1.0),
            duration: _duration,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
            child: AnimatedOpacity(
              opacity: _open ? 0.0 : 1.0,
              curve: const Interval(0.25, 1.0, curve: Curves.easeInOut),
              duration: _duration,
              child: FloatingActionButton(
                onPressed: _toggle,
                child: const Icon(Icons.menu),
              ),
            )),
      );
}

@immutable
class ExpandableFabButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;

  const ExpandableFabButton({this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: theme.accentColor,
      child: IconTheme.merge(
          data: theme.accentIconTheme,
          child: IconButton(onPressed: onPressed, icon: icon)),
    );
  }
}

@immutable
class ExpandingActionButton extends StatelessWidget {
  ExpandingActionButton({
    Key? key,
    required this.directionInDegrees,
    required this.maxDistance,
    required this.progress,
    required this.child,
  }) : super(key: key);

  final double directionInDegrees;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (BuildContext context, Widget? child) {
        final offset = Offset.fromDirection(
          directionInDegrees * (pi / 180.0),
          progress.value * maxDistance,
        );
        var math;
        return Positioned(
          right: 4.0 + offset.dx,
          bottom: 4.0 + offset.dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}
