import 'package:tuple/tuple.dart';

Map<String, String> parseCast(List<dynamic>? c) {
  if (c == null) return const {};
  Map<String, String> cast = {};
  c.forEach((i) => cast[i['name']] = i['role']);
  return cast;
}

// Get hours and minutes from seconds.
Tuple2<int, int> getHoursAndMinutes(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;
  return Tuple2(hours, minutes);
}
