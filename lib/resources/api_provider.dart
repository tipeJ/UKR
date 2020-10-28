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
  static String url(Player p) => "http://${p.address}:${p.port}/jsonrpc";

  factory ApiProvider() {
    return _apiProvider;
  }

  ApiProvider._internal();

  Future<String> _getApplicationProperties(Player player) async {
    final body = jsonEncode({
      "method": "Application.getProperties",
      "params": {
        "properties": ["muted", "name", "version", "volume"]
      }
    });
    final response = await http.post(url(player), headers: headers, body: body);
    if (response.statusCode == 200) {
      return response.body;
    }
    return "An error occurred: ${response.statusCode}";
  }

  Future<String> _getPlayerProperties(Player player) async {
    final body = jsonEncode({
      "method": "Player.getProperties",
      "params": {
        "playerid": 1,
        "properties": ["position", "repeat", "type", "time", "videostreams"]
      },
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    if (response.statusCode == 200) {
      return response.body;
    }
    return "An error occurred" + response.statusCode.toString();
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

  Future<int> adjustVolume(Player player, {double newVolume}) async {
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
}

ApplicationProperties _parseApplicationProperties(String jsonSource) {
  final json = jsonDecode(jsonSource);
  return ApplicationProperties.fromJson(json);
}

PlayerProperties _parsePlayerProperties(String jsonSource) {
  final json = jsonDecode(jsonSource);
  return PlayerProperties.fromJson(json['result']);
}
