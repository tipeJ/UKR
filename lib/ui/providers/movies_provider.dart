import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/widgets.dart';

class MoviesProvider extends ChangeNotifier {
  /// How many movies are fetched per fetchMovies call
  static const _span = 30;

  final Player player;
  MoviesProvider(this.player) {
    fetchMovies();
  }

  List<VideoItem> movies = [];
  LoadingState state = LoadingState.Inactive;
  int get _length => movies.length;

  void fetchMovies({bool reset = false, String? searchTitle}) async {
    // Do not load new movies while the provider is already loading.
    if (this.state != LoadingState.Active) {
      if (reset) {
        movies = [];
        notifyListeners();
      }
      this.state = LoadingState.Active;
      List<ListFilter> filters = searchTitle != null
          ? ListFilter.comboFields(const ["title", "plot", "tagline", "director"], value: searchTitle)
          : [];
      await ApiProvider.getMovies(player,
          limits: ListLimits(start: _length, end: _length + _span),
          filters: filters, onError: (e) {
        print("ERRR:" + e);
        this.state = LoadingState.Error;
      }, onSuccess: (j) {
        movies += j.map<VideoItem>((m) => VideoItem.fromJson(m)).toList();
        this.state = LoadingState.Inactive;
        notifyListeners();
      });
    }
  }
}
