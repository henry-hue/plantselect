import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plant.dart';
import 'allplants.dart';
import 'myplants.dart';
import 'enter_username.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PlantSelect',
      theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a blue toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          ),
      home: const MyHomePage(title: 'PlantSelect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPageIndex = 0;
  List<Plant> plants = [];
  Map<String, Plant> plantByBotanicName = {};
  Directory? picPath;
  String? username;

  getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.remove('username');
    setUsername(prefs.getString('username'));
    
  }

  setUsername(String? name) {
    setState(() {
      username = name;
    });
  }

  Future directory() async {
    picPath = await getApplicationDocumentsDirectory();
  }

  @override
  void initState() {
    super.initState();
    getUsername();
    fetchPlants();
    directory();
  }

  Future<void> fetchPlants() async {
    const String url =
        'https://script.googleusercontent.com/macros/echo?user_content_key=_B-W-AHmjR26KU5dTCw1S-B2DHZEuws01wTIWfteAhh1hJmlRPaKDGo9Y28yztqfS4hpvU0auyjWeXE6R04QW4DiUHEKgbgXm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnO2U0Bl7BUAklHHeNRDrUcIoEcGPmrrlK_ulnafppH3w7o8FAM3ee_EkorPOGtTMgbRERG-Fn53JVefYCVkuXGQB2G7xa3afN9z9Jw9Md8uu&lib=MxnqXoKCpdNq7DADJrJEvDBtmPjijWW5o';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<dynamic> values = data.sublist(1);
      setState(() {
        plants = values.map((json) => Plant.fromJson(json)).toList();
        plants.map((plant) => plantByBotanicName[plant.values[1]] = plant);
      });
    } else {
      throw Exception('Failed to load plants');
    }
  }

void goToAddPlant() {

setState(() {
  
});

 Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AddPlant(plants: plants, picPath: picPath, username: username!),
                    ),
                  );
}


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    if (plants.isEmpty) {
      // Wait until fetch completes
      return const Center(child: CircularProgressIndicator());
    }

    if (username == null) {
      return EnterUsername(setUsername: setUsername);
    } else {
      return MaterialApp(
        //key: _scaffoldKey,
        home: Scaffold(
        appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Colors.lightGreen,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Image.asset('assets/images/logo.png'),
        ),

        floatingActionButton: FloatingActionButton(
        onPressed: goToAddPlant,
        tooltip: 'Add Plant',
        child: const Icon(Icons.add),
      ),

        body: <Widget>[
          Card(
            child:
                MyPlants(plants: plants, picPath: picPath, username: username!),
          ),
        ][currentPageIndex],
      )
      );
    }
  }
}
