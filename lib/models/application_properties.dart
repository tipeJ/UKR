const EmptyApplicationProperties =
    ApplicationProperties(name: "", muted: false, version: "", volume: 0);

class ApplicationProperties {
  final bool muted;
  final String name;
  final String version;
  final int volume;

  const ApplicationProperties(
      {required this.muted, required this.name, required this.version, required this.volume});

  factory ApplicationProperties.fromJson(dynamic j) => ApplicationProperties(
      muted: j['muted'],
      name: j['name'],
      version: j['version'].toString(),
      volume: j['volume']);
}
