import 'models.dart';

abstract class Item {
  final int duration;
  final String label;
  const Item(this.duration, this.label);

  @override
  bool operator ==(other) =>
      other is Item && other.duration == duration && other.label == label;
}

enum AlbumReleaseType { Album, Single }

class AudioItem extends Item {
  final String albumArtist;
  final AlbumReleaseType releaseType;
  final int disc;

  const AudioItem(duration, label,
      {required this.albumArtist,
      required this.releaseType,
      required this.disc})
      : super(duration, label);

  factory AudioItem.fromJson(dynamic j) => AudioItem(j['duration'], j['label'],
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
  final String? banner;
  final String? fanart;
  final String? poster;
  final String? thumb;

  const VideoItem(duration, label,
      {required this.director,
      required this.videoStreams,
      this.year,
      this.banner,
      this.fanart,
      this.poster,
      this.thumb})
      : super(duration, label);
  factory VideoItem.fromJson(dynamic j) => VideoItem(j['duration'], j['label'],
      year: j['year'],
      banner: j['art']['banner'],
      fanart: j['art']['fanart'],
      poster: j['art']['poster'],
      thumb: j['art']['thumb'],
      director: j['director'] != null
          ? j['director'].map<String>((d) => d.toString()).toList()
          : const [],
      videoStreams: j['streamdetails'] != null
          ? VideoStreams.fromJson(j['streamdetails'])
          : null);
}
