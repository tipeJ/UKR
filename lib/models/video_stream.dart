import 'models.dart';

class VideoStreams {
  final List<AudioChannel> audioChannels;
  final List<String> subtitles;
  final List<VideoStream> videoChannels;

  const VideoStreams({this.audioChannels = const [], this.subtitles = const [], this.videoChannels = const []});
  factory VideoStreams.fromJson(dynamic j) => VideoStreams(
      audioChannels: j['audio']
          .map<AudioChannel>((aj) => AudioChannel.fromJson(aj))
          .toList(),
      subtitles:
          j['subtitle'].map<String>((sj) => sj['language'].toString()).toList(),
      videoChannels: j['video']
          .map<VideoStream>((vj) => VideoStream.fromJson(vj))
          .toList());
}

class AudioChannel {
  final int channels;
  final String codec;
  final String language;

  const AudioChannel(this.channels, this.codec, this.language);
  factory AudioChannel.fromJson(dynamic j) =>
      AudioChannel(j['channels'], j['codec'], j['language']);
}
