import 'package:UKR/models/player.dart';
import 'package:flutter/material.dart';

class AddPlayerDialog extends StatefulWidget {
  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            validator: (value) => value.isEmpty ? "Please enter a name" : null,
            controller: _nameController,
            decoration: InputDecoration(
                hintText: "Name of the server", labelText: "Name"),
          ),
          TextFormField(
            validator: (value) =>
                value.isEmpty ? "Please enter an address" : null,
            controller: _addressController,
            decoration: InputDecoration(
                hintText: "Address of the server i.e. 192.168.xxx.xxx",
                labelText: "Address"),
          ),
          TextFormField(
            validator: (value) =>
                value.isEmpty ? "Plase enter a valid port number" : null,
            controller: _portController,
            decoration: InputDecoration(
              hintText: "Port of the Kodi instance",
              labelText: "Port",
            ),
            keyboardType: TextInputType.number,
            maxLength: 4,
          ),
          Row(
            children: [
              ElevatedButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text("OK"),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    final newPlayer = Player(
                        name: _nameController.text,
                        address: _addressController.text,
                        port: int.parse(_portController.text));
                    Navigator.of(context).pop(newPlayer);
                  }
                },
              ),
            ],
          )
        ]));
  }
}
