import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
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
                        Expanded(child: InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: const Text("//"),
                            ),
                            onTap: () => context.read<FilelistProvider>().navigateUp())
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () => context.read<FilelistProvider>().refresh())
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

class _FileTile extends StatelessWidget {
  final File file;
  const _FileTile(this.file);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(file.label),
        onTap: () {
          if (file.fileType == FileType.Directory) {
            context.read<FilelistProvider>().navigateDown(file.file);
          } else if (file.fileType == FileType.File) {
            context.read<UKProvider>().openFile(file.file);
          }
        });
  }
}
