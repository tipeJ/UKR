import 'package:UKR/utils/utils.dart';

class Addon {
  final String addonID;
  final String type;
  final String name;
  final String? description;
  final String? disclaimer;

  /// Thumbnail for the addon
  final String? thumbnail;

  const Addon(
      {required this.addonID,
      required this.type,
      required this.name,
      this.description,
      this.disclaimer,
      this.thumbnail});

  factory Addon.fromJson(dynamic j) => Addon(
      name: (j['name'] as String).replaceInside('[', ']'),
      addonID: j['addonid'],
      type: j['type'],
      description: j['description'],
      disclaimer: j['disclaimer'],
      thumbnail: j['thumbnail']);

  @override
  String toString() {
    return this.name.capitalize();
  }
}
