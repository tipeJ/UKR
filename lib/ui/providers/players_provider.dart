import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:hive/hive.dart';
import 'dart:async';

import 'package:multicast_dns/multicast_dns.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class PlayersProvider extends ChangeNotifier {
  Box<Player> get _box => Hive.box<Player>(BOX_PLAYERS);
  get _cachedBox => Hive.box(BOX_CACHED);
  final List<Player> players = [];
  Player? selectedPlayer;

  PlayersProvider() {
    this.players.addAll(_box.values);
    final id = _cachedBox.get(DATA_MOST_RECENT_PLAYERID);
    if (id == null) {
      selectedPlayer = players.isEmpty ? null : players.first;
    } else {
      selectedPlayer =
          players.firstWhere((p) => p.id == id, orElse: () => players.first);
    }
  }

  Future<bool> testPlayer(Player player) async =>
      await ApiProvider.testPlayerConnection(player) == 200;

  /// Adds the given player to the list of players, and saves it to the local database.
  void addPlayer(Player player) {
    players.add(player);
    _box.put(player.id, player);
    selectedPlayer = player;
    notifyListeners();
  }

  /// Removes the player from the list and the local database.
  void removePlayer(Player player) {
    if (players.remove(player)) {
      notifyListeners();
      _box.delete(player.id);

      // Switch to first player, if exists.
      if (player == selectedPlayer) {
        if (players.isNotEmpty) {
          setPlayer(players[0]);
        } else {
          selectedPlayer = null;
          notifyListeners();
        }
      }
    }
  }

  /// Modify the selected player, replacing the old values with the new.
  void modifyPlayer(Player original, Player modified) {
    final index = players.indexOf(original);
    if (index != -1 && original.id == modified.id) {
      players[index] = modified;
      notifyListeners();
      _box.putAt(index, modified);

      if (original == selectedPlayer) {
        selectedPlayer = modified;
        notifyListeners();
      }
    }
  }

  /// Sets the given player as the current player.
  void setPlayer(Player player) {
    if (player == this.selectedPlayer) return;
    selectedPlayer = player;
    _cachedBox.put(DATA_MOST_RECENT_PLAYERID, player.id);
    notifyListeners();
  }

  Stream<List<Tuple2<Player, bool>>>? networkDiscoveryPlayers;

  Future<void> discoVERY() async {
    print("Started network discovery");
    const String name = "_xbmc-jsonrpc-h._tcp";
    final MDnsClient client = MDnsClient();
    await client.start();
    List<Tuple2<Player, bool>> currentList = [];

    print("Client started");
    networkDiscoveryPlayers = client
        .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))
        .asyncMap<SrvResourceRecord>((p) async => await client
            .lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(p.domainName))
            .first)
        .map<Player>((t) {
      return Player(
          id: Uuid().v1(),
          address: t.target,
          port: t.port,
          name: t.target.replaceAll(".local", ""));
    }).asyncMap<List<Tuple2<Player, bool>>>((p) async {
      final props = await ApiProvider.getApplicationProperties(p);
      bool auth = true;
      if (props['error'] == 401) {
        // Handle auth
        auth = false;
      }
      var newPlayer = Tuple2(Player(
          address: p.address,
          port: p.port,
          id: p.id,
          name:
              props['name'] != null ? "${props['name']} (${p.name})" : p.name), auth);
      if (!currentList.contains(newPlayer)) currentList.add(newPlayer);
      return currentList;
    });
    notifyListeners();
  }

  void resetSearchState() => networkDiscoveryPlayers = null;
}
