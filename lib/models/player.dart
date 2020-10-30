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

  const Player({this.id, this.name, this.address, this.port});
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
    return Player(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
      port: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Player p) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(p.id)
      ..writeByte(1)
      ..write(p.name)
      ..writeByte(2)
      ..write(p.address)
      ..writeByte(3)
      ..write(p.port);
  }
}
