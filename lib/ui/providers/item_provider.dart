import 'dart:async';
import 'package:UKR/models/item.dart';
import 'package:UKR/models/player.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class ItemProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();
  Player? _player;
  Player get player => _player!;
  StreamSubscription<Item>? _subscription;

  ItemProvider(Player player) {
    initialize(player);
  }

  void initialize(Player player) {
    this._player = player;
    _subscription?.pause();
    _subscription = _api.playerItemStream(player).listen((newItem) {
      if (newItem != item) {
        item = newItem;
        print((item as VideoItem).banner);
        print((item as VideoItem).fanart);
        print((item as VideoItem).thumb);
        print((item as VideoItem).poster);
        notifyListeners();
      }
    });
    _subscription?.resume();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Item? item;
}
