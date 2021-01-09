import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class FilelistProvider extends ChangeNotifier {
  final String rootPath;
  final Player player;

  List<File>? files;

  FilelistProvider(this.player, {required this.rootPath}) {
    fetchFiles(rootPath);
  }

  void fetchFiles(String path) async {
    ApiProvider.getDirectory(player, path: rootPath, onError: (s) {
      print("ERROR DIRECTORY: $s");
    }, onSuccess: (files) {
      this.files = files;
      notifyListeners();
    });
  }
}
