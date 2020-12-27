import 'package:UKR/models/player.dart';
import 'package:UKR/utils/utils.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class AddPlayerDialog extends StatefulWidget {
  @override
  State<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends State<AddPlayerDialog> {
  static final uuid = Uuid();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _portController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _credentialsGiven =>
      _usernameController.text.isNotEmpty &&
      _passwordController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Form(
            key: _formKey,
            child: Column(children: [
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter a name" : null,
                controller: _nameController,
                decoration: const InputDecoration(
                    hintText: "Name of the server", labelText: "Name"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Please enter an address" : null,
                controller: _addressController,
                decoration: const InputDecoration(
                    hintText: "Address of the server i.e. 192.168.xxx.xxx",
                    labelText: "Address"),
              ),
              TextFormField(
                validator: (value) =>
                    value!.isEmpty ? "Plase enter a valid port number" : null,
                controller: _portController,
                decoration: const InputDecoration(
                  hintText: "Port of the Kodi instance",
                  labelText: "Port",
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Username (Optional)",
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password (Optional)",
                ),
              ),
              Row(
                children: [
                  FlatButton(
                    child: const Text("Cancel"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  ElevatedButton(
                    child: const Text("OK"),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final newPlayer = Player(
                          id: uuid.v1(),
                          name: _nameController.text,
                          address: _addressController.text,
                          port: int.parse(_portController.text),
                          username: _credentialsGiven ? _usernameController.text : null,
                          password: _credentialsGiven
                              ? _passwordController.text
                              : null,
                        );
                        Navigator.of(context).pop(newPlayer);
                      }
                    },
                  ),
                ],
              )
            ])));
  }
}
