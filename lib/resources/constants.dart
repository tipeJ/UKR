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
  "art",
  "genre",
  "year"
  // "cast"
];

const FETCH_PLAYLIST_ITEMS = ["file"];
