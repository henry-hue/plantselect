import 'package:flutter/material.dart';
import 'package:plantselect/create_account.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

class EnterUsername extends StatefulWidget {
  const EnterUsername({super.key, required this.setUsername});
  final Function setUsername;

  @override
  State<EnterUsername> createState() => _EnterUsername();
}

class _EnterUsername extends State<EnterUsername> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? errorMessage;

  void saveUsername() async {
    if(! await widget.setUsername(usernameController.text, passwordController.text)) {
      setState(() {
        errorMessage = 'Incorrect Username or Password';
      });
    }
  }

  void createAccount() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateAccount())).then((value) {
            setState(() {});
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: primaryColor,
            title: Image.asset('assets/images/logo.png'),
          ),
          body: Center(
            child: Padding( padding: const  EdgeInsets.all(24),
              child: ListView(children: <Widget> [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      labelText:
                          'Enter your username:')
                ),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText:
                          'Enter your password:')
                ),
                if((errorMessage ?? '') != '')
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage ?? '',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Center( 
                  child:Row(
                    children: [
                      ElevatedButton(
                        onPressed: saveUsername,
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        // AddPlant(plants: widget.plants, picPath: widget.picPath, username: usernameController.text)));

                        child: const Text('Log In'),
                      ),
                      ElevatedButton(
                        onPressed: createAccount,
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        // AddPlant(plants: widget.plants, picPath: widget.picPath, username: usernameController.text)));

                        child: const Text('Create Account'),
                      )
                    ],
                  ),
                ),
              ]
            )
          )
        )
      )
    );
  }
}
