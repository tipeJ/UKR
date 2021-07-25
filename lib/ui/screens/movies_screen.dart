import 'dart:async';

import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:UKR/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:UKR/resources/resources.dart';

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
              ROUTE_CONTENT_MOVIE_SEARCH,
              arguments: context.read<PlayersProvider>().selectedPlayer),
          child: const Icon(Icons.search)),
      body: Selector<MoviesProvider, List<VideoItem>>(
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
                        childAspectRatio: listPosterRatio,
                        maxCrossAxisExtent: gridPosterMaxWidth),
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
              )),
    );
  }
}

class MoviesSearchScreen extends StatefulWidget {
  @override
  _MoviesSearchScreenState createState() => _MoviesSearchScreenState();
}

class _MoviesSearchScreenState extends State<MoviesSearchScreen> {
  static const _searchDelay = Duration(milliseconds: 750);

  late final TextEditingController _controller;
  // Controls the search functinoality. Stars over again when user types on the search field. The function will be triggered when there hasn't been new input within the delay duration.
  Timer? _timer;

  @override
  void initState() {
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _refresh() {
    context
        .read<MoviesProvider>()
        .fetchMovies(reset: true, searchTitle: _controller.text);
    _timer = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: TextField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: "Search movies",
                focusedBorder: InputBorder.none,
                border: InputBorder.none),
            onChanged: (searchTerm) {
              _timer?.cancel();
              _timer = new Timer(_searchDelay, _refresh);
            }),
      ),
      body: Selector<MoviesProvider, List<VideoItem>>(
          selector: (_, p) => p.movies,
          builder: (_, movies, __) =>
              NotificationListener<ScrollUpdateNotification>(
                onNotification: (not) {
                  // Detect whether we are closer than 200 pixels to the bottom of the list. If so, fetch more movies from the player.
                  if (not.metrics.maxScrollExtent - not.metrics.pixels < 200) {
                    _timer?.cancel();
                    context
                        .read<MoviesProvider>()
                        .fetchMovies(searchTitle: _controller.text);
                  }
                  return false;
                },
                child: GridView.builder(
                    itemCount: movies.length + 1,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: listPosterRatio,
                        maxCrossAxisExtent: gridPosterMaxWidth),
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
              )),
    );
  }
}

class MovieGridItem extends StatelessWidget {
  final VideoItem movie;

  const MovieGridItem(this.movie);

  @override
  Widget build(BuildContext context) {
    Widget? background = Container(color: Colors.red);
    if (movie.artwork.isNotEmpty) {
      String url = retrieveOptimalImage(movie);
      if (url.isNotEmpty)
        background = CachedNetworkImage(fit: BoxFit.cover, imageUrl: url);
    }
    return InkWell(
        onTap: () => showModalBottomSheet(
            context: context,
            builder: (context) => _MovieDetailsSheet(this.movie)),
        child: Container(
            height: 350.0,
            child: Hero(
                tag: HERO_CONTENT_MOVIES_POSTER + movie.fileUrl,
                child: background)));
  }
}

class _MovieDetailsSheet extends StatelessWidget {
  final VideoItem movie;

  const _MovieDetailsSheet(this.movie);

  @override
  Widget build(BuildContext context) {
    String poster = retrieveOptimalImage(movie);
    TextTheme theme = Theme.of(context).textTheme;
    double imageHeight = 50 * (16.0 / 9.0);
    return Container(
        padding: const EdgeInsets.all(5.0),
        height: imageHeight + 45.0,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (poster.isNotEmpty)
              Container(
                width: 50,
                height: imageHeight,
                child: CachedNetworkImage(imageUrl: poster, fit: BoxFit.cover),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(movie.label, minFontSize: 18.0, maxFontSize: 25.0),
                      if (movie.tagline != null)
                        Text(movie.tagline!,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: theme.caption),
                      SizedBox(height: 5.0),
                      Text.rich(TextSpan(children: [
                        if (movie.year != null)
                          TextSpan(text: movie.year.toString(), style: theme.bodyText1),
                        if (movie.rating != null && movie.rating! > 0)
                          TextSpan(children: [
                            TextSpan(
                                text: "  " + movie.rating!.toStringAsFixed(2),
                                style: theme.caption),
                            TextSpan(
                                text: "/10", style: theme.bodyText2)
                          ]),
                      ]))
                    ]),
              ),
            )
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            children: [
              TextButton(
                child: Text("Details"),
                onPressed: () => Navigator.of(context).pushNamed(
                    ROUTE_CONTENT_VIDEOITEM_DETAILS,
                    arguments: movie),
              ),
              TextButton(
                child: Text("Play"),
                onPressed: () => print("Play ${movie.label}"),
              )
            ],
          )
        ]));
  }
}
