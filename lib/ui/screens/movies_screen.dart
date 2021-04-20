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
                // Detect whether we are closer than 200 pixels to the bottom of the list. If so, fetch more movies from the player.
                if (not.metrics.maxScrollExtent - not.metrics.pixels < 200) {
                  context.read<MoviesProvider>().fetchMovies();
                }
                return false;
              },
              child: GridView.builder(
                  itemCount: movies.length + 1,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: _posterRatio,
                      maxCrossAxisExtent: 150.0),
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
    return InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(ROUTE_CONTENT_VIDEOITEM_DETAILS, arguments: movie),
        child: Container(
            height: 350.0,
            child: Hero(
                tag: HERO_CONTENT_MOVIES_POSTER + movie.fileUrl,
                child: background)));
  }
}
