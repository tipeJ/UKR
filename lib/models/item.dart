import 'models.dart';

class Item {
  final String type;
  final int duration;
  final String label;
  final Map<String, String> artwork;
  final String fileUrl;
  final int? year;
  Item(Map<String, dynamic> j)
      : duration = j['duration'],
        year = j['year'] == 1601 ? null : j['year'],
        type = j['type'],
        label = j['label'],
        artwork = _castArt(j),
        fileUrl = j['file'] ?? "";
  @override
  bool operator ==(other) =>
      other is Item && other.duration == duration && other.label == label && other.fileUrl == fileUrl && other.year == year;
}

enum AlbumReleaseType { Album, Single }

class AudioItem extends Item {
  final String albumArtist;
  final AlbumReleaseType releaseType;
  final int disc;

  AudioItem(json,
      {required this.albumArtist,
      required this.releaseType,
      required this.disc})
      : super(json);

  factory AudioItem.fromJson(dynamic j) => AudioItem(j,
      albumArtist: j['albumartist'],
      releaseType: _getReleaseType(j['releasetype']),
      disc: j['disc']);

  static AlbumReleaseType _getReleaseType(String releaseType) =>
      releaseType == "album" ? AlbumReleaseType.Album : AlbumReleaseType.Single;
}

class VideoItem extends Item {
  final List<String> director;
  final VideoStreams? videoStreams;
  final String? plot;

  // * TV Specific
  final int? season;
  final int? episode;
  final String? showTitle;

  VideoItem(json,
      {required this.director,
      required this.videoStreams,
      this.plot,
      this.season,
      this.episode,
      this.showTitle})
      : super(json);

  factory VideoItem.fromJson(dynamic j) => VideoItem(j,
      plot: j['plot'],
      season: j['season'] == -1 ? null : j['season'],
      episode: j['episode'],
      showTitle: j['showtitle'],
      director: j['director'] != null
          ? j['director'].map<String>((d) => d.toString()).toList()
          : const [],
      videoStreams: j['streamdetails'] != null
          ? VideoStreams.fromJson(j['streamdetails'])
          : null);
}

Map<String, String> _castArt(dynamic j) => j['art'] != null ? Map<String, String>.from(j['art']) : const {};
