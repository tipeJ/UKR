import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilelistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !(await context.read<FilelistProvider>().navigateUp());
      },
      child: Selector<FilelistProvider, List<File>?>(
          selector: (_, p) => p.files,
          builder: (_, files, __) {
            if (files == null) {
              return const Center(child: CircularProgressIndicator());
            } else {
              return RefreshIndicator(
                onRefresh: () => context.read<FilelistProvider>().refresh(),
                child: ListView.builder(
                  itemCount: files.length + 1,
                  itemBuilder: (_, i) {
                    return (i == 0)
                        ? Row(children: [
                            Expanded(
                                child: InkWell(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: const Text("//"),
                                    ),
                                    onTap: () => context
                                        .read<FilelistProvider>()
                                        .navigateUp())),
                            IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () =>
                                    context.read<FilelistProvider>().refresh())
                          ])
                        : _FileTile(files[i - 1]);
                  },
                ),
              );
            }
          }),
    );
  }
}

class _FileTile extends StatefulWidget {
  final File file;
  final bool compact;
  const _FileTile(this.file, {this.compact = false});

  @override
  __FileTileState createState() => __FileTileState();
}

class __FileTileState extends State<_FileTile> {
  var _tapPosition;

  void _showCustomMenu() async {
    final overlay = Overlay.of(context)?.context.findRenderObject();

    if (_tapPosition != null && overlay != null && overlay is RenderBox) {
      final r = await showMenu(
          position: RelativeRect.fromRect(
              _tapPosition & const Size(40, 40), Offset.zero & overlay.size),
          context: context,
          items: const ["Play", "Queue"]
              .map<PopupMenuEntry<String>>(
                  (i) => PopupMenuItem(value: i, child: Text(i)))
              .toList());
      switch (r.toString()) {
        case "Play":
          context.read<UKProvider>().openFile(widget.file.file);
          break;
      }
    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.all(widget.compact ? 8.0 : 12.0);
    if (widget.file.fileType == FileType.Directory) {
      return InkWell(
          child: Padding(padding: padding, child: Row(
            children: [
              Icon(Icons.subdirectory_arrow_right),
              Text(widget.file.label),
            ],
          )),
          onTap: () =>
              context.read<FilelistProvider>().navigateDown(widget.file.file));
    } else if (widget.file.fileType == FileType.File) {
      return Listener(
        onPointerDown: (details) {
          // Detect mouse right clicks:
          if (details.kind == PointerDeviceKind.mouse && details.buttons == 2) {
            _tapPosition = details.position;
            _showCustomMenu();
          }
        },
        child: InkWell(
            child: Padding(
              padding: padding,
              child: Text(widget.file.label),
            ),
            onTapDown: _storePosition,
            onLongPress: _showCustomMenu,
            onTap: () => context.read<UKProvider>().openFile(widget.file.file)
          ),
      );
    }
    return const Text("Unknown file type");
  }
}
