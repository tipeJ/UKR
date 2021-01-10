import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class FilelistProvider extends ChangeNotifier {
  final String rootPath;
  final Player player;

  List<File>? files;
  List<String> _paths = [];

  FilelistProvider(this.player, {required this.rootPath}) {
    navigateDown(rootPath);
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
  void navigateDown(String path) {
    _paths.add(path);
    _fetchFiles(path);
  }

  /// Navigate up in the tree. Does not go above root directory. Returns a boolean value, indicating the success of the operation.
  Future<bool> navigateUp() async {
    // Required to prevent unwanted route pops
    if (files == null) return true;

    if (_paths.length > 1) {
      _paths.removeLast();
      await _fetchFiles(_paths.last);
      return true;
    }
    return false;
  }
}
