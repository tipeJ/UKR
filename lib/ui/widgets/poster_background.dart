import 'dart:ui';

import 'package:flutter/material.dart';

class PosterBackground extends StatelessWidget {
  const PosterBackground({
    Key? key,
    required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            image:
                DecorationImage(fit: BoxFit.cover, image: NetworkImage(image))),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.45),
            )),
      );
}
