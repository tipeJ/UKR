import 'package:hive/hive.dart';

class Player {
  final String id;
  final String name;
  final String address; // Only the IP part, ie. 192.168.xxx.xxx
  final int port;

  const Player({this.id, this.name, this.address, this.port});
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final typeId = 0;
  @override
  Player read(BinaryReader reader) => Player(
      id: reader.read(),
      name: reader.read(),
      address: reader.read(),
      port: reader.read());

  @override
  void write(BinaryWriter writer, Player p) {
    writer.write(p.id);
    writer.write(p.name);
    writer.write(p.address);
    writer.write(p.port);
  }
}
