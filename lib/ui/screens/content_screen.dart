import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:UKR/utils/utils.dart';
import 'package:provider/provider.dart';

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
            launch: ROUTE_CONTENT_ADDONS),
        _ContentTile(
          title: "Files",
          heroTag: HERO_CONTENT_FILES_HEADER,
          iconData: Icons.folder_open,
          launch: ROUTE_CONTENT_FILES,
          launchArguments: context.watch<PlayersProvider>().selectedPlayer,
        )
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

  /// Optional launch arguments;
  final dynamic launchArguments;

  /// Icon to be shown as the leading widget.
  final IconData iconData;

  const _ContentTile(
      {required this.title,
      required this.launch,
      required this.iconData,
      this.launchArguments,
      this.heroTag,
      this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: heroTag == null
            ? Text(title)
            : Hero(tag: heroTag!, child: Text(title)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: Icon(iconData),
        onTap: () => Navigator.of(context).pushNamed(launch, arguments: launchArguments));
  }
}
