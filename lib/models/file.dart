import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';

class File {
  final String file;
  final FileType fileType;
  final String type;
  final String label;

  const File(
      {required this.file,
      required this.fileType,
      required this.type,
      required this.label});

  factory File.fromJson(dynamic j) => File(
      file: j['file'],
      fileType: enumFromString(FileType.values, j['filetype']),
      type: j['type'],
      label: (j['label'] as String).replaceInside('[', ']').replaceAll("Â¤", "").trim()
    );

  @override
  String toString() => label;
}

enum FileType { Directory, File }
