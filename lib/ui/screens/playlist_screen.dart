import 'package:UKR/models/models.dart';
import 'package:UKR/resources/constants.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:UKR/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart'
    as roList;

class PlaylistsScreen extends StatefulWidget {
  @override
  _PlaylistsScreenState createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  int _selectedPlaylistID = PLAYLIST_VIDEOS_ID;

  void changePlaylist(int playlistID) {
    setState(() {
      _selectedPlaylistID = playlistID;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: BottomAppBar(
            child: Container(
                height: 50.0,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.movie_sharp,
                            color: _selectedPlaylistID == PLAYLIST_VIDEOS_ID
                                ? Colors.white
                                : Colors.grey),
                        tooltip: "Videos",
                        onPressed: () => changePlaylist(PLAYLIST_VIDEOS_ID),
                      ),
                      IconButton(
                        icon: Icon(Icons.headphones,
                            color: _selectedPlaylistID == PLAYLIST_MUSIC_ID
                                ? Colors.white
                                : Colors.grey),
                        tooltip: "Audio",
                        onPressed: () => changePlaylist(PLAYLIST_MUSIC_ID),
                      ),
                      IconButton(
                        icon: Icon(Icons.photo_album,
                            color: _selectedPlaylistID == PLAYLIST_PICTURES_ID
                                ? Colors.white
                                : Colors.grey),
                        tooltip: "Images",
                        onPressed: () => changePlaylist(PLAYLIST_PICTURES_ID),
                      )
                    ]))),
        body: Selector<UKProvider, Playlist?>(
            selector: (context, provider) => provider.playlist,
            builder: (_, playlist, __) {
              if (playlist == null) {
                return Center(
                  child: Text("No Player Selected."),
                );
              }
              return PlaylistScreen(
                playList: playlist.getPlaylistById(_selectedPlaylistID) ?? [],
                playlistId: _selectedPlaylistID,
              );
            }));
  }
}

class PlaylistScreen extends StatelessWidget {
  final List<PlaylistItemModel> playList;
  final int playlistId;

  const PlaylistScreen({required this.playList, required this.playlistId});

  int _indexOf(Key key, List<PlaylistItemModel> list) =>
      list.indexWhere((i) => i.id == key);

  @override
  Widget build(BuildContext context) {
    return playList.isEmpty
        ? Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Icon(Icons.playlist_play_rounded, size: 56.0),
                Text("Playlist is Empty", style: TextStyle(color: Colors.grey))
              ],
            ))
        : roList.ReorderableList(
            onReorder: (from, to) {
              int draggingIndex = _indexOf(from, playList);
              int newPositionIndex = _indexOf(to, playList);
              context
                  .read<UKProvider>()
                  .movePlaylistItem(draggingIndex, newPositionIndex);
              return true;
            },
            onReorderDone: (item) {
              int newIndex = _indexOf(item, playList);
              context
                  .read<UKProvider>()
                  .syncMovePlaylistItem(newIndex, id: playlistId);
            },
            child: ListView.builder(
                itemCount: playList.length,
                itemBuilder: (_, i) => _ReorderablePlaylistItem(
                    data: playList[i],
                    onTap: () {
                      context.read<UKProvider>().goto(i);
                    },
                    isFirst: i == 0,
                    isLast: i == playList.length - 1)));
  }
}

class _ReorderablePlaylistItem extends StatelessWidget {
  const _ReorderablePlaylistItem({
    required this.data,
    required this.onTap,
    required this.isFirst,
    required this.isLast,
  });

  final PlaylistItemModel data;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  Widget _buildChild(BuildContext context, roList.ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == roList.ReorderableItemState.dragProxy ||
        state == roList.ReorderableItemState.dragProxyFinished) {
      // slightly transparent background white dragging (just like on iOS)
      decoration = const BoxDecoration(color: Color(0x55000000));
    } else {
      bool placeholder = state == roList.ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.transparent);
    }

    // For iOS dragging mode, there will be drag handle on the right that triggers
    // reordering; For android mode it will be just an empty container
    Widget dragHandle = roList.ReorderableListener(
      child: Container(
        padding: const EdgeInsets.only(right: 18.0, left: 18.0),
        color: Color(0x08000000),
        child: Center(
          child: const Icon(Icons.reorder, color: Color(0xFF888888)),
        ),
      ),
    );

    Widget content = Container(
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            // hide content for placeholder
            opacity:
                state == roList.ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                      child: PlaylistItem(data,
                          compact: isDesktop(), onTap: onTap)),
                  // Triggers the reordering
                  dragHandle,
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return roList.ReorderableItem(
        key: data.id, //
        childBuilder: _buildChild);
  }
}
