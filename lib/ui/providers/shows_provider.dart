import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/widgets.dart';

class TVShowsProvider extends ChangeNotifier {
  /// How many shows are fetched per fetchMovies call
  static const _span = 30;

  final Player player;
  TVShowsProvider(this.player, {bool initialFetch = false}) {
    if (initialFetch) this.fetchShows();
  }

  List<TVShow> shows = [];
  LoadingState state = LoadingState.Inactive;
  int get _length => shows.length;

  void fetchShows({bool reset = false, String? searchTitle}) async {
    // Do not load new shows while the provider is already loading.
    if (this.state != LoadingState.Active) {
      if (reset) {
        shows = [];
        notifyListeners();
      }
      this.state = LoadingState.Active;
      List<ListFilter> filters = searchTitle != null
          ? ListFilter.comboFields(
              const ["title", "plot", "director", "tag"],
              value: searchTitle)
          : [];
      await ApiProvider.getTVShows(player,
          filters: filters,
          limits: ListLimits(start: _length, end: _length + _span),
          onSuccess: (j) {
            shows += j.map<TVShow>((m) => TVShow.fromJson(m)).toList();
            this.state = LoadingState.Inactive;
            notifyListeners();
          }, onError: (e) => print("ERROR fetching shows: " + e));
    }
  }
}
