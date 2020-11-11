import 'dart:async';
import 'package:UKR/models/item.dart';
import 'package:UKR/models/player.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/material.dart';

class ItemProvider with ChangeNotifier {
  final ApiProvider _api = ApiProvider();
  final Player _player;
  Stream<Item> _stream;
  StreamSubscription<Item> _subscription;

  ItemProvider(this._player) {
    _stream = _api.playerItemStream(_player);
    _subscription = _stream.listen((newItem) {
      if (newItem != item) {
        item = newItem;
        notifyListeners();
      }
    });
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Item item;
}
