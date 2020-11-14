import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class RemoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TITLE")),
      bottomSheet: RemoteControlsBar(),
      body: Stack(
        children: [
          BackgroundVolume(),
          Align(
              alignment: Alignment.topCenter,
              child: CurrentItem()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: EdgeInsets.only(bottom: 50.0),
                child: RemoteButtons()
              )
              ,)
        ],
      ));
  }
}
