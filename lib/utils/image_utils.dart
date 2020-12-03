import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';

String decodeExternalImageUrl(String url) =>
    Uri.decodeComponent(url.replaceFirst("image://", ""));

String retrieveOptimalImage(Item item) {
  final a = item.artwork;
  switch (item.type) {
    case "movie":
      return a.getPreferred(const ['poster', 'fanart', 'thumb', 'banner'], "");
    case "episode":
      return a.getPreferred(const [
        'season.poster',
        'tvshow.poster',
        'poster',
        'thumb',
        'fanart',
        'banner'
      ], "");
    default:
      print("type:" + item.type);
      return a.getPreferred(
          const ['poster', 'season.poster', 'fanart', 'thumb', 'banner'], "");
  }
}
