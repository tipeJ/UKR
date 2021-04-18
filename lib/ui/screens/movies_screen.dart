import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:UKR/resources/resources.dart';

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<MoviesProvider, List<VideoItem>?>(
        selector: (_, p) => p.movies,
        builder: (_, movies, __) => movies == null
            ? const Center(child: CircularProgressIndicator())
            : MovieGridItem(movies[0]));
    // : GridView.builder(
    //     gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //         maxCrossAxisExtent: 150.0),
    //     itemBuilder: (_, i) => MovieGridItem(movies[i])));
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
    return GestureDetector(
      onTap: () async {
        final ur = retrieveOptimalImage(movie);
        final p = Provider.of<PlayersProvider>(context, listen: false).selectedPlayer;
        final z = await ApiProvider.retrieveCachedImageURL(p!, ur);
        print("URL: " + movie.artwork.toString());
      },
      child: Container(
          height: 250.0,
          child: Stack(
            children: [background, Text(movie.label)],
          )),
    );
  }
}
