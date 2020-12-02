import 'dart:io';
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
  static String wsurl(Player p) => "ws://${p.address}:9090";

  Future<WebSocket> getWS(Player player) => WebSocket.connect(wsurl(player),
      headers: headers, compression: CompressionOptions.compressionOff);

  factory ApiProvider() {
    return _apiProvider;
  }

  ApiProvider._internal();

  // System API endpoints
  Future<bool> testPlayerConnection(Player player) async {
    //TODO: Get this check working on local servers that do not have http control enabled (doesn't return anything)
    final body = jsonEncode({"method": "JSONRPC.Ping", ...defParams});
    final request = await http
        .post(url(player), headers: headers, body: body)
        .timeout(_pingTimeOut, onTimeout: () => http.Response("", 404));
    return request.statusCode == 200;
  }

  Future<Map<String, bool>> getSystemProperties(Player player) async {
    final body = await _encode("System.GetProperties", const {
      "properties": ["canshutdown", "canhibernate", "canreboot", "cansuspend"]
    });
    final response = await http.post(url(player), body: body, headers: headers);
    final json = await compute(jsonDecode, response.body);
    return Map<String, bool>.from(json['result']);
  }

  void toggleSystemProperty(Player player, String property) async {
    final body = jsonEncode({"method": "System.$property", ...defParams});
    http.post(url(player), body: body, headers: headers);
  }

  // Properties endpoints
  static String _handleHTTPResponse(http.Response r) => r.statusCode == 200
      ? r.body
      : "";
  static Future<String> _encode(String method, Map<String, dynamic> params) =>
      compute(jsonEncode, {"method": method, "params": params, ...defParams});

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

  Future<Map<String, dynamic>> getApplicationProperties(Player player) async {
    final body = await _encode("Application.GetProperties", {
      "properties": const ["muted", "name", "version", "volume"]
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    return parsed['result'] ?? const {};
  }

  Future<Map<String, dynamic>> getPlayerProperties(Player player) async {
    final body = await _encode("Player.getProperties", {
      "playerid": _playerID,
      "properties": const [
        "position",
        "repeat",
        "type",
        "speed",
        "playlistid",
        "totaltime",
        "time",
        "canseek",
        "videostreams",
        "currentvideostream"
      ]
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    return parsed['result'] ?? const {};
  }

  Future<Map<String, dynamic>> getPlayerItem(Player player) async {
    final body = await _encode("Player.GetItem", {
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
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    return parsed['result'] ?? const {};
  }

  Future<Map<String, dynamic>> getPlayList(Player player,
      {required int id}) async {
    final body = await _encode("Player.GetItem", {"playlistid": id});
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    return parsed['result'] ?? const {};
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

  Future<String> retrieveCachedImageURL(Player player, String source) async {
    final bod = await _encode("Files.PrepareDownload", {"path": source});
    final r = await http.post(url(player), headers: headers, body: bod);
    if (r.statusCode != 200) return "";
    final parsed = await compute(jsonDecode, r.body);
    final path = parsed['result']['details']['path'];
    if (path == null) return "";
    return "http://${player.address}:${player.port}/" +
        parsed['result']['details']['path'];
  }

  void skip(Player player, Map<String, dynamic> params) async {
    final body =
        await _encode("Player.Seek", {"playerid": _playerID, "value": params});
    http.post(url(player), headers: headers, body: body);
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
