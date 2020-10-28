const EmptyPlayerProperties = PlayerProperties(
    hours: 0, minutes: 0, seconds: 0, type: "Null", videoStreams: []);

class PlayerProperties {
  final int hours;
  final int minutes;
  final int seconds;
  final String type;

  final List<VideoStream> videoStreams;

  const PlayerProperties(
      {this.hours, this.minutes, this.seconds, this.type, this.videoStreams});

  factory PlayerProperties.fromJson(dynamic j) => PlayerProperties(
      hours: j['time']['hours'],
      minutes: j['time']['minutes'],
      seconds: j['time']['seconds'],
      type: j['type'],
      videoStreams: j['videostreams']
          .map<VideoStream>((v) => VideoStream.fromJson(v))
          .toList());
}

class VideoStream {
  final int width;
  final int height;
  final String codec;

  const VideoStream({this.width, this.height, this.codec});
  factory VideoStream.fromJson(dynamic j) =>
      VideoStream(width: j['width'], height: j['height'], codec: j['codec']);
}
