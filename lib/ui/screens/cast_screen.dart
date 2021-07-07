
import 'package:UKR/models/models.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CastScreen extends StatelessWidget {
  final List<Map<String, String>> cast;
  const CastScreen(this.cast);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: cast.length,
        itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: CastItem(
                name: cast[i]['name'] ?? "Unknown",
                role: cast[i]['role'] ?? "Unknown")));
  }
}
