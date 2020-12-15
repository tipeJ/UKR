import 'models.dart';
import 'package:UKR/utils/utils.dart';

class Input {
  final InputType type;
  final String title;
  final String value;

  const Input(this.type, this.title, this.value);
  factory Input.fromJson(dynamic j) => Input(
      enumFromString(InputType.values, j['type']), (j['title'] as String).replaceInside("[", "]"), j['value']);
}

enum InputType {
  Keyboard,
  Time,
  Date,
  IP,
  Password,
  Numericpassword,
  Number,
  Seconds
}
