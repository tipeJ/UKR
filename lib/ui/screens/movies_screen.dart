import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:UKR/resources/resources.dart';

class MoviesScreen extends StatelessWidget {
  static const _posterRatio = 9 / 16.0;
  @override
  Widget build(BuildContext context) {
    return Selector<MoviesProvider, List<VideoItem>>(
        selector: (_, p) => p.movies,
        builder: (_, movies, __) =>
            NotificationListener<ScrollUpdateNotification>(
              onNotification: (not) {
                context.read<MoviesProvider>().fetchMovies();
                return true;
              },
              child: GridView.builder(
                  itemCount: movies.length + 1,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: _posterRatio, maxCrossAxisExtent: 150.0),
                  itemBuilder: (_, i) => i == movies.length
                      ? Container(
                          height: 75,
                          alignment: Alignment.center,
                          child: Selector<MoviesProvider, LoadingState>(
                              selector: (_, p) => p.state,
                              builder: (_, state, __) {
                                switch (state) {
                                  case LoadingState.Active:
                                    return CircularProgressIndicator();
                                  case LoadingState.Error:
                                    return Text("Error loading movies");
                                  default:
                                    // Return an empty container
                                    return Container();
                                }
                              }),
                        )
                      : MovieGridItem(movies[i])),
            ));
  }
}

class MovieGridItem extends StatelessWidget {
  final VoidCallback? onClick;
  final VideoItem movie;

  const MovieGridItem(this.movie, {this.onClick});

  @override
  Widget build(BuildContext context) {
    Widget? background = Container(color: Colors.red);
    if (movie.artwork.isNotEmpty) {
      String url = retrieveOptimalImage(movie);
      if (url.isNotEmpty)
        background = CachedNetworkImage(fit: BoxFit.cover, imageUrl: url);
    }
    return Container(height: 350.0, child: background);
  }
}
