import 'package:flutter/material.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class RemoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: _durationtest()),
        bottomSheet: RemoteControlsBar(),
        body: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                ))
          ],
        ));
  }
}

class _durationtest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(context.watch<MainProvider>().playerItem?.duration.toString());
  }
}
