import 'package:UKR/models/models.dart';
import 'package:flutter/material.dart';

class TVShowDetailsScreen extends StatelessWidget {
  final TVShow show;

  const TVShowDetailsScreen(this.show);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(show.title)),
    body: Text(show.plot ?? ""),
  );
}
