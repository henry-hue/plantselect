import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:convert';
import 'dart:io';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccount();
}

class _CreateAccount extends State<CreateAccount> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();
  String? errorMessage;

  void createAccount() async {
    // widget.createAccount(usernameController.text, passwordController.text);
    // API call here
    var body = {
      'username': usernameController.text,
      'password': passwordController.text,
      'password2': passwordController2.text,
      'name' : nameController.text,
      'email' : emailController.text,
    };

    var resp = await http.post(
      Uri.parse('${Constants.apiUrl}/api/user/create-account'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );
    var data = jsonDecode(resp.body);
    if(data['success'] == true) {
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = data['errors'].join('\n');
      });
    }
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
                  controller: emailController,
                  decoration: const InputDecoration(
                      labelText:
                          'Enter your email:')
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                      labelText:
                          'Enter your name:')
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                      labelText:
                          'Enter desired username:')
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
                TextFormField(
                  controller: passwordController2,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(
                      labelText:
                          'Confirm your password:')
                ),
                if((errorMessage ?? '') != '') 
                  Icon(Icons.error_outline, color: Colors.red),
                if((errorMessage ?? '') != '')
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      errorMessage ?? '',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                Center(
                  child: Row(
                    children:[
                      ElevatedButton(
                        onPressed: createAccount,
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        // AddPlant(plants: widget.plants, picPath: widget.picPath, username: usernameController.text)));

                        child: const Text('Create Account'),
                      ),
                      ElevatedButton(
                        onPressed: () {Navigator.pop(context);},
                        //Navigator.of(context).push(MaterialPageRoute(builder: (context) =>
                        // AddPlant(plants: widget.plants, picPath: widget.picPath, username: usernameController.text)));

                        child: const Text('Return to Login'),
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
