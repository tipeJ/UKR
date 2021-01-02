import 'dart:io';

import 'package:UKR/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:hive/hive.dart';
import 'dart:async';
import 'package:mdns_plugin/mdns_plugin.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

class PlayersProvider extends ChangeNotifier {
  static const String _zeroconfServiceName = "_xbmc-jsonrpc-h._tcp";

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

  /// Zeroconf player information search. Uses multicast DNS for indexing.
  Future<void> discoVERY() async {
    print("Started network discovery");

    List<Tuple2<Player, bool>> currentList = [];

    print("Client started");
    if (isMobile()) {
      networkDiscoveryPlayers = _nativeMdnsStream();
    } else {
      // Workaround needed for android, which doesn't seem to support reusePort
      final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
          (dynamic host, int port,
              {bool reuseAddress = true, bool reusePort = true, int ttl = 10}) {
        return RawDatagramSocket.bind(host, port,
            reuseAddress: reuseAddress,
            reusePort: Platform.isAndroid ? false : reusePort,
            ttl: ttl);
      });
      await client.start();
      networkDiscoveryPlayers = client
          .lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(_zeroconfServiceName))
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
        final newPlayer = await _fetchPlayerInfo(p);
        if (!currentList.contains(newPlayer)) currentList.add(newPlayer);
        return currentList;
      });
    }
    notifyListeners();
  }

  /// Stream for mobile devices. For some reason Android devices require the usage of platform channel-based Mdns implementation, instead of the native dart one used above.
  static Stream<List<Tuple2<Player, bool>>> _nativeMdnsStream() async* {
    List<Tuple2<Player, bool>> currentList = [];
    StreamController<List<Tuple2<Player, bool>>> controller =
        StreamController();
    MDNSPlugin mdns = new MDNSPlugin(_MdnsNativeDelegate((s) async {
      try {
        Uri.parse(s.hostName);
        final newPlayer = await _fetchPlayerInfo(Player(
            address: s.hostName, port: s.port, name: s.name, id: Uuid().v1()));
        if (!currentList.contains(newPlayer)) {
          currentList.add(newPlayer);
          controller.add(currentList);
        }
      } catch (e) {
        print("Mdns URI PARSE ERROR" + e.toString());
      }
    }));
    await mdns.startDiscovery(_zeroconfServiceName, enableUpdating: true);
    yield* controller.stream;
    await Future.delayed(const Duration(seconds: 5));
    await mdns.stopDiscovery();
    await controller.close();
  }

  static Future<Tuple2<Player, bool>> _fetchPlayerInfo(Player p) async {
    final props = await ApiProvider.getApplicationProperties(p);
    bool auth = true;
    if (props['error'] == 401) {
      // Handle auth
      auth = false;
    }
    return Tuple2(
        Player(
            address: p.address,
            port: p.port,
            id: p.id,
            name: props['name'] != null &&
                    !RegExp(r'\(.*?\)', caseSensitive: false, multiLine: false)
                        .hasMatch(p.name)
                ? "${props['name']} (${p.name})"
                : p.name),
        auth);
  }

  void resetSearchState() => networkDiscoveryPlayers = null;
}

class _MdnsNativeDelegate implements MDNSPluginDelegate {
  Function(MDNSService) _callBack;
  _MdnsNativeDelegate(this._callBack);

  @override
  void onDiscoveryStarted() {
    // TODO: implement onDiscoveryStarted
  }

  @override
  void onDiscoveryStopped() {
    // TODO: implement onDiscoveryStopped
  }

  @override
  bool onServiceFound(MDNSService s) {
    return true;
  }

  @override
  void onServiceResolved(MDNSService s) {
    print("SERVICE RESOLVED!:${s.name} - ${s.port}");
    print(s.map);
    _callBack(s);
  }

  @override
  void onServiceUpdated(MDNSService service) {
    // TODO: implement onServiceUpdated
  }

  @override
  void onServiceRemoved(MDNSService service) {
    // TODO: implement onServiceRemoved
  }
}
