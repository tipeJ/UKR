/// Limits the fetch results for any Kodi API list query
class ListLimits {
  final int start;
  final int end;
  const ListLimits({this.start = 0, this.end = -1});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {
      'limits': {'start': start}
    };
    if (end >= 0) {
      res['limits']['end'] = end;
    }
    return res;
  }
}
