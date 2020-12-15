extension StringExtensions on String {
  // ** Capitalize
  /// Capitalizes the string. What more do you need to know?
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }

  // ** Replace String
  /// Replaces everything inside given characters occurring inside the String with the replacement value. (i.e. inside brackets ()). Also replaces the starting and closing characters. Default replacement value is an empty string (removal).
  String replaceInside(String starting, String closing, {String replacement = ""}) {
    String current = this;
    while (true) {
      int startIndex = current.indexOf(starting);
      if (startIndex == -1) break;
      int endIndex = current.indexOf(closing, startIndex);
      current = current.replaceRange(startIndex, endIndex + 1, replacement);
    }
    return current;
  }
}
