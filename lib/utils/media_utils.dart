import 'package:UKR/models/models.dart';

List<String> mediaItemsIntoPlaylist(List<MediaItem> items) {
  return items.map<String>((i) => i.fileUrl).toList();
}
