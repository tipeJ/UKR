import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';

class PlaylistItem extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const PlaylistItem(this.item, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    String title = item.label.isEmpty ? item.fileUrl : item.label;
    String subtitle = item.year?.toString() ?? item.type;
    return ListTile(
      onTap: onTap,
      title: Text(title, overflow: TextOverflow.ellipsis,),
      subtitle: Text(subtitle)
    );
  }
}
