import 'package:UKR/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiProvider {
  static final ApiProvider _apiProvider = ApiProvider._internal();
  static const _refreshInterval = Duration(milliseconds: 750);
  static const _pingTimeOut = Duration(milliseconds: 500);

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

  // System API endpoints
  Future<bool> testPlayerConnection(Player player) async {
    //TODO: Implement check with kodi-server that doesn't have JSONRPC enabled
    final body = jsonEncode({"method": "JSONRPC.Ping"});
    final request = await http
        .post(url(player), headers: headers, body: body)
        .timeout(_pingTimeOut, onTimeout: () => http.Response("", 404));
    return request.statusCode == 200;
  }

  Future<Map<String, bool>> getSystemProperties(Player player) async {
    final body = jsonEncode({
      "method": "System.GetProperties",
      "params": {
        "properties": const [
          "canshutdown",
          "canhibernate",
          "canreboot",
          "cansuspend"
        ]
      },
      ...defParams
    });
    final response = await http.post(url(player), body: body, headers: headers);
    final json = jsonDecode(response.body);
    return Map<String, bool>.from(json['result']);
  }

  void toggleSystemProperty(Player player, String property) async {
    final body = jsonEncode({"method": "System.$property", ...defParams});
    http.post(url(player), body: body, headers: headers);
  }

  // Properties endpoints
  static String _handleHTTPResponse(http.Response r) => r.statusCode == 200
      ? r.body
      : "An error occurred: " + r.statusCode.toString();

  Future<String> _getApplicationProperties(Player player) async {
    final body = jsonEncode({
      "method": "Application.GetProperties",
      "params": {
        "properties": const ["muted", "name", "version", "volume"]
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
        "properties": const [
          "position",
          "repeat",
          "type",
          "speed",
          "totaltime",
          "time",
          "canseek",
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
        "properties": const [
          "director",
          "year",
          "disc",
          "albumartist",
          "art",
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
      final parsedItem = await compute(_parsePlayerItem, response);
      yield parsedItem;
    }
  }

  // * Input API endpoints
  void navigate(Player p, String a) => http.post(url(p),
      body: jsonEncode({
        "method": "Input.ExecuteAction",
        "params": {"action": a},
        ...defParams
      }),
      headers: headers);

  // * Application API endpoints
  Future<int> adjustVolume(Player player, {required int newVolume}) async {
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

  Future<bool> toggleMute(Player player, [bool? value]) async {
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

  Future<int> seek(Player player, {required double percentage}) async {
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

  void toggleRepeat(Player player) async {
    final body = jsonEncode({
      "method": "Player.SetRepeat",
      "params": {"playerid": _playerID, "repeat": "cycle"},
      ...defParams
    });
    await http.post(url(player), headers: headers, body: body);
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
