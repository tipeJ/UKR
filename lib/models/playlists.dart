import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';

class Playlist {
  final Player player;
  int currentPlaylistID;
  List<PlaylistItemModel>? videos;
  List<PlaylistItemModel>? audios;
  List<PlaylistItemModel>? images;

  Playlist(this.player, {this.currentPlaylistID = PLAYLIST_VIDEOS_ID});

  List<PlaylistItemModel>? getPlaylistById(int id) {
    // TODO: Unknown ID error handling
    switch (id) {
      case PLAYLIST_VIDEOS_ID:
        return videos;
      case PLAYLIST_MUSIC_ID:
        return audios;
      case PLAYLIST_PICTURES_ID:
        return images;
    }
  }

  // Get current playlist.
  List<PlaylistItemModel>? get currentPlaylist {
    return getPlaylistById(currentPlaylistID);
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
