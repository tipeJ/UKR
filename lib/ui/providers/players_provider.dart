import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class PlayersProvider extends ChangeNotifier {
  final _api = ApiProvider();
  final _box = Hive.box(BOX_PLAYERS);
  final List<Player> players = List();
  Player selectedPlayer;

  PlayersProvider() {
    this.players.addAll(_box.values.where((i) => i is Player));
    final id = this._box.get(DATA_MOST_RECENT_PLAYERID);
    if (id == null) {
      selectedPlayer = players.first;
    } else {
      selectedPlayer = players.firstWhere((p) => p.id == id) ?? players.first;
    }
  }
  Future<bool> testPlayer(Player player) => _api.testPlayerConnection(player);
  void addPlayer(Player player) {
    players.add(player);
    _box.add(player);
    notifyListeners();
  }

  void setPlayer(Player player) {
    selectedPlayer = player;
    _box.put(DATA_MOST_RECENT_PLAYERID, player.id);
    notifyListeners();
  }
}
