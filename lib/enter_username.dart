import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterUsername extends StatefulWidget {

  const EnterUsername({super.key, required this.setUsername});
      final Function setUsername;



  @override
  State<EnterUsername> createState() => _EnterUsername();
}

class _EnterUsername extends State<EnterUsername> {
  TextEditingController usernameController = TextEditingController();

  void saveUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', usernameController.text);
    widget.setUsername(usernameController.text);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.lightGreen,
              title: Image.asset('assets/images/logo.png'),
            ),
            body: Center(
                child: ListView(children: <Widget>[
                 const Padding(
                        padding: EdgeInsets.all(16)),
              TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Enter your username or enter a new username:')),
              ElevatedButton(
                onPressed: saveUsername,
                //Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
               // AddPlant(plants: widget.plants, picPath: widget.picPath, username: usernameController.text)));
                
                child: const Text('Submit'),
              )
            ]))));
  }
}
