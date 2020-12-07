/// * Playlist Item
/// A model for Playlist Items, which are simplified representations of normal Items
class PlaylistItemModel {
  final String type;
  final String label;
  final String fileUrl;

  const PlaylistItemModel({this.type = "", this.label = "", this.fileUrl = ""});

  factory PlaylistItemModel.fromJson(dynamic j) => PlaylistItemModel(
      type: j['type'],
      label: j['label'] == "play" ? "" : j['label'],
      fileUrl: j['file']);

  String getTitle() =>
      [label, fileUrl, "Unknown"].firstWhere((t) => t.isNotEmpty);
}
