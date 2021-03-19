import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/widgets.dart';

class MoviesProvider extends ChangeNotifier {
  final Player player;
  MoviesProvider(this.player) {
    fetchMovies();
  }

  List<VideoItem>? movies;
  void fetchMovies() async => ApiProvider.getMovies(player, onError: (e) {
        print("ERRR:" + e);
      }, onSuccess: (j) {
        print(j['result']['movies'][0].toString());
        movies = j['result']['movies'].map<VideoItem>((m) => VideoItem.fromJson(m)).toList();
        notifyListeners();
      });
}
