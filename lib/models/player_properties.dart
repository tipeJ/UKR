class PlayerProperties {
  final PlayerTime time;
  final PlayerTime totalTime;
  final int speed;
  final String type;

  final List<VideoStream> videoStreams;
  final VideoStream currentVideoStream;

  final Repeat repeat;

  bool get playing => speed > 0;

  const PlayerProperties(
      {this.time = const PlayerTime(0, 0, 0),
      this.totalTime = const PlayerTime(0, 0 , 0),
      this.type = "Null",
      this.speed = 0,
      this.repeat = Repeat.Off,
      this.videoStreams = const [],
      this.currentVideoStream = const VideoStream()});

  factory PlayerProperties.fromJson(dynamic j) => PlayerProperties(
      time: PlayerTime.fromJson(j['time']),
      totalTime: PlayerTime.fromJson(j['totaltime']),
      type: j['type'],
      speed: j['speed'],
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

  int get inSeconds => (this.hours * minutes + minutes) * 60 + seconds;

  @override
  String toString() =>
  [hours > 9 ? hours.toString() : "0$hours", minutes > 9 ? minutes.toString() : "0$minutes", seconds > 9 ? seconds.toString() : "0$seconds"].join(":");

  const PlayerTime(this.seconds, this.minutes, this.hours);
  factory PlayerTime.fromJson(dynamic j) => j == null
      ? PlayerTime(0, 0, 0)
      : PlayerTime(j['seconds'], j['minutes'], j['hours']);
}

class VideoStream {
  final int width;
  final int height;
  final String codec;

  const VideoStream({this.width = 0, this.height = 0, this.codec = "h264"});
  factory VideoStream.fromJson(dynamic j) =>
      VideoStream(width: j['width'], height: j['height'], codec: j['codec']);
}
