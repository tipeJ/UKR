import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
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
    await ApiProvider.getTVSeasons(player, tvshowID: show.tvshowid,
        onSuccess: (seasons) {
      this.seasons = seasons;
    });
  }
}

class _TVShowDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
          body: CustomScrollView(
        slivers: [
          SliverAppBar(
              title: Selector<_TVShowDetailsProvider, String>(
                selector: (_, p) => p.show.title,
                builder: (_, title, __) => Text(title),
              ),
              automaticallyImplyLeading: false),
          SliverToBoxAdapter(
            child: Selector<_TVShowDetailsProvider, String>(
              selector: (_, p) => p.show.plot ?? "",
              builder: (_, plot, __) => Text(plot),
            ),
          ),
          SliverToBoxAdapter(child: _horizontalSeasonsView())
        ],
      ));

  Widget _horizontalSeasonsView() => SizedBox(
      height: 120,
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
                itemCount: vals.item1.length,
                itemBuilder: (_, i) => Text(vals.item1[i].seasonNo.toString()),
              );
          }
        },
      ));
}
