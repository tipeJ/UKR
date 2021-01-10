import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class FilelistProvider extends ChangeNotifier {
  final String rootPath;
  final String title;
  final Player player;

  List<File>? files;
  List<File> paths = [];

  FilelistProvider(this.player, {required this.title, required this.rootPath}) {
    navigateDown(File(
        file: rootPath,
        label: rootPath,
        fileType: FileType.Directory,
        type: "unknown"));
  }

  /// Retrieves the tree from the host player.
  Future<void> _fetchFiles(String path) async {
    files = null;
    notifyListeners();
    ApiProvider.getDirectory(player, path: path, onError: (s) {
      print("ERROR DIRECTORY: $s");
    }, onSuccess: (files) {
      this.files = files;
      notifyListeners();
    });
  }

  /// Navigate down in the tree.
  void navigateDown(File path) {
    paths.add(path);
    _fetchFiles(path.file);
  }

  /// Navigate up in the tree. Does not go above root directory. Returns a boolean value, indicating the success of the operation.
  Future<bool> navigateUp() async {
    // Required to prevent unwanted route pops
    if (files == null) return true;

    if (paths.length > 1) {
      paths.removeLast();
      await _fetchFiles(paths.last.file);
      return true;
    }
    return false;
  }

  Future<void> refresh() => _fetchFiles(paths.last.file);
}
