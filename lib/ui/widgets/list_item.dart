import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const ListItem(this.item, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(item.type),
      subtitle: item.year == null ? Container() : Text(item.year.toString()),
    );
  }
}
