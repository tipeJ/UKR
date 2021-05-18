import 'package:UKR/utils/utils.dart';

class TVShow {
  final String file;
  final String title;
  final String label;
  final String studio;
  final int tvshowid;
  final int? year;
  final String? plot;
  final double? rating;
  final Map<String, String> artwork;
  final Map<String, String> cast;

  const TVShow(
      {required this.file,
      required this.title,
      required this.label,
      required this.studio,
      this.tvshowid = -1,
      this.year,
      this.plot,
      this.rating,
      this.cast = const {},
      this.artwork = const {}});

  factory TVShow.fromJson(dynamic j) => TVShow(
      file: j['file'],
      title: j['title'],
      plot: (j['plot'] as String).nullIfEmpty()?.replaceAll('â', ""),
      label: j['label'],
      studio: j['studio'].toString(),
      tvshowid: j['tvshowid'],
      year: j['year'],
      rating: j['rating'],
      artwork: j['art'] != null ? Map<String, String>.from(j['art']) : const {},
      cast: parseCast(j['cast']));
}
