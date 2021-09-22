// * Routes
// ** Player Navigation Routes
const ROUTE_CURRENT_ITEM_DETAILS = "current_item_details";
const ROUTE_PAGES_SCREEN = "pages_screen";
const ROUTE_CAST_SCREEN = "cast_screen";
// ** Main Navigation Routes
const ROUTE_MAIN = "route_main_screen";
const ROUTE_PLAYERS = "route_players_screen";
const ROUTE_ADD_PLAYER = "route_add_player";
// ** Content navigation Routes
const ROUTE_CONTENT_ADDONS = "content_addons";
const ROUTE_CONTENT_FILES = "content_files";
const ROUTE_CONTENT_MOVIES = "content_movies";
const ROUTE_CONTENT_MOVIE_SEARCH = "content_movies_search";
const ROUTE_CONTENT_SHOWS = "content_tvshows";
const ROUTE_CONTENT_SHOW_SEARCH = "content_shows_search";
const ROUTE_CONTENT_VIDEOITEM_DETAILS = "content_videoitem_details";
const ROUTE_CONTENT_TVSHOW_DETAILS = "content_tvshow_details";
const ROUTE_CONTENT_SEASON_DETAILS = "content_season_details";
const ROUTE_ADDON_DETAILS = "content_addon_details";
const ROUTE_FILELIST = "content_filelist";

// ** Hero Animation Tags
const HERO_CURRENT_ITEM_HEADLINE = "hero_current_headline";
const HERO_CURRENT_ITEM_CAPTION = "hero_current_caption";
const HERO_CURRENT_ITEM_YEAR = "hero_current_year";

const HERO_CONTENT_ADDONS_HEADER = "hero_content_addons_header";
const HERO_CONTENT_ADDON_TITLE = "hero_content_addon_title";
const HERO_CONTENT_FILES_HEADER = "hero_content_files_header";
const HERO_CONTENT_MOVIES_HEADER = "hero_content_movies_header";
const HERO_CONTENT_MOVIES_POSTER = "hero_content_movies_poster";
const HERO_CONTENT_SERIES_POSTER = "hero_content_series_poster";
const HERO_CONTENT_TV_HEADER = "hero_content_tv_header";

// * Kodi constants
// ** Add-On information
const KODI_PLUGIN_TYPE_SCRIPT = "xbmc.python.script";
const KODI_PLUGIN_TYPE_PLUGINSOURCE = "xbmc.python.pluginsource";

// * Hive Data
const BOX_PLAYERS = "box_players";

// * Cached information
const BOX_CACHED = "box_cached";
const DATA_MOST_RECENT_PLAYERID = "mostRecentPlayerID";

// * Fetching data
const FETCH_ITEM_PROPERTIES = [
  "director",
  "year",
  "disc",
  "albumartist",
  "art",
  "showtitle",
  "episode",
  "season",
  "episodeguide",
  "description",
  "albumreleasetype",
  "duration",
  "streamdetails",
  "file",
  "plot",
  "plotoutline",
  "tagline",
  "tag",
  "trailer",
  "playcount",
  "originaltitle",
  "genre",
  "studio",
  "imdbnumber",
  "rating",
  "cast"
];
const FETCH_MOVIE_PROPERTIES = [
  "studio",
  "title",
  "director",
  "runtime",
  "art",
  "genre",
  "year",
  "file",
  "tagline",
  "plot",
  "plotoutline",
  "rating",
  "mpaa"
  // "cast"
];
const FETCH_SHOW_PROPERTIES = [
  "title",
  "genre",
  "year",
  "rating",
  "plot",
  "studio",
  "file",
  "art",
];
const FETCH_SEASON_PROPERTIES = [
  "season",
  "title",
  "art",
  "watchedepisodes",
  "showtitle",
  "tvshowid",
  "userrating",
];
const FETCH_EPISODE_PROPERTIES = [
  "art",
  "file",
  "title",
  "director",
  "writer",
  "streamdetails",
  "plot",
  "rating",
  "season",
  "episode",
  "showtitle"
];

const FETCH_PLAYLIST_ITEMS = ["file"];

// * UI Constants
const double listPosterRatio = 9 / 16.0;
const double gridPosterMaxWidth = 150;

const PLAYLIST_VIDEOS_ID = 1;
const PLAYLIST_MUSIC_ID = 0;
const PLAYLIST_PICTURES_ID = 2;
