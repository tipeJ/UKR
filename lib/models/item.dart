import 'models.dart';

abstract class Item {
  final int duration;
  const Item(this.duration);
}

enum AlbumReleaseType { Album, Single }

class AudioItem extends Item {
  final String albumArtist;
  final AlbumReleaseType releaseType;
  final int disc;

  const AudioItem(duration, {this.albumArtist, this.releaseType, this.disc})
      : super(duration);

  factory AudioItem.fromJson(dynamic j) => AudioItem(j['duration'],
      albumArtist: j['albumartist'],
      releaseType: _getReleaseType(j['releasetype']),
      disc: j['disc']);

  static AlbumReleaseType _getReleaseType(String releaseType) =>
      releaseType == "album" ? AlbumReleaseType.Album : AlbumReleaseType.Single;
}

class VideoItem extends Item {
  final List<String> director;
  final VideoStreams videoStreams;

  const VideoItem(duration, {this.director, this.videoStreams})
      : super(duration);
  factory VideoItem.fromJson(dynamic j) => VideoItem(j['duration'],
      director: j['director'].map<String>((d) => d.toString()).toList(),
      videoStreams: VideoStreams.fromJson(j['streamdetails']));
}
