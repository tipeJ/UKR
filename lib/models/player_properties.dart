import 'package:UKR/utils/utils.dart';

class PlayerProperties {
  final PlayerTime time;
  final PlayerTime totalTime;
  final int speed;
  final String type;
  final bool canSeek;

  final List<VideoStream> videoStreams;
  final VideoStream currentVideoStream;

  final Repeat repeat;

  bool get playing => speed > 0;

  const PlayerProperties(
      {this.time = const PlayerTime(0, 0, 0),
      this.totalTime = const PlayerTime(0, 0, 0),
      this.type = "Null",
      this.speed = 0,
      this.canSeek = false,
      this.repeat = Repeat.Off,
      this.videoStreams = const [],
      this.currentVideoStream = const VideoStream()});

  factory PlayerProperties.fromJson(dynamic j) => PlayerProperties(
      time: PlayerTime.fromJson(j['time']),
      totalTime: PlayerTime.fromJson(j['totaltime']),
      type: j['type'],
      speed: j['speed'],
      canSeek: j['canseek'],
      repeat: enumFromString(Repeat.values, j['repeat']),
      currentVideoStream: VideoStream.fromJson(j['currentvideostream']),
      videoStreams: j['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList());
}

T enumFromString<T>(Iterable<T> values, String value) => values.firstWhere(
    (type) => type.toString().split('.').last.toLowerCase() == value,
    orElse: null);
enum Repeat { Off, One, All }

class PlayerTime {
  final int hours;
  final int minutes;
  final int seconds;

  /// Returns the time in seconds
  int get inSeconds => (hours * 3600) + (minutes * 60) + seconds;

  /// Returns a new PlayerTime, with time adjusted according to the number of seconds as set by the variable [seconds]
  PlayerTime increment(int seconds) {
    int newSeconds = this.seconds + seconds;
    int newMinutes = this.minutes;
    int newHours = this.hours;
    if (newMinutes == 0 && newHours == 0 && newSeconds < 0) {
      return PlayerTime.empty();
    } else {
      newMinutes += (newSeconds / 60).floor();
      newSeconds = newSeconds % 60;

      if (newMinutes > 59) {
        newHours += (newMinutes / 60).floor();
        newMinutes = newMinutes % 60;
      }
      return PlayerTime(newSeconds, newMinutes, newHours);
    }
  }

  @override
  operator ==(other) =>
      (other is PlayerTime) &&
      other.seconds == seconds &&
      other.minutes == minutes &&
      other.hours == hours;

  Map<String, int> toJson() =>
      {"hours": hours, "minutes": minutes, "seconds": seconds};
  @override
  String toString() => [
        hours > 9 ? hours.toString() : "0$hours",
        minutes > 9 ? minutes.toString() : "0$minutes",
        seconds > 9 ? seconds.toString() : "0$seconds"
      ].join(":");

  const PlayerTime(this.seconds, this.minutes, this.hours);

  factory PlayerTime.empty() => const PlayerTime(0, 0, 0);
  factory PlayerTime.fromJson(dynamic j) => j == null
      ? PlayerTime(0, 0, 0)
      : PlayerTime(j['seconds'], j['minutes'], j['hours']);
}

class VideoStream {
  final int width;
  final int height;
  final int index;
  final String codec;
  final String? name;
  final String? language;

  const VideoStream(
      {this.width = 0,
      this.height = 0,
      this.codec = "null",
      this.index = -1,
      this.name,
      this.language});

  factory VideoStream.fromJson(dynamic j) => VideoStream(
      width: j['width'],
      height: j['height'],
      codec: j['codec'],
      index: j['index'] ?? -1,
      language: (j['language'] as String).nullIfEmpty(),
      name: (j['name'] as String).nullIfEmpty());

  @override
  String toString() => codec;

  @override
  bool operator ==(other) =>
      other is VideoStream &&
      other.width == width &&
      other.height == height &&
      other.name == name &&
      other.index == index &&
      other.codec.toLowerCase() == codec.toLowerCase();
}

class AudioStream {
  final int bitrate;
  final int channels;
  final int index;
  final bool isDefault;
  final bool isOriginal;
  final int samplerate;
  final String? language;
  final String? name;
  final String? codec;

  const AudioStream(
      {this.bitrate = 0,
      this.channels = 0,
      this.index = -1,
      this.samplerate = 0,
      this.isDefault = false,
      this.isOriginal = false,
      this.language,
      this.name,
      this.codec});

  factory AudioStream.fromJson(dynamic j) => AudioStream(
        bitrate: j['bitrate'] ?? 0,
        channels: j['channels'] ?? 0,
        index: j['index'] ?? -1,
        samplerate: j['samplerate'] ?? 0,
        isDefault: j['isdefault'] ?? false,
        isOriginal: j['isoriginal'] ?? false,
        language: (j['language'] as String).nullIfEmpty(),
        name: (j['name'] as String).nullIfEmpty(),
        codec: (j['codec'] as String).nullIfEmpty(),
      );

  @override
  String toString() => "$name : $bitrate : $language : $codec";

  @override
  bool operator ==(other) =>
      other is AudioStream &&
      other.bitrate == bitrate &&
      other.channels == channels &&
      other.index == index &&
      other.isDefault == isDefault &&
      other.name == name &&
      other.language == language &&
      other.codec == codec;
}

class Subtitle {
  final int index;
  final bool isDefault;
  final bool isForced;
  final bool isImpaired;
  final String? language;
  final String? name;

  const Subtitle(
      {this.index = -1,
      this.isDefault = false,
      this.isForced = false,
      this.isImpaired = false,
      this.language,
      this.name});

  factory Subtitle.fromJson(dynamic j) => Subtitle(
      index: j['index'] ?? -1,
      isDefault: j['isdefault'] ?? false,
      isForced: j['isforced'] ?? false,
      isImpaired: j['isimpaired'] ?? false,
      language: (j['language'] as String).nullIfEmpty(),
      name: (j['name'] as String).nullIfEmpty());

  @override
  String toString() => "$language, $name";

  @override
  bool operator ==(other) =>
      other is Subtitle &&
      other.index == index &&
      other.isDefault == isDefault &&
      other.isForced == isForced &&
      other.isImpaired == isImpaired &&
      other.name == name &&
      other.language == language;
}
