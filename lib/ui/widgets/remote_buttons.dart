import 'dart:ui';

import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/main_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RemoteButtons extends StatelessWidget {
  MainProvider _getProvider(BuildContext context) =>
      context.read<MainProvider>();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _RemoteButton(Icons.keyboard_arrow_up, () {}),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(Icons.keyboard_arrow_left, () {}),
            _RemoteButton(Icons.circle, () {}),
            _RemoteButton(Icons.keyboard_arrow_right, () {}),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _RemoteButton(Icons.arrow_back, () {}, 30.0),
            _RemoteButton(Icons.notes_outlined, () {}, 30.0),
            _RemoteButton(Icons.keyboard_arrow_down, () {}),
            _RemoteButton(Icons.info_outline_rounded, () {}, 30.0),
            _RemoteButton(Icons.menu_outlined, () {}, 30.0),
          ],
        )
      ],
    );
  }
}

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
          child: Icon(this.icon, size: this.size)));
  }
}
