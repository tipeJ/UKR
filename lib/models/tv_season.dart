import 'package:UKR/models/models.dart';

class TVSeason extends Item {
  final int tvshowID;
  final int seasonID;
  final int seasonNo;
  final String? title;
  final String showTitle;
  final int userRating;
  final int watchedEpisodes;

  TVSeason(json,
      {required this.tvshowID,
      required this.seasonID,
      required this.seasonNo,
      required this.showTitle,
      this.title,
      this.userRating = 0,
      this.watchedEpisodes = 0})
      : super(json);

  factory TVSeason.fromJson(dynamic j) => TVSeason(j,
      tvshowID: j['tvshowid'],
      seasonID: j['seasonid'],
      seasonNo: j['season'],
      showTitle: j['showtitle'],
      title: j['title'],
      userRating: j['userrating'],
      watchedEpisodes: j['watchedepisodes']);
}
