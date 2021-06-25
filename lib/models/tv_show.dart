import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';

class TVShow extends Item{
  final String file;
  final String title;
  final String label;
  final String studio;
  final int tvshowid;
  final int? year;
  final String? plot;
  final double? rating;
  Map<String, String> cast;

  TVShow(
      json,
      {required this.file,
      required this.title,
      required this.label,
      required this.studio,
      this.tvshowid = -1,
      this.year,
      this.plot,
      this.rating,
      this.cast = const {},
      }) : super(json);

  factory TVShow.fromJson(dynamic j) => TVShow(
      j,
      file: j['file'],
      title: j['title'],
      plot: (j['plot'] as String).nullIfEmpty()?.replaceAll('â', ""),
      label: j['label'],
      studio: j['studio'].toString(),
      tvshowid: j['tvshowid'],
      year: j['year'],
      rating: j['rating'],
      cast: parseCast(j['cast']));
}
