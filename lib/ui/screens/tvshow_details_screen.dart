import 'dart:ui';

import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/utils/image_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class TVShowDetailsScreen extends StatelessWidget {
  final Player player;
  final TVShow show;
  const TVShowDetailsScreen({required this.player, required this.show});

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<_TVShowDetailsProvider>(
        create: (_) => _TVShowDetailsProvider(this.player, this.show),
        builder: (_, __) => _TVShowDetailsScreen(),
      );
}

class _TVShowDetailsProvider extends ChangeNotifier {
  final Player player;
  final TVShow show;

  List<TVSeason> seasons = [];
  LoadingState seasonsLoadingState = LoadingState.Inactive;

  _TVShowDetailsProvider(this.player, this.show) {
    refreshSeasons();
  }

  void refreshSeasons() async {
    seasonsLoadingState = LoadingState.Active;
    notifyListeners();
    await ApiProvider.getTVSeasons(player, tvshowID: show.tvshowid,
        onSuccess: (seasons) {
          this.seasons = seasons..sort((f, s) => f.seasonNo.compareTo(s.seasonNo));
          seasonsLoadingState = LoadingState.Inactive;
          notifyListeners();
    });
  }
}

class _TVShowDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String image =
        retrieveOptimalImage(context.watch<_TVShowDetailsProvider>().show);
    return Scaffold(
        body: Stack(
      children: [
        _background(context, image),
        CustomScrollView(
          slivers: [
            SliverAppBar(
                backgroundColor: Colors.transparent,
                title: Selector<_TVShowDetailsProvider, String>(
                  selector: (_, p) => p.show.title,
                  builder: (_, title, __) => Text(title),
                ),
                automaticallyImplyLeading: false),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Selector<_TVShowDetailsProvider, String>(
                  selector: (_, p) => p.show.plot ?? "",
                  builder: (_, plot, __) => Text(plot),
                ),
              ),
            ),
            SliverToBoxAdapter(
                child: Container(child: _horizontalSeasonsView()))
          ],
        ),
      ],
    ));
  }

  Widget _horizontalSeasonsView() => SizedBox(
      height: 350,
      child: Selector<_TVShowDetailsProvider,
          Tuple2<List<TVSeason>, LoadingState>>(
        selector: (_, p) => Tuple2(p.seasons, p.seasonsLoadingState),
        builder: (_, vals, __) {
          switch (vals.item2) {
            case LoadingState.Error:
              return const Text("Error loading seasons!");
            case LoadingState.Active:
              return const Center(child: CircularProgressIndicator());
            default:
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: vals.item1.length,
                itemBuilder: (_, i) => _SeasonPoster(vals.item1[i]),
              );
          }
        },
      ));

  // Blurred image background wrapper.
  Widget _background(BuildContext context, String image) => Container(
        decoration: BoxDecoration(
            image:
                DecorationImage(fit: BoxFit.cover, image: NetworkImage(image))),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.45),
            )),
      );
}

class _SeasonPoster extends StatelessWidget {
  final TVSeason season;

  const _SeasonPoster(this.season);

  @override
  Widget build(BuildContext context) {
    Widget? background = Container(color: Colors.red);
    if (season.artwork.isNotEmpty) {
      String url = retrieveOptimalImage(season);
      if (url.isNotEmpty)
        background = CachedNetworkImage(fit: BoxFit.cover, imageUrl: url);
    }
    return InkWell(
        onTap: () => print("CLICKED: " + season.seasonNo.toString()),
        child: Container(
            height: 350.0,
            child: background));
            // child: Hero(
            //     tag: HERO_CONTENT_MOVIES_POSTER +
            //         "${show.tvshowid} + ${show.year}",
            //     child: background)));
  }
}
