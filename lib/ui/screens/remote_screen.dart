import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:UKR/ui/providers/providers.dart';

class RemoteScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("UKR")),
        body: Stack(
          children: [
            Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                  child: Slider(
                    min: 0.0,
                    max: 100.0,
                    value: context.watch<MainProvider>().volume.toDouble(),
                    onChanged: (newValue) {
                      final vol = newValue.round();
                      if (vol != context.read<MainProvider>().volume) {
                        context.read<MainProvider>().setVolume(vol);
                      }
                    },
                  ),
                ))
          ],
        ));
  }
}
