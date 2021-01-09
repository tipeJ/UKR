import 'package:UKR/models/models.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FilelistScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<FilelistProvider, List<File>?>(
        selector: (_, p) => p.files,
        builder: (_, files, __) {
          if (files == null) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return ListView.builder(
              itemCount: files.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return const Text("//");
                return Text(files[i - 1].label);
              },
            );
          }
        });
  }
}
