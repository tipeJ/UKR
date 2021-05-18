Map<String, String> parseCast(List<dynamic>? c) {
  if (c == null) return const {};
  Map<String, String> cast = {};
  c.forEach((i) => cast[i['name']] = i['role']);
  return cast;
}
