export 'image_utils.dart';
export 'platform_utils.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension ListExtensions<T> on List<T> {
  /// A version of this list where the null values are filtered.
  List<T> nonNulls() => where((i) => i != null).toList();

  /// String representation of this list.
  String separateFold(String separator) {
    String fold = "";
    for (int i = 0; i < length; i++) {
      fold += this[i].toString();
      if (i != length - 1) fold += " $separator";
    }
    return fold;
  }
}

extension MapsExtensions<T, E> on Map<T, E> {
  E getPreferred(List<T> preferreds, E def) {
    for (int i = 0; i < preferreds.length; i++) {
      E? p = this[preferreds[i]];
      if (p != null) {
        return p;
      }
    }
    return def;
  }
}

extension Generals on dynamic {
  T? nullOr<T>(T retur) => this == null ? null : retur;
  T? nullIf<T>(T retur, ConditionArgument a) => a(this) ? retur : null;
}

typedef bool ConditionArgument<T>(T parameter);
