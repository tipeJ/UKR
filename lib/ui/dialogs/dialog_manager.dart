import 'dart:io';

import 'package:UKR/models/models.dart';
import 'package:UKR/ui/dialogs/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DialogManager extends StatefulWidget {
  final Widget child;
  DialogManager({required this.child});

  _DialogManagerState createState() => _DialogManagerState();
}

class _DialogManagerState extends State<DialogManager> {
  DialogService _dialogService = GetIt.instance<DialogService>();
  bool active = false;

  @override
  void initState() {
    super.initState();
    _dialogService.registerDialogListener(_showDialog);
    _dialogService.registerDialogDismiss(() {
        if (active) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;

  void _showDialog(Input input) async {
    active = true;
    Widget alert;
    String? returnValue;

    switch (input.type) {
      case InputType.Keyboard:
      alert = AlertDialog(
        title: Text(input.title),
        content: TextField(
          decoration: InputDecoration(labelText: input.title),
          onChanged: (s) => returnValue = s
        ),
        actions: [
          FlatButton(
            child: const Text("Cancel"),
            onPressed: () {
              _dialogService.dialogComplete();
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: const Text("OK"),
            onPressed: () {
              _dialogService.dialogComplete(returnValue);
              Navigator.of(context).pop();
            },
          ),
        ]);
        break;
      default:
        alert = Text("BL");
    }
    await showDialog(
        context: context, barrierDismissible: false, builder: (_) => alert);
    active = false;
  }
}
