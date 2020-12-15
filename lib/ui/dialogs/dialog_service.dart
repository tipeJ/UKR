import "dart:async";

import 'package:UKR/models/models.dart';

class DialogService {
  Function(Input)? _showDialogListener;
  Function? _dialogDismisser;
  Completer? _dialogCompleter;

  void registerDialogListener(Function(Input) showDialogListener) =>
      _showDialogListener = showDialogListener;
  void registerDialogDismiss(Function dismissDialog) =>
      _dialogDismisser = dismissDialog;

  Future<dynamic> showDialog(Input input) {
    _dialogCompleter = Completer();
    if (_showDialogListener != null) {
      _showDialogListener!(input);
    }
    return _dialogCompleter!.future;
  }

  void dismissDialog() {
    if (_dialogDismisser != null) {
      _dialogDismisser!();
    }
  }

  void dialogComplete([dynamic returnValue]) {
    _dialogCompleter?.complete(returnValue);
    _dialogCompleter = null;
  }
}
