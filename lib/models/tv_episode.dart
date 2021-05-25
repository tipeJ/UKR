import 'package:UKR/models/models.dart';

class TVEpisode extends Item {
  final int tvshowID;
  final int seasonID;
  final int seasonNo;
  final String? title;
  final int userRating;
  final int watchedEpisodes;

  TVEpisode(json,
      {required this.tvshowID,
      required this.seasonID,
      required this.seasonNo,
      this.title,
      this.userRating = 0,
      this.watchedEpisodes = 0})
      : super(json);

  factory TVEpisode.fromJson(dynamic j) => TVEpisode(j,
      tvshowID: j['tvshowid'],
      seasonID: j['seasonid'],
      seasonNo: j['season'],
      title: j['title'],
      userRating: j['userrating'],
      watchedEpisodes: j['watchedepisodes']);
}
