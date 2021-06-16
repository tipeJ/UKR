import 'dart:ui';

import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:UKR/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class SeasonDetailsScreen extends StatelessWidget {
  final Player player;
  final TVSeason show;
  const SeasonDetailsScreen({required this.player, required this.show});

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<_SeasonDetailsProvider>(
        create: (_) => _SeasonDetailsProvider(this.player, this.show),
        builder: (_, __) => _SeasonDetailsScreen(),
      );
}

class _SeasonDetailsProvider extends ChangeNotifier {
  final Player player;
  final TVSeason season;

  List<VideoItem> episodes = [];
  LoadingState state = LoadingState.Inactive;

  _SeasonDetailsProvider(this.player, this.season) {
    refreshEpisodes();
  }

  void refreshEpisodes() async {
    state = LoadingState.Active;
    notifyListeners();
    await ApiProvider.getTVEpisodes(player,
        showID: season.tvshowID,
        season: season.seasonNo, onSuccess: (episodes) {
      this.episodes = episodes
        ..sort((f, s) => (f.episode ?? -1).compareTo((s.episode ?? 0)));
      state = LoadingState.Inactive;
      notifyListeners();
    });
  }
}

class _SeasonDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final season = context.watch<_SeasonDetailsProvider>().season;
    String image = retrieveOptimalImage(season);
    return Scaffold(
        floatingActionButton: ExpandableFab(distance: 112.0, children: [
          // ExpandableFabButton(
          //     onPressed: () =>
          //         context.read<UKProvider>().openFile(item.fileUrl),
          //     icon: const Icon(Icons.play_arrow)),
          ExpandableFabButton(
              onPressed: () => context.read<UKProvider>().addItemsToPlaylist(
                  sources: mediaItemsIntoPlaylist(
                      context.read<_SeasonDetailsProvider>().episodes),
                  type: "file"),
              icon: const Icon(Icons.queue)),
        ]),
        body: Stack(
          children: [
            PosterBackground(image: image),
            CustomScrollView(
              slivers: [
                SliverAppBar(
                    backgroundColor: Colors.transparent,
                    title: Selector<_SeasonDetailsProvider, TVSeason>(
                      selector: (_, p) => p.season,
                      builder: (_, season, __) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(season.title ?? "Unknown Season"),
                          Text(season.showTitle,
                              style: Theme.of(context).textTheme.caption)
                        ],
                      ),
                    ),
                    automaticallyImplyLeading: false),
                _buildEpisodesList(context)
              ],
            ),
          ],
        ));
  }

  Widget _buildEpisodesList(BuildContext context) =>
      Selector<_SeasonDetailsProvider, Tuple2<List<VideoItem>, LoadingState>>(
        selector: (_, p) => Tuple2(p.episodes, p.state),
        builder: (_, params, __) {
          switch (params.item2) {
            case LoadingState.Error:
              return SliverToBoxAdapter(
                  child: const Text("Error loading episodes"));
            case LoadingState.Active:
              return SliverToBoxAdapter(
                  child: const SizedBox(
                      height: 50,
                      child: Center(child: CircularProgressIndicator())));
            default:
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                    (_, i) => ExpansionTile(
                          title: Text(params.item1[i].label),
                          trailing: IconButton(
                              icon: const Icon(Icons.play_arrow),
                              onPressed: () => print("Pressed")),
                          children: _buildEpisodeExpandingContent(
                              context, params.item1[i]),
                        ),
                    childCount: params.item1.length),
              );
          }
        },
      );

  List<Widget> _buildEpisodeExpandingContent(
      BuildContext context, VideoItem item) {
    TextTheme theme = Theme.of(context).textTheme;
    return [
      Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.plot ?? "",
              style: theme.caption,
            ),
            if (item.rating != null) Text.rich(TextSpan(children: [
              TextSpan(
                  text: item.rating?.toStringAsPrecision(3) ?? "",
                  style: theme.subtitle1),
              TextSpan(text: "/10", style: theme.caption)
            ]))
          ],
        ),
      )
    ];
  }
}
