import 'package:UKR/models/models.dart';
import 'package:provider/provider.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';

const double _posterRatio = 9 / 16.0;

class TVShowsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.of(context).pushNamed(
              ROUTE_CONTENT_MOVIE_SEARCH,
              arguments: context.read<PlayersProvider>().selectedPlayer),
          child: const Icon(Icons.search)),
      // body: Selector<MoviesProvider, List<VideoItem>>(
      //     selector: (_, p) => p.movies,
      //     builder: (_, movies, __) =>
      //         NotificationListener<ScrollUpdateNotification>(
      //           onNotification: (not) {
      //             // Detect whether we are closer than 200 pixels to the bottom of the list. If so, fetch more movies from the player.
      //             if (not.metrics.maxScrollExtent - not.metrics.pixels < 200) {
      //               context.read<MoviesProvider>().fetchMovies();
      //             }
      //             return false;
      //           },
      //           child: GridView.builder(
      //               itemCount: movies.length + 1,
      //               gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      //                   childAspectRatio: _posterRatio,
      //                   maxCrossAxisExtent: 150.0),
      //               itemBuilder: (_, i) => i == movies.length
      //                   ? Container(
      //                       height: 75,
      //                       alignment: Alignment.center,
      //                       child: Selector<MoviesProvider, LoadingState>(
      //                           selector: (_, p) => p.state,
      //                           builder: (_, state, __) {
      //                             switch (state) {
      //                               case LoadingState.Active:
      //                                 return CircularProgressIndicator();
      //                               case LoadingState.Error:
      //                                 return Text("Error loading movies");
      //                               default:
      //                                 // Return an empty container
      //                                 return Container();
      //                             }
      //                           }),
      //                     )
      //                   : MovieGridItem(movies[i])),
      //         )),
      body: Selector<TVShowsProvider, List<TVShow>>(
        selector: (_, p) => p.shows,
        builder: (_, ct, __) => ListView.builder(
          itemCount: ct.length,
          itemBuilder: (_, i) => Text(ct[i].label),
        ),
      )
    );
  }
}
