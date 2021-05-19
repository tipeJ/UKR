import 'dart:async';

import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';


class TVShowsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
              ROUTE_CONTENT_SHOW_SEARCH,
              arguments: context.read<PlayersProvider>().selectedPlayer),
          child: const Icon(Icons.search)),
      body: Selector<TVShowsProvider, List<TVShow>>(
        selector: (_, p) => p.shows,
        builder: (_, shows, __) => NotificationListener<ScrollUpdateNotification>(
                onNotification: (not) {
                  // Detect whether we are closer than 200 pixels to the bottom of the list. If so, fetch more movies from the player.
                  if (not.metrics.maxScrollExtent - not.metrics.pixels < 200) {
                    context.read<TVShowsProvider>().fetchShows();
                  }
                  return false;
                },
                child: GridView.builder(
                  itemCount: shows.length + 1,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: listPosterRatio,
                    maxCrossAxisExtent: gridPosterMaxWidth
                  ),
                  itemBuilder: (_, i) => i == shows.length
                        ? Container(
                            height: 75,
                            alignment: Alignment.center,
                            child: Selector<TVShowsProvider, LoadingState>(
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
                          : ShowGridItem(shows[i])
                )
        ),
        ),
    );
  }
}
class TVShowsSearchScreen extends StatefulWidget {
  @override
  _TVShowsSearchScreenState createState() => _TVShowsSearchScreenState();
}

class _TVShowsSearchScreenState extends State<TVShowsSearchScreen> {
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
        .read<TVShowsProvider>()
        .fetchShows(reset: true, searchTitle: _controller.text);
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
      body: Selector<TVShowsProvider, List<TVShow>>(
          selector: (_, p) => p.shows,
          builder: (_, shows, __) =>
              NotificationListener<ScrollUpdateNotification>(
                onNotification: (not) {
                  // Detect whether we are closer than 200 pixels to the bottom of the list. If so, fetch more movies from the player.
                  if (not.metrics.maxScrollExtent - not.metrics.pixels < 200) {
                    _timer?.cancel();
                    context.read<TVShowsProvider>().fetchShows(searchTitle: _controller.text);
                  }
                  return false;
                },
                child: GridView.builder(
                    itemCount: shows.length + 1,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        childAspectRatio: listPosterRatio,
                        maxCrossAxisExtent: gridPosterMaxWidth),
                    itemBuilder: (_, i) => i == shows.length
                        ? Container(
                            height: 75,
                            alignment: Alignment.center,
                            child: Selector<TVShowsProvider, LoadingState>(
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
                        : ShowGridItem(shows[i])),
              )),
    );
  }
}

class ShowGridItem extends StatelessWidget {
  final VoidCallback? onClick;
  final TVShow show;

  const ShowGridItem(this.show, {this.onClick});

  @override
  Widget build(BuildContext context) {
    Widget? background = Container(color: Colors.red);
    if (show.artwork.isNotEmpty) {
      String url = retrieveOptimalImage(show);
      if (url.isNotEmpty) background = CachedNetworkImage(fit: BoxFit.cover, imageUrl: url);
    }
    return InkWell(
        onTap: () => Navigator.of(context)
            .pushNamed(ROUTE_CONTENT_TVSHOW_DETAILS, arguments: show),
        child: Container(
            height: 350.0,
            child: Hero(
                tag: HERO_CONTENT_MOVIES_POSTER + "${show.tvshowid} + ${show.year}",
                child: background)));
  }
}
