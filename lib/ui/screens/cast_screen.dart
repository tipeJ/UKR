import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CastScreen extends StatelessWidget {
  final List<Map<String, String>> cast;
  const CastScreen(this.cast);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: cast.length,
        itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: CastItem(
                name: cast[i]['name'] ?? "Unknown",
                role: cast[i]['role'] ?? "Unknown")));
  }
}

class CastSliverList extends StatelessWidget {
  static const _itemHeight = 350.0;

  final List<Map<String, String>> cast;
  const CastSliverList(this.cast);

  @override
  GridView build(BuildContext context) {
    return GridView.builder(
      itemCount: cast.length > 10 ? cast.length + 1 : cast.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: listPosterRatio,
          maxCrossAxisExtent: gridPosterMaxWidth),
        itemBuilder: (_, i) => i == cast.length
          ? InkWell(
            child: Container(
              height: _itemHeight,
              child: const Center(child: Text("Show all"))
            ),
            onTap: () => Navigator.of(context).pushNamed(ROUTE_CAST_SCREEN, arguments: cast),
          )
          : _CastGridItem(cast[i])
    );
  }
}

class _CastGridItem extends StatelessWidget {
  late final String name;
  late final String role;
  late final String? img;


  _CastGridItem(Map<String, String> item) {
    this.name = item['name'] ?? "Unknown";
    this.role = item['role'] ?? "Unknown";
    this.img  = item['thumb'];
  }

  @override
  Widget build(BuildContext context) {
    Widget? background = Container(color: Colors.red);
    if (img != null) {
      background = CachedNetworkImage(fit: BoxFit.cover, imageUrl: img!);
    }
    return Container(
        height: 350.0,
        child: background);
  }
}
