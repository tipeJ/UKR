import 'package:UKR/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiProvider {
  static final ApiProvider _apiProvider = ApiProvider._internal();
  static const _refreshInterval = Duration(milliseconds: 750);

  static const headers = {
    "Content-Type": "application/json",
  };
  static const jsonRPCVersion = "2.0";

  static const defParams = {"jsonrpc": jsonRPCVersion, "id": 27928};
  static const _playerID = 1;
  static String url(Player p) => "http://${p.address}:${p.port}/jsonrpc";

  factory ApiProvider() {
    return _apiProvider;
  }

  ApiProvider._internal();

  Future<bool> testPlayerConnection(Player player) async {
    final body = jsonEncode({"method": "JSONRPC.Ping"});
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode == 200;
  }

  static String _handleHTTPResponse(http.Response r) => r.statusCode == 200
      ? r.body
      : "An error occurred: " + r.statusCode.toString();

  Future<String> _getApplicationProperties(Player player) async {
    final body = jsonEncode({
      "method": "Application.GetProperties",
      "params": {
        "properties": ["muted", "name", "version", "volume"]
      },
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return _handleHTTPResponse(response);
  }

  Future<String> _getPlayerProperties(Player player) async {
    final body = jsonEncode({
      "method": "Player.getProperties",
      "params": {
        "playerid": _playerID,
        "properties": [
          "position",
          "repeat",
          "type",
          "speed",
          "totaltime",
          "time",
          "videostreams",
          "currentvideostream"
        ]
      },
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return _handleHTTPResponse(response);
  }

  Future<String> _getPlayerItem(Player player) async {
    final body = jsonEncode({
      "method": "Player.GetItem",
      "params": {
        "playerid": _playerID,
        "properties": [
          "director",
          "year",
          "disc",
          "albumartist",
          "albumreleasetype",
          "duration",
          "streamdetails"
        ]
      },
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return _handleHTTPResponse(response);
  }

  Stream<ApplicationProperties> applicationPropertiesStream(Player p) async* {
    while (true) {
      await Future.delayed(_refreshInterval);
      final response = await _getApplicationProperties(p);
      final parsedProperties =
          await compute(_parseApplicationProperties, response);
      yield parsedProperties;
    }
  }

  Stream<PlayerProperties> playerPropertiesStream(Player p) async* {
    while (true) {
      await Future.delayed(_refreshInterval);
      final response = await _getPlayerProperties(p);
      final parsedProperties = await compute(_parsePlayerProperties, response);
      yield parsedProperties;
    }
  }

  Stream<Item> playerItemStream(Player p) async* {
    while (true) {
      await Future.delayed(_refreshInterval);
      final response = await _getPlayerItem(p);
      print(response);
      final parsedItem = await compute(_parsePlayerItem, response);
      yield parsedItem;
    }
  }

  // * Application API endpoints
  Future<int> adjustVolume(Player player, {int newVolume}) async {
    final body = jsonEncode({
      "method": "Application.SetVolume",
      "params": {"volume": newVolume},
      ...defParams
    });
    try {
      final response =
          await http.post(url(player), headers: headers, body: body);
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  Future<bool> toggleMute(Player player, [bool value]) async {
    final body = jsonEncode({
      "method": "Application.SetMute",
      "params": {"mute": value ?? "toggle"},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final parsedJson = jsonDecode(response.body);
    return parsedJson['result'];
  }

  // * Player API endpoints
  Future<int> playPause(Player player) async {
    final body = jsonEncode({
      "method": "Player.PlayPause",
      "params": {"playerid": _playerID, "play": "toggle"},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode == 200 ? 200 : -1;
  }

  Future<int> seek(Player player, {double percentage}) async {
    final percent = (percentage * 100).round();
    final body = jsonEncode({
      "method": "Player.Seek",
      "params": {"playerid": _playerID, "value": percent},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode;
  }

  Future<int> stop(Player player) async {
    final body = jsonEncode({
      "method": "Player.Stop",
      "params": {"playerid": _playerID},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode;
  }

  Future<Repeat> toggleRepeat(Player player, {Repeat repeat}) async {
    final body = jsonEncode({
      "method": "Player.SetRepeat",
      "params": {
        "playerid": _playerID,
        "repeat": repeat.toString().split('.').last
      },
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final parsed = jsonDecode(response.body);
    print(response.body);
    return enumFromString(Repeat.values, parsed['result']);
  }
}

ApplicationProperties _parseApplicationProperties(String jsonSource) {
  final json = jsonDecode(jsonSource);
  return ApplicationProperties.fromJson(json['result']);
}

PlayerProperties _parsePlayerProperties(String jsonSource) {
  final json = jsonDecode(jsonSource);
  return PlayerProperties.fromJson(json['result']);
}

Item _parsePlayerItem(String jsonSource) {
  final result = jsonDecode(jsonSource);
  return VideoItem.fromJson(result['result']['item']);
}
