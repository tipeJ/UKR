import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RemoteButton(Icons.keyboard_arrow_up, (){}),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(Icons.keyboard_arrow_left, (){}),
            _RemoteButton(Icons.circle, (){}),
            _RemoteButton(Icons.keyboard_arrow_right, (){}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(Icons.arrow_left, (){}),
            _RemoteButton(Icons.arrow_left, (){}),
            _RemoteButton(Icons.keyboard_arrow_down, (){}),
            _RemoteButton(Icons.arrow_left, (){}),
            _RemoteButton(Icons.arrow_left, (){}),
          ],
        )
      ],
    );
  }
}

class _RemoteButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;

  const _RemoteButton(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.all(10.0), child: Icon(this.icon, size: 40.0)));
  }
}
