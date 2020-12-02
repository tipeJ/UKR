import 'models.dart';

abstract class Item {
  final String type;
  final int duration;
  final String label;
  final Map<String, String> artwork;
  const Item(this.duration, this.label, this.type, this.artwork);

  @override
  bool operator ==(other) =>
      other is Item && other.duration == duration && other.label == label;
}

enum AlbumReleaseType { Album, Single }

class AudioItem extends Item {
  final String albumArtist;
  final AlbumReleaseType releaseType;
  final int disc;

  const AudioItem(duration, label, type, artwork,
      {required this.albumArtist,
      required this.releaseType,
      required this.disc})
      : super(duration, label, type, artwork);

  factory AudioItem.fromJson(dynamic j) =>
    AudioItem(j['duration'], j['label'], j['type'], _castArt(j),
          albumArtist: j['albumartist'],
          releaseType: _getReleaseType(j['releasetype']),
          disc: j['disc']);

  static AlbumReleaseType _getReleaseType(String releaseType) =>
      releaseType == "album" ? AlbumReleaseType.Album : AlbumReleaseType.Single;
}

class VideoItem extends Item {
  final List<String> director;
  final VideoStreams? videoStreams;
  final int? year;

  // * TV Specific
  final int? season;
  final int? episode;
  final String? showTitle;

  const VideoItem(duration, label, type, artwork,
      {required this.director,
      required this.videoStreams,
      this.year,
      this.season,
      this.episode,
      this.showTitle})
      : super(duration, label, type, artwork);

  factory VideoItem.fromJson(dynamic j) =>
    VideoItem(j['duration'], j['label'], j['type'], _castArt(j),
          year: j['year'],
          season: j['season'],
          episode: j['episode'],
          showTitle: j['showtitle'],
          director: j['director'] != null
              ? j['director'].map<String>((d) => d.toString()).toList()
              : const [],
          videoStreams: j['streamdetails'] != null
              ? VideoStreams.fromJson(j['streamdetails'])
              : null);
}

Map<String, String> _castArt(dynamic j) => Map<String, String>.from(j['art']);
