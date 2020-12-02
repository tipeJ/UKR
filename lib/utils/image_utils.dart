import 'package:UKR/models/models.dart';

String decodeExternalImageUrl(String url) =>
    Uri.decodeComponent(url.replaceFirst("image://", ""));

String retrieveOptimalImage(Item item) {
  final a = item.artwork;
  switch (item.type) {
    case "movie":
      return a['poster'] ?? a['fanart'] ?? a['thumb'] ?? a['banner'] ?? "";
    case "episode":
      return a['season.poster'] ?? a['tvshow.poser'] ?? a['poster'] ?? a['thumb'] ?? a['fanart'] ?? a['banner'] ?? "";
    default:
      print("type:" + item.type);
      return "";
  }
}
