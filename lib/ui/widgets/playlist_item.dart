import 'package:UKR/models/models.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:UKR/utils/utils.dart';

class PlaylistItem extends StatefulWidget {
  final PlaylistItemModel item;
  final VoidCallback onTap;
  final bool compact;

  const PlaylistItem(this.item, {required this.onTap, this.compact = false});

  @override
  _PlaylistItemState createState() => _PlaylistItemState();
}

class _PlaylistItemState extends State<PlaylistItem> {
  var _tapPosition;

  void _showCustomMenu() async {
    final overlay = Overlay.of(context)?.context.findRenderObject();

    if (_tapPosition != null && overlay != null && overlay is RenderBox) {
      final r = await showMenu(
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40), Offset.zero & overlay.size),
          context: context,
          items: <PopupMenuEntry<String>>[
            PopupMenuItem(value: "Remove", child: Text("Remove"))
          ]);
      if (r.toString() == "Remove") {
        context.read<UKProvider>().removePlaylistItem(widget.item.id);
      }
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    String title =
        widget.item.label.isEmpty ? widget.item.fileUrl : widget.item.label;
    String subtitle = widget.item.type;
    double padding = widget.compact ? 4.0 : 8.0;
    return Listener(
      onPointerDown: (details) {
        // Detect mouse right clicks:
        if (details.kind == PointerDeviceKind.mouse && details.buttons == 2) {
          _tapPosition = details.position;
          _showCustomMenu();
        }
      },
      child: InkWell(
          onTap: widget.onTap,
          onTapDown: _storePosition,
          onLongPress: _showCustomMenu,
          child: Padding(
            padding: EdgeInsets.only(left: padding, bottom: padding, top: padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyText1),
                if (!widget.compact)
                  Text(subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyText2!.apply(
                          color: Theme.of(context).textTheme.caption!.color))
              ],
            ),
          )),
    );
  }
}
