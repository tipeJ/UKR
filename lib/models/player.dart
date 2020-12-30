import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Player {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String address; // Only the IP part, ie. 192.168.xxx.xxx
  @HiveField(3)
  final int port;
  @HiveField(4)
  final String? username;
  @HiveField(5)
  final String? password;

  const Player(
      {required this.id,
      required this.name,
      required this.address,
      required this.port,
      this.username,
      this.password});

  /// Returns true if this player instance has both username and password set.
  bool get hasCredentials => username != null && password != null;

  @override
  bool operator ==(other) =>
      (other is Player) &&
      (other.id == id || (
      other.username == username &&
      other.password == password &&
      other.name == name &&
      other.address == address &&
      other.port == port ));
}

class PlayerAdapter extends TypeAdapter<Player> {
  @override
  final typeId = 0;

  @override
  Player read(BinaryReader reader) {
    final numberOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numberOfFields; i++) reader.readByte(): reader.read(),
    };
    final String id = fields[0] as String;
    final String name = fields[1] as String;
    final String address = fields[2] as String;
    final int port = fields[3] as int;
    return numberOfFields != 6
        ? Player(id: id, name: name, address: address, port: port)
        : Player(
            id: id,
            name: name,
            address: address,
            port: port,
            username: fields[4] as String,
            password: fields[5] as String,
          );
  }

  @override
  void write(BinaryWriter writer, Player p) {
    writer
      ..writeByte(p.hasCredentials ? 6 : 4)
      ..writeByte(0)
      ..write(p.id)
      ..writeByte(1)
      ..write(p.name)
      ..writeByte(2)
      ..write(p.address)
      ..writeByte(3)
      ..write(p.port);
    if (p.hasCredentials) {
      writer
        ..writeByte(4)
        ..write(p.username)
        ..writeByte(5)
        ..write(p.password);
    }
  }
}
