const EmptyPlayerProperties = PlayerProperties(
    time: PlayerTime(0, 0, 0),
    totalTime: PlayerTime(0, 0, 0),
    type: "Null",
    videoStreams: []);

class PlayerProperties {
  final PlayerTime time;
  final PlayerTime totalTime;
  final int speed;
  final String type;

  final List<VideoStream> videoStreams;
  final VideoStream currentVideoStream;

  bool get playing => speed > 0;

  const PlayerProperties(
      {this.time,
      this.totalTime,
      this.type,
      this.speed,
      this.videoStreams,
      this.currentVideoStream});

  factory PlayerProperties.fromJson(dynamic j) => PlayerProperties(
      time: PlayerTime.fromJson(j['time']),
      totalTime: PlayerTime.fromJson(j['totaltime']),
      type: j['type'],
      speed: j['speed'],
      currentVideoStream: VideoStream.fromJson(j['currentvideostream']),
      videoStreams: j['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList());
}

class PlayerTime {
  final int hours;
  final int minutes;
  final int seconds;

  int get inSeconds => (this.hours * minutes + minutes) * 60 + seconds;

  const PlayerTime(this.seconds, this.minutes, this.hours);
  factory PlayerTime.fromJson(dynamic j) =>
      PlayerTime(j['seconds'], j['minutes'], j['hours']);
}

class VideoStream {
  final int width;
  final int height;
  final String codec;

  const VideoStream({this.width, this.height, this.codec});
  factory VideoStream.fromJson(dynamic j) =>
      VideoStream(width: j['width'], height: j['height'], codec: j['codec']);
}
