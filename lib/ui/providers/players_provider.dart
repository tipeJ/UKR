import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:hive/hive.dart';
import 'dart:async';

class PlayersProvider extends ChangeNotifier {
  final _api = ApiProvider();
  get _box => Hive.box<Player>(BOX_PLAYERS);
  final List<Player> players = [];
  Player? selectedPlayer;

  PlayersProvider() {
    this.players.addAll(_box.values);
    final id = null; //this._box.get(DATA_MOST_RECENT_PLAYERID);
    if (id == null) {
      selectedPlayer = players.isEmpty ? null : players.first;
    } else {
      selectedPlayer = players.firstWhere((p) => p.id == id, orElse: () => players.first);
    }
  }
  Future<bool> testPlayer(Player player) => _api.testPlayerConnection(player);
  void addPlayer(Player player) {
    players.add(player);
    _box.add(player);
    selectedPlayer = player;
    notifyListeners();
  }

  void setPlayer(Player player) {
    selectedPlayer = player;
    //_box.put(DATA_MOST_RECENT_PLAYERID, player.id);
    notifyListeners();
  }

  void remotePlayerSelection() {
    selectedPlayer = null;
    notifyListeners();
  }
}
