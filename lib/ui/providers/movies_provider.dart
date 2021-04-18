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

  List<VideoItem>? movies;
  int get _length => (movies ?? []).length;

  void fetchMovies() async => ApiProvider.getMovies(player,
          limits: ListLimits(start: _length, end: _length + _span),
          onError: (e) {
        print("ERRR:" + e);
      }, onSuccess: (j) {
        movies = j
            .map<VideoItem>((m) => VideoItem.fromJson(m))
            .toList();
        notifyListeners();
      });
}
