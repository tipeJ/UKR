import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../screens.dart';

class RemoteRouter {
  static const _invalidParams = Text("Invalid parameters");
  static Route generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    Widget child = Center(child: Text("No Router found for ${settings.name}"));
    switch (settings.name) {
      case ROUTE_PAGES_SCREEN:
        child = Stack(children: [
          BackgroundVolumeWrapper(),
          PagesScreen(),
        ]);
        break;
      case ROUTE_CURRENT_ITEM_DETAILS:
        child = ItemDetailsScreen();
        break;
      case ROUTE_CONTENT_VIDEOITEM_DETAILS:
        if (args is VideoItem) {
          child = VideoDetailsScreen(args);
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CAST_SCREEN:
        if (args is VideoItem) {
          child = CastScreen(args);
        } else {
          child = const Text("No cast for non-video items");
        }
        break;
      case ROUTE_CONTENT_ADDONS:
        child = AddonsListScreen();
        break;
      case ROUTE_ADDON_DETAILS:
        if (args is Addon) {
          child = AddonDetailsScreen(args);
        }
        break;
      case ROUTE_CONTENT_FILES:
        if (args is Player) {
          child = FilesScreen(args);
        }
        break;
      case ROUTE_FILELIST:
        if (args is Tuple3<Player, String, String>) {
          child = ChangeNotifierProvider(
            create: (_) => FilelistProvider(args.item1,
                rootPath: args.item2, title: args.item3),
            builder: (_, __) => FilelistScreen(),
          );
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CONTENT_MOVIES:
        if (args is Player) {
          child = ChangeNotifierProvider(
            create: (_) => MoviesProvider(args, initialFetch: true),
            builder: (_, __) => MoviesScreen(),
          );
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CONTENT_MOVIE_SEARCH:
        if (args is Player) {
          child = ChangeNotifierProvider(
            create: (_) => MoviesProvider(args),
            builder: (_, __) => MoviesSearchScreen(),
          );
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CONTENT_SHOWS:
        if (args is Player) {
          child = ChangeNotifierProvider(
              create: (_) => TVShowsProvider(args, initialFetch: true),
              builder: (_, __) => TVShowsScreen());
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CONTENT_SHOW_SEARCH:
        if (args is Player) {
          child = ChangeNotifierProvider(
            create: (_) => TVShowsProvider(args),
            builder: (_, __) => TVShowsSearchScreen(),
          );
        } else {
          child = _invalidParams;
        }
        break;
      case ROUTE_CONTENT_TVSHOW_DETAILS:
        if (args is Tuple2<TVShow, Player>) {
          child = TVShowDetailsScreen(player: args.item2, show: args.item1);
        } else {
          child = _invalidParams;
        }
        break;
    }
    return MaterialPageRoute(builder: (context) => child);
  }
}
