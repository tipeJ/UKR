import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<MoviesProvider, List<VideoItem>?>(
        selector: (_, p) => p.movies,
        builder: (_, movies, __) => movies == null
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150.0),
                itemBuilder: (_, i) => MovieGridItem(movies[i])));
  }
}

class MovieGridItem extends StatelessWidget {
  final VoidCallback? onClick;
  final VideoItem movie;

  const MovieGridItem(this.movie, {this.onClick});

  @override
  Widget build(BuildContext context) {
    return Column(children: [Text(movie.label), Text(movie.year.toString())]);
  }
}
