import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class AddonsListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Hero(
            tag: HERO_CONTENT_ADDONS_HEADER,
            child: Text("Addons",
                    style: Theme.of(context).textTheme.headline5)
          )
        ),
        SliverToBoxAdapter(
          child: Text("Video Addons", style: Theme.of(context).textTheme.headline6)
        )
      ],
    );
  }
}
