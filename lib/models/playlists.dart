import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';

class Playlist {
  final Player player;
  List<PlaylistItemModel>? videos;
  List<PlaylistItemModel>? audios;
  List<PlaylistItemModel>? images;

  Playlist(this.player);

  List<PlaylistItemModel>? getPlaylistById(int id) {
    switch (id) {
      case PLAYLIST_VIDEOS_ID:
        return videos;
      case PLAYLIST_MUSIC_ID:
        return audios;
      case PLAYLIST_PICTURES_ID:
        return images;
    }
  }

  // Refresh playlist
  Future<void> refreshPlaylist({id: int}) async {
    var list = getPlaylistById(id);
    list = await ApiProvider.getPlayList(this.player, id: id);
  }

  // Add item to playlist
  void addItemToPlaylist(PlaylistItemModel item, int playlist) {
    var list = getPlaylistById(playlist);
    list?.add(item);
  }
}
