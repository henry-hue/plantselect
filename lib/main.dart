import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'plant.dart';
import 'myplants.dart';
import 'enter_username.dart';
import 'constants.dart';

const primaryColor = Color(0xFF046a38);


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
          textTheme: TextTheme(
      displayLarge: const TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.bold,
      ),
      // ···
      titleLarge: GoogleFonts.oswald(
        fontSize: 30,
        fontStyle: FontStyle.italic,
      ),
      bodyMedium: GoogleFonts.merriweather(),
      displaySmall: GoogleFonts.pacifico(),
    ),
  primaryColor: primaryColor,
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
  Map<String, dynamic> plantByBotanicName = {};
  Directory? picPath;
  String? username;
  int? userId;

  getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setUsername(prefs.getString('username'), prefs.getString('password'));
  }

  Future<bool> setUsername(String? enteredUsername, String? password) async {
    if(enteredUsername != null) {
      //Look up name from DB
      var body = {
        'username': enteredUsername,
        'password': password,
      };

      var resp = await http.post(
        Uri.parse('${Constants.apiUrl}/api/user/log-in'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );
      var data = jsonDecode(resp.body);
      if(data['success'] == true) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', enteredUsername);
        await prefs.setString('password', password!);
        setState(() {
          username = data['name'];
          userId = data['user_id'];
        });
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  Future directory() async {
    if (!kIsWeb) {
      picPath = await getApplicationDocumentsDirectory();
    }
  }

  @override
  void initState() {
    super.initState();
    getUsername();
    fetchPlants();
    directory();
  }


  Future <void> fetchPlants() async {
    final  resp = await http.get(
      Uri.parse('${Constants.apiUrl}/api/plants/list'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}'},
    );  
    
    List<dynamic> data = jsonDecode(resp.body);

    setState(() {
       for (var plantData in data) {
         plants.add(Plant.fromJson(plantData));
         //plantByBotanicName[plantData['botanic_name']] = plantData;
       }
    });
  }

  void logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    setState(() {
      username = null;
      userId = null;
    });
  }

  void deleteAccount() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

var data = {
      'username': prefs.get('username'),
     
    };

        //await prefs.remove('username');


    var response = 
    print('api call run');
    await http.post(
      Uri.parse('${Constants.apiUrl}/api/plants/delete-user'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );
 
    setState(() {
      username = null;
      userId = null;
    });
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
        home: MyPlants(plants: plants, picPath: picPath, username: username!, userId: userId!, logout: logout, deleteAccount: deleteAccount),
      );
    }
  }
}
