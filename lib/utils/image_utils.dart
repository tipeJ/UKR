import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';

String decodeExternalImageUrl(String url) =>
    Uri.decodeComponent(url.replaceFirst("image://", ""));

const movieArtPriority = ['poster', 'fanart', 'thumb', 'banner'];
String retrieveOptimalImage(Item item) {
  final a = item.artwork;
  switch (item.type) {
    case "movie":
      return a.getPreferred(movieArtPriority, "");
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
      if (item is VideoItem){
        return a.getPreferred(
              const ['poster', 'season.poster', 'thumb', 'fanart', 'banner'], "");
      } else {
        return a.getPreferred(
              const ['poster', 'season.poster', 'fanart', 'thumb', 'banner'], "");
      }
  }
}
