import 'package:UKR/models/models.dart';
import 'package:UKR/resources/resources.dart';
import 'package:UKR/ui/dialogs/dialogs.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:UKR/ui/widgets/widgets.dart';
import 'package:UKR/utils/utils.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class RemoteScreen extends StatelessWidget {
  static final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return DropTarget(
        onDragEntered: (details) {
          print("drag entered");
        },
        onDragDone: (details) {
          print("drag done");
          // Reveal dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("File"),
              actions: <Widget>[
                TextButton(
                  child: Text("Enqueue"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Play"),
                  onPressed: () {},
                ),
              ],
            ),
          );
        },
        child: WillPopScope(
            onWillPop: _onWillPop,
            child: Selector<UKProvider, double>(
                selector: (p0, p1) => p1.currentTemporaryVolume,
                builder: (_, data, __) => Theme(
                    data: Theme.of(context).copyWith(
                        // TODO: Add dynamic color logic here.
                        // canvasColor: Colors.green.withOpacity(data / 100),
                        // backgroundColor: Colors.blue.withOpacity(data / 100),
                        // appBarTheme:
                        //     AppBarTheme(color: Colors.red.withOpacity(data / 100))
                        ),
                    child: Scaffold(
                      appBar: _buildAppBar(context),
                      drawer: Drawer(child: _PlayersBar()),
                      bottomSheet: RemoteControlsBar(),
                      body: Stack(
                        children: [
                          BackgroundImageWrapper(),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: kBottomNavigationBarHeight),
                            child: Navigator(
                              observers: [HeroController()],
                              key: navKey,
                              initialRoute: ROUTE_PAGES_SCREEN,
                              onGenerateRoute: RemoteRouter.generateRoute,
                            ),
                          ),
                        ],
                      ),
                    )))));
  }

  // Function for willpop
  Future<bool> _onWillPop() async {
    bool popped = await navKey.currentState?.maybePop() ?? false;
    if (!popped && navKey.currentContext != null) {
      // We do not want to exit the app via the back button. Instead, we want to
      // pop the route or open the drawer.
      Scaffold.of(navKey.currentContext!).openDrawer();
    }
    return Future.value(false);
  }

  AppBar _buildAppBar(BuildContext context) {
    Widget title;
    List<Widget> actions = [];
    final player = context.watch<PlayersProvider>().selectedPlayer;
    const playerActions = ["Refresh", "Send Text"];
    if (player == null) {
      title = const Text("NO PLAYER");
    } else {
      title = Selector<UKProvider, Tuple2<String?, ConnectionStatus>>(
          selector: (_, p) => Tuple2(p.socketCloseReason, p.connectionStatus),
          builder: (_, errors, __) {
            String? status;
            Function() onTap = () async {
              final result = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("Actions"),
                        contentPadding: const EdgeInsets.all(0),
                        titlePadding: const EdgeInsets.all(10.0),
                        content: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          height: playerActions.length * 50.0,
                          child: ListView(
                              children: playerActions
                                  .map<Widget>((a) => ListTile(
                                      title: Text(a),
                                      onTap: () {
                                        Navigator.of(context).pop(a);
                                      }))
                                  .toList()),
                        ),
                      ));
              switch (result) {
                case "Send Text":
                  final input = Input(
                      InputType.Keyboard, "Send Text to ${player.name}", "");
                  DialogService ds = GetIt.instance<DialogService>();
                  var dialogResult = await ds.showInputDialog(input);
                  if (dialogResult != null)
                    ApiProvider.sendTextInput(player, data: dialogResult);
                  break;
                case "Refresh":
                  context.read<UKProvider>().initialize(player);
                  break;
              }
            };
            if (errors.item2 == ConnectionStatus.Unauthorized) {
              status = "Unauthorized";
            } else if (errors.item1 != null ||
                errors.item2 == ConnectionStatus.Disconnected) {
              status = errors.item1 ?? "Disconnected";
              onTap = () async {
                context.read<UKProvider>().reconnect();
              };
            } else if (errors.item2 == ConnectionStatus.Reconnecting)
              status = "Reconnecting";
            return InkWell(
                onTap: onTap,
                child: Container(
                  height: kBottomNavigationBarHeight,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(player.name),
                      AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeIn,
                          height: status != null ? 15.0 : 0,
                          child: status != null
                              ? Text(status,
                                  style: Theme.of(context).textTheme.caption)
                              : Container())
                    ],
                  ),
                ));
          });
      actions.add(_PlayerPowerOptions());
    }
    return AppBar(
        leading: IconButton(
            // TODO: Add animated icon for menu/ back button.
            icon: const Icon(Icons.arrow_back),
            onPressed: _onWillPop),
        centerTitle: true,
        title: title,
        actions: actions);
  }
}

class _PlayerPowerOptions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Selector<UKProvider, Map<String, bool>>(
        selector: (context, provider) => provider.systemProps,
        builder: (_, values, __) {
          if (values.values.contains(true)) {
            return PopupMenuButton<String>(
                icon: const Icon(Icons.power_settings_new),
                tooltip: "Power Menu",
                onSelected: (newValue) {
                  context.read<UKProvider>().toggleSystemProperty(newValue);
                },
                itemBuilder: (_) => values.keys.map((String property) {
                      return PopupMenuItem<String>(
                          value: property,
                          enabled: values[property] ?? false,
                          child: Text(property.substring(3).capitalize()));
                    }).toList());
          }
          return IconButton(
              icon: Icon(Icons.power_settings_new, color: Colors.transparent),
              onPressed: () {});
        });
  }
}

class _PlayersBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayersProvider>();
    final players = provider.players;
    final currentPlayer = provider.selectedPlayer;
    bool compact = isDesktop();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverSafeArea(
                sliver: SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Players",
                          style: Theme.of(context).textTheme.headline5),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            Navigator.of(context).pushNamed(ROUTE_PLAYERS),
                      )
                    ],
                  ),
                )),
              ),
              SliverList(
                  delegate: SliverChildListDelegate(
                      List<PlayerListItem>.generate(
                          players.length,
                          (i) => PlayerListItem(players[i],
                              compact: compact,
                              current: players[i] == currentPlayer)))),
              SliverToBoxAdapter(
                  child: InkWell(
                      onTap: () async {
                        context.read<PlayersProvider>().resetSearchState();
                        final result = await Navigator.of(context)
                            .pushNamed(ROUTE_ADD_PLAYER);
                        if (result != null) {
                          context
                              .read<PlayersProvider>()
                              .addPlayer(result as Player);
                        }
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: const Text("Add Player",
                              style: TextStyle(fontWeight: FontWeight.w200)))))
            ],
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text("UKR (ALPHA)",
                    style: TextStyle(fontWeight: FontWeight.w200)),
                IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () =>
                        Navigator.of(context).pushNamed(ROUTE_SETTINGS))
              ],
            ))
      ],
    );
  }
}
