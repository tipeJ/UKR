import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteButtons extends StatelessWidget {
  void _executeAction(BuildContext context, String action) =>
      context.read<ApplicationProvider>().navigate(action);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RemoteButton(
            Icons.keyboard_arrow_up, () => _executeAction(context, "up")),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(Icons.keyboard_arrow_left,
                () => _executeAction(context, "left")),
            _RemoteButton(
                Icons.trip_origin, () => _executeAction(context, "select")),
            _RemoteButton(Icons.keyboard_arrow_right,
                () => _executeAction(context, "right")),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(
                Icons.arrow_back, () => _executeAction(context, "back"), 30.0),
            _RemoteButton(Icons.notes_outlined,
                () => _executeAction(context, "left"), 30.0),
            _RemoteButton(Icons.keyboard_arrow_down,
                () => _executeAction(context, "down")),
            _RemoteButton(Icons.info_outline_rounded,
                () => _executeAction(context, "info"), 30.0),
            _RemoteButton(Icons.menu_outlined,
                () => _executeAction(context, "contextmenu"), 30.0),
          ],
        )
      ],
    );
  }
}

const _iconColor = Colors.white70;

class _RemoteButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final double size;

  const _RemoteButton(this.icon, this.onTap, [this.size = 45.0]);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Container(
            alignment: Alignment.center,
            width: 50.0,
            height: 50.0,
            child: Icon(this.icon, color: _iconColor, size: this.size)));
  }
}