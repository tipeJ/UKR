/// Filter the fetch results for any Kodi API list query
class ListFilter {
  final String operator;
  final String field;
  final String value;
  const ListFilter(
      {this.operator = "contains", required this.field, required this.value});

  Map<String, dynamic> toJson() =>
      {"operator": this.operator, "field": this.field, "value": this.value};
}

extension ListFilterExtensions<ListFilter> on List<ListFilter> {
  Map<String, dynamic> toJson() {
    if (isEmpty) {
      return const {};
    } else {
      // TODO: Change workaround when dart team fixes this.
      return {"and": map((f) => (f as dynamic).toJson())};
    }
  }
}
