import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';

String decodeExternalImageUrl(String url) {
  String component = Uri.decodeComponent(url.replaceFirst("image://", ""));
  // If the image has a trailing slash after file type, remove it
  if (component.endsWith("/")) {
    component = component.substring(0, component.length - 1);
  }
  return component;
}

const movieArtPriority = ['poster', 'fanart', 'thumb', 'banner'];
String retrieveOptimalImage(Item item) {
  final a = item.artwork;
  switch (item.type) {
    case "movie":
      return a.getPreferred(movieArtPriority, "");
    case "season":
    case "tvshow":
      return a.getPreferred(const ['poster', 'fanart', 'banner', 'icon'], "");
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
      if (item is VideoItem) {
        return a.getPreferred(
            const ['poster', 'season.poster', 'thumb', 'fanart', 'banner'], "");
      } else {
        return a.getPreferred(
            const ['poster', 'season.poster', 'fanart', 'thumb', 'banner'], "");
      }
  }
}
