import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';
import 'package:UKR/utils/utils.dart';

class ContentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(height: 200),
        _ContentTile(
            title: "Addons",
            heroTag: HERO_CONTENT_ADDONS_HEADER,
            iconData: Icons.extension,
            launch: ROUTE_CONTENT_ADDONS)
      ],
    );
  }
}

class _ContentTile extends StatelessWidget {
  final String title;
  /// Include if the title is to be wrapped in a hero widget
  final String? heroTag;
  final String? subtitle;

  /// Which route to push to the nearest navigator
  final String launch;

  /// Icon to be shown as the leading widget.
  final IconData iconData;

  const _ContentTile(
      {required this.title,
      required this.launch,
      required this.iconData,
      this.heroTag,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: heroTag == null ? Text(title) : Hero(tag: heroTag!, child: Text(title)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: Icon(iconData),
        onTap: () => Navigator.of(context).pushNamed(launch));
  }
}
