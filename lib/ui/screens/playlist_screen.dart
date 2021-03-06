import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:UKR/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart' as roList;

class PlaylistScreen extends StatelessWidget {
  int _indexOf(Key key, List<PlaylistItemModel> list) =>
      list.indexWhere((i) => i.id == key);

  @override
  Widget build(BuildContext context) {
    return Selector<UKProvider, List<PlaylistItemModel>>(
        selector: (_, p) => p.playList.toList(),
        builder: (_, playList, __) {
          return playList.isEmpty ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.playlist_play_rounded, size: 56.0),
              Text("Playlist is Empty", style: TextStyle(color: Colors.grey))
            ],
          ) : roList.ReorderableList(
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
                context.read<UKProvider>().syncMovePlaylistItem(newIndex);
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
        });
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
            opacity: state == roList.ReorderableItemState.placeholder ? 0.0 : 1.0,
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
