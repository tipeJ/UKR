import 'package:flutter/material.dart';

class CastItem extends StatelessWidget {
  final String name;
  final String role;

  const CastItem({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: Theme.of(context).textTheme.bodyText1),
        Text(role, style: Theme.of(context).textTheme.caption),
      ]),
    );
  }
}

// Cast item with thumbnail image.
class CastItemWithThumbnail extends StatelessWidget {
  final String name;
  final String role;
  final String thumbnailUrl;

  const CastItemWithThumbnail(
      {required this.name, required this.role, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: Image.network(thumbnailUrl,
              width: 50.0, height: 50.0, fit: BoxFit.cover),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: Theme.of(context).textTheme.bodyText1),
            Text(role, style: Theme.of(context).textTheme.caption),
          ]),
        ),
      ]),
    );
  }
}
