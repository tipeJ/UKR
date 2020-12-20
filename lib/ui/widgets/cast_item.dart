import 'package:flutter/material.dart';

class CastItem extends StatelessWidget {
  final String name;
  final String role;

  const CastItem({required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: Theme.of(context).textTheme.bodyText1),
          Text(role, style: Theme.of(context).textTheme.caption),
        ]
      ),
    );
  }
}
