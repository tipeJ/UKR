import 'package:UKR/models/models.dart';
import 'package:UKR/utils/utils.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class VideoItemInfo extends StatelessWidget {
  final VideoItem item;

  const VideoItemInfo(this.item);

  @override
  Widget build(BuildContext context) {
    TextTheme theme = Theme.of(context).textTheme;
    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(item.label, minFontSize: 18.0, maxFontSize: 25.0),
          if (item.tagline != null)
            Text(item.tagline!,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: theme.caption),
          SizedBox(height: 5.0),
          Text.rich(TextSpan(children: [
            if (item.year != null)
              TextSpan(
                  text: item.year.toString() + " ", style: theme.bodyText1),
            TextSpan(text: _getDurationString(item) + " "),
            if (item.mpaa != null)
              TextSpan(text: item.mpaa! + " ", style: theme.bodyText1)
          ])),
          if (item.rating != null)
            Text.rich(TextSpan(children: [
              TextSpan(children: [
                TextSpan(
                    text: item.rating!.toStringAsFixed(2),
                    style: theme.caption),
                TextSpan(text: "/10", style: theme.bodyText2)
              ]),
            ]))
        ]);
  }

  static String _getDurationString(VideoItem item) {
    if (item.type == 'movie') {
      final runtime = getHoursAndMinutes(item.duration);
      return "${runtime.item1}h ${runtime.item2}m";
    }
    return "";
  }
}
