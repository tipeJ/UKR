import 'dart:io';
import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiProvider {
  static const _tmdbApiKey = "1f67bf23438d6cd46fa54a799e1210d5";
  static const _refreshInterval = Duration(milliseconds: 3500);
  static const _pingTimeOut = Duration(milliseconds: 500);
  static const _httpRequestTimeout = const Duration(milliseconds: 5000);

  static const headers = {
    "Content-Type": "application/json",
  };
  static const jsonRPCVersion = "2.0";

  static const defParams = {"jsonrpc": jsonRPCVersion, "id": 27928};
  static const _playerID = 1;
  static String url(Player p) =>
      "http://" +
      (p.hasCredentials ? "${p.username}:${p.password}@" : "") +
      "${p.address}:${p.port}/jsonrpc";
  static String wsurl(Player p) => "ws://${p.address}:9090";

  static Future<WebSocket> getWS(Player player) =>
      WebSocket.connect(wsurl(player),
          headers: headers, compression: CompressionOptions.compressionDefault);

  // * System API endpoints
  static Future<int> testPlayerConnection(Player player) async {
    //TODO: Get this check working on local servers that do not have http control enabled (doesn't return anything)
    final body = await _encode("JSONRPC.Ping", const {});
    try {
      final request = await http
          .post(url(player), headers: headers, body: body)
          .timeout(_pingTimeOut, onTimeout: () => http.Response("", 404));
      return request.statusCode;
    } on SocketException {
      return 408;
    }
  }

  static Future<Map<String, bool>> getSystemProperties(Player player) async {
    final body = await _encode("System.GetProperties", const {
      "properties": ["canshutdown", "canhibernate", "canreboot", "cansuspend"]
    });
    final response = await http.post(url(player), body: body, headers: headers);
    final json = await compute(jsonDecode, response.body);
    return Map<String, bool>.from(json['result']);
  }

  static void toggleSystemProperty(Player player, String property) async {
    final body = jsonEncode({"method": "System.$property", ...defParams});
    http.post(url(player), body: body, headers: headers);
  }

  // * Properties endpoints
  static String _handleHTTPResponse(http.Response r) =>
      r.statusCode == 200 ? r.body : "";
  static Future<String> _encode(String method, Map<String, dynamic> params) =>
      compute(jsonEncode, {"method": method, "params": params, ...defParams});

  static Future<http.Response> _post(Player player, String body,
          {Function(String)? timeOut}) =>
      http
          .post(url(player), headers: headers, body: body)
          .timeout(_httpRequestTimeout, onTimeout: () {
        timeOut?.call("Request Timed Out");
        return http.Response(
            '{"result": {"error": {"message": "Request Timed Out"}}}', 404);
      });
  static Future<dynamic> _postAndParse(Player player, String body) async =>
      compute(jsonDecode, (await _post(player, body)).body);

  static Future<String> _getApplicationProperties(Player player) async {
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

  static Future<Map<String, dynamic>> getApplicationProperties(
      Player player) async {
    final body = await _encode("Application.GetProperties", {
      "properties": const ["muted", "name", "version", "volume"]
    });
    final response = await http.post(url(player), headers: headers, body: body);
    if (response.statusCode != 200) {
      // Handle Unauthorized response
      return {"error": response.statusCode};
    } else {
      final parsed = await compute(jsonDecode, response.body);
      return parsed['result'] ?? const {};
    }
  }

  static Future<Map<String, dynamic>> getPlayerProperties(Player player) async {
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
        "audiostreams",
        "subtitles",
        "currentsubtitle",
        "currentvideostream",
        "currentaudiostream"
      ]
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    return parsed['result'] ?? const {};
  }

  static Future<Map<String, dynamic>> getPlayerItem(Player player) async {
    final body = await _encode("Player.GetItem",
        {"playerid": _playerID, "properties": FETCH_ITEM_PROPERTIES});
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isEmpty) return const {};
    final parsed = await compute(jsonDecode, s);
    final result = parsed['result'];
    if (parsed['error'] == null && result != null) {
      var item = parsed['result']['item'];
      // *** Fetch Artwork Paths
      await _retrieveImageURLs(player, item);
      return item;
    }
    return {};
  }

  static Future<List<PlaylistItemModel>> getPlayList(Player player,
      {required int id, int lowerLimit = -1, int upperLimit = -1}) async {
    final limits =
        lowerLimit > 0 ? {"start": lowerLimit, "end": upperLimit} : const {};
    final body = await _encode("Playlist.GetItems", {
      "playlistid": id,
      "properties": FETCH_PLAYLIST_ITEMS,
      "limits": limits
    });
    final response = await http.post(url(player), headers: headers, body: body);
    final s = _handleHTTPResponse(response);
    if (s.isNotEmpty) {
      final parsed = await compute(jsonDecode, s);
      List<PlaylistItemModel> itemsList = [];
      final items = parsed['result']['items'];
      if (items != null && items.isNotEmpty) {
        for (int i = 0; i < items.length; i++) {
          var item = items[i];
          itemsList.add(PlaylistItemModel.fromJson(item));
        }
      }
      return itemsList;
    }
    return const [];
  }

  static Future<String> _getPlayerItem(Player player) async {
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

  static Stream<Map<String, dynamic>> playerPropertiesStream(Player p) async* {
    while (true) {
      await Future.delayed(_refreshInterval);
      final response = await getPlayerProperties(p);
      yield response.isEmpty
          ? const {"error": "No Response from remote player"}
          : response;
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
  static void navigate(Player p, String a) => http.post(url(p),
      body: jsonEncode({
        "method": "Input.ExecuteAction",
        "params": {"action": a},
        ...defParams
      }),
      headers: headers);

  static void sendTextInput(Player p,
      {required String data, bool done = true}) async {
    final body = await _encode("Input.SendText", {"text": data, "done": done});
    http.post(url(p), body: body, headers: headers);
  }

  // * Application API endpoints
  static Future<int> adjustVolume(Player player,
      {required int newVolume}) async {
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

  static Future<bool> toggleMute(Player player, [bool? value]) async {
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
  static Future<int> playPause(Player player) async {
    final body = jsonEncode({
      "method": "Player.PlayPause",
      "params": {"playerid": _playerID, "play": "toggle"},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode == 200 ? 200 : -1;
  }

  static Future<int> seek(Player player, {required double percentage}) async {
    final percent = (percentage * 100).round();
    final body = jsonEncode({
      "method": "Player.Seek",
      "params": {"playerid": _playerID, "value": percent},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode;
  }

  static Future<void> setAudioStream(Player player, {required int index}) =>
      _setPlayerStream(player, "SetAudioStream", index);

  static Future<void> setVideoStream(Player player, {required int index}) =>
      _setPlayerStream(player, "setVideoStream", index);

  static Future<void> setSubtitle(Player player, {required int index}) async {
    final body = await _encode("Player.SetSubtitle",
        {"playerid": _playerID, "subtitle": index == -1 ? "off" : index});
    http.post(url(player), headers: headers, body: body);
  }

  static Future<void> _setPlayerStream(
      Player player, String method, int index) async {
    final body = await _encode(
        "Player.$method", {"playerid": _playerID, "stream": index});
    http.post(url(player), headers: headers, body: body);
  }

  static Future<String> retrieveCachedImageURL(
      Player player, String source) async {
    final bod = await _encode("Files.PrepareDownload", {"path": source});
    final r = await http.post(url(player), headers: headers, body: bod);
    final parsed = await compute(jsonDecode, r.body);
    if (r.statusCode != 200 || parsed['error'] != null) return "";
    final path = parsed['result']['details']['path'];
    if (path == null) return "";
    return "http://${player.address}:${player.port}/" +
        parsed['result']['details']['path'];
  }

  /// Retrieve all artwork URLs from player
  static Future<void> _retrieveImageURLs(
      Player player, Map<String, dynamic> item) async {
    var art = item['art'];
    if (art != null && art.isNotEmpty) {
      Map<String, String> alreadyFetched = {};
      for (int i = 0; i < art.length; i++) {
        final key = art.keys.elementAt(i);
        if (art[key].isNotEmpty) {
          if (alreadyFetched.keys.contains(art[key])) {
            art[key] = alreadyFetched[art[key]];
          } else {
            final previous = art[key];
            art[key] = await retrieveCachedImageURL(player, art[key] ?? "");
            alreadyFetched[previous] = art[key];
          }
        }
      }
    }
  }

  static void _convertResourceURLs(Player player, Map<String, dynamic> item) {
    var art = item['art'];
    if (art != null && art.isNotEmpty) {
      Map<String, String> alreadyConverted = {};
      for (int i = 0; i < art.length; i++) {
        final key = art.keys.elementAt(i);
        if (art[key].isNotEmpty) {
          if (alreadyConverted.keys.contains(art[key])) {
            art[key] = alreadyConverted[art[key]];
          } else {
            final previous = art[key];
            art[key] = _convertResourceToImage(player, art[key]);
            alreadyConverted[previous] = art[key];
          }
        }
      }
    }
  }

  static String _convertResourceToImage(Player player, String resource) =>
      "http://" +
      "${player.address}:${player.port}/image/${Uri.encodeComponent(resource)}";

  static Future<void> skip(Player player, Map<String, dynamic> params) async {
    final body =
        await _encode("Player.Seek", {"playerid": _playerID, "value": params});
    http.post(url(player), headers: headers, body: body);
  }

  static Future<int> stop(Player player) async {
    final body = jsonEncode({
      "method": "Player.Stop",
      "params": {"playerid": _playerID},
      ...defParams
    });
    final response = await http.post(url(player), headers: headers, body: body);
    return response.statusCode;
  }

  static void toggleRepeat(Player player) async {
    final body = await _encode(
        "Player.SetRepeat", {"repeat": "cycle", "playerid": _playerID});
    await http.post(url(player), headers: headers, body: body);
  }

  // * Playlist API Endpoints
  static Future<void> swapPlaylistItems(Player player,
      {required int playListID, required int from, required int to}) async {
    final body = await _encode("Playlist.Swap",
        {"playlistid": playListID, "position1": from, "position2": to});
    await http.post(url(player), headers: headers, body: body);
  }

  static Future<void> removePlaylistItem(Player player,
      {required int location, required int playlistID}) async {
    final body = await _encode(
        "Playlist.Remove", {"playlistid": playlistID, "position": location});
    await http.post(url(player), headers: headers, body: body);
  }

  static Future<void> goTo(Player player, dynamic to) async {
    final body =
        await _encode("Player.GoTo", {"playerid": _playerID, "to": to});
    http.post(url(player), body: body, headers: headers);
  }

  static Future<void> playFile(Player player, {required String file}) async {
    final body = await _encode("Player.Open", {
      "item": {"file": file}
    });
    http.post(url(player), headers: headers, body: body);
  }

  static Future<void> enqueueItem(Player player,
      {required String source,
      String type = "file",
      int playlistID = 1}) async {
    final body = await _encode("Playlist.Add", {
      "playlistid": playlistID,
      "item": {type: source}
    });
    http.post(url(player), headers: headers, body: body);
  }

  // * Sources API Endpoints
  static Future<List<Addon>> fetchAddons(Player player,
      {String content = "unknown"}) async {
    final body = await _encode("Addons.GetAddons", {
      "content": content,
      "properties": [
        "name",
        // "version"
        // "summary",
        "description",
        // "path",
        // "author",
        "thumbnail",
        "disclaimer",
        // "broken",
        // "enabled",
        // "installed"
      ]
    });
    final r = await http.post(url(player), headers: headers, body: body);
    final parsed = jsonDecode(r.body);
    if (parsed['result']['limits']['total'] == 0) return const [];
    final addons = parsed['result']['addons'] as List<dynamic>;
    List<Addon> addonsList = [];
    for (int i = 0; i < addons.length; i++) {
      final addon = addons[i];
      if (addon['thumbnail'] != null && addon['thumbnail'].isNotEmpty) {
        addon['thumbnail'] =
            await retrieveCachedImageURL(player, addon['thumbnail']);
      }
      addonsList.add(Addon.fromJson(addon));
    }
    return addonsList;
  }

  static Future<String> getAddonDetails(Player player,
      {required String addonID}) async {
    final body = await _encode("Addons.GetAddonDetails", {
      'addonid': addonID,
      "properties": ["name", "version", "path", "disclaimer"]
    });
    final r = await http.post(url(player), headers: headers, body: body);
    return r.body;
  }

  static Future<String> executeAddon(Player player,
      {required String addonID}) async {
    final body = await _encode(
        "Addons.ExecuteAddon", {"addonid": addonID, "wait": true});
    return (await http.post(url(player), headers: headers, body: body)).body;
  }

  static Future<void> getMovies(Player player,
      //TODO: Add properties
      {required Function(dynamic) onSuccess,
      Function(String)? onError,
      List<ListFilter> filters = const [],
      ListSort sort = ListSort.defaultSort,
      ListLimits limits = const ListLimits()}) async {
    final body = await _encode("VideoLibrary.GetMovies", {
      "sort": sort.toJson(),
      "properties": FETCH_MOVIE_PROPERTIES,
      ...filters.toJson(),
      ...limits.toJson()
    });
    var j = await _postAndParse(player, body);
    final error = j['result']?['error'];
    if (error != null) {
      onError?.call(error['message']);
    } else {
      for (int i = 0; i < j['result']['movies'].length; i++) {
        j['result']['movies'][i]['type'] = "movie";
        _convertResourceURLs(player, j['result']['movies'][i]);
      }
      onSuccess.call(j['result']['movies']);
    }
  }

  static Future<void> getTVShows(Player player,
      {required Function(dynamic) onSuccess,
      Function(String)? onError,
      List<ListFilter> filters = const [],
      ListSort sort = ListSort.defaultSort,
      ListLimits limits = const ListLimits()}) async {
    final body = await _encode("VideoLibrary.GetTVShows", {
      "sort": sort.toJson(),
      "properties": FETCH_SHOW_PROPERTIES,
      ...filters.toJson(),
      ...limits.toJson()
    });
    var j = await _postAndParse(player, body);
    final error = j['result']?['error'];
    if (error != null) {
      onError?.call(error['message']);
    } else {
      for (int i = 0; i < j['result']['tvshows'].length; i++) {
        j['result']['tvshows'][i]['type'] = "tvshow";
        _convertResourceURLs(player, j['result']['tvshows'][i]);
      }
      onSuccess.call(j['result']['tvshows']);
    }
  }

  static Future<void> getTVSeasons(Player player,
      {required int tvshowID,
      Function(List<TVSeason>)? onSuccess,
      Function(String)? onError}) async {
    final body = await _encode("VideoLibrary.GetSeasons",
        {"tvshowid": tvshowID, "properties": FETCH_SEASON_PROPERTIES});
    final j = await _postAndParse(player, body);
    if (j['result']?['error'] != null) {
      onError?.call(j['result']['error']['message']);
    } else {
      print(j['result']);
      // onSuccess?.call(j['result']['sources']
      //     .map<File>((f) => File.fromJson(f, fileType: FileType.Directory))
      //     .toList());
    }
  }

  static Future<void> getFileMediaSources(Player player,
      {required String media,
      Function(List<File>)? onSuccess,
      Function(String)? onError}) async {
    final body = await _encode("Files.GetSources", {"media": media});
    final j = await _postAndParse(player, body);
    if (j['result']?['error'] != null) {
      onError?.call(j['result']['error']['message']);
    } else {
      onSuccess?.call(j['result']['sources']
          .map<File>((f) => File.fromJson(f, fileType: FileType.Directory))
          .toList());
    }
  }

  static Future<void> getDirectory(Player player,
      {required String path,
      Function(List<File>)? onSuccess,
      Function(String)? onError}) async {
    final body = await _encode("Files.GetDirectory", {"directory": path});
    final r = await _post(player, body);
    final j = await compute(jsonDecode, r.body);
    if (j['result']?['error'] != null) {
      onError?.call(j['result']['error']['message']);
    } else if (j['result']['limits']['total'] > 0) {
      var files = j['result']['files'].map<File>((f) => File.fromJson(f));
      onSuccess?.call(files.toList());
    } else {
      onSuccess?.call(const []);
    }
  }

  // * External API Endpoints
  static Future<TMDBItem> fetchTMDBMovie(String imdbID) async {
    final theaders = {"api_key": _tmdbApiKey};
    final response = await http
        .get("https://api.themoviedb.org/3/movie/$imdbID?api_key=$_tmdbApiKey");
    final parsed = await compute(jsonDecode, response.body);
    return TMDBItem.fromJson(parsed);
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
