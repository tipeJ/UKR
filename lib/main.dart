// @dart=2.9
// Uncomment above to build with sound null safety.
import 'package:flutter/material.dart';
import 'package:UKR/resources/resources.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:UKR/ui/screens/screens.dart';
import 'package:UKR/ui/providers/providers.dart';
import 'package:provider/provider.dart';
import 'package:UKR/models/models.dart';
import 'package:get_it/get_it.dart';
import 'package:UKR/utils/utils.dart';
import 'ui/dialogs/dialogs.dart';

void main() async {
  Hive.registerAdapter(PlayerAdapter());
  await Hive.initFlutter();
  await Hive.openBox<Player>(BOX_PLAYERS);
  await Hive.openBox(BOX_CACHED);

  // final x =
  //     Player(address: "192.168.100.16", port: 8080, name: "ASD", id: "SD");
  //     await ApiProvider.getVideoLibraryItems(x, method: "GetMovies", onSuccess: (s) => print("SUCCESS: $s"), onError: (s) => print("ERROR: $s"));

  final getIt = GetIt.instance;
  getIt.registerLazySingleton(() => DialogService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.  @override

  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'UKR DEMO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
        ),
        home: DialogManager(child: MyHomePage()));
  }
}

class MyHomePage extends StatefulWidget {
  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return ChangeNotifierProvider<PlayersProvider>(
      create: (context) => PlayersProvider(),
      builder: (context, widget) => MainScreen(),
    );
  }
}
