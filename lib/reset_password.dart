import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';
import 'dart:convert';
import 'dart:io';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPassword();
}

class _ResetPassword extends State<ResetPassword> {
  TextEditingController emailController = TextEditingController();
  TextEditingController resetCode = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordController2 = TextEditingController();

  bool resetSuccess = false;
  int? activeUserId;
  List<Map<String, dynamic>> userData = [];

  void sendPasswordReset() async {
    if(passwordController.text != passwordController2.text) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('The passwords do not match.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text('OK'),
              ),
            ],
          );
        },  
      );
    } else {
      var body = {
        'userId': activeUserId,
        'resetCode': resetCode.text,
        'password': passwordController.text,
      };

      var resp = await http.post( 
        Uri.parse('${Constants.apiUrl}/api/user/set-new-password'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );

      var data = jsonDecode(resp.body);
      if(data['success']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Success'),
              content: Text('The Password has been successfully reset.  Press OK to login using the new password.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    Navigator.of(context).pop(); // Return to Login
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },  
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Server Error'),
              content: Text(data['errors']),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void resetPassword() async {
    // widget.createAccount(usernameController.text, passwordController.text);
    // API call here
    var body = {
      'email' : emailController.text,
    };

    var resp = await http.post(
      Uri.parse('${Constants.apiUrl}/api/user/reset-password'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',
      },
      body: jsonEncode(body),
    );
    List<dynamic> data = jsonDecode(resp.body);
    setState(() {
      userData = data.map((user) => user as Map<String, dynamic>).toList();
      if(userData.isNotEmpty) {
        activeUserId = userData[0]['userId'];
      }
    });
  }

  void validateResetCode() {
    Map<String, dynamic> user = userData.where((user) => user['userId'] == activeUserId).toList()[0];
    setState(() {
      resetSuccess = resetCode.text == user['resetCode'];
    });
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
                if(userData.isEmpty) 
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                        labelText:
                            'Enter the email address associated with your account:')
                  ),
                
                if(resetSuccess)
                  Column(
                    children: [
                      Text('Enter new password user username ' + userData.where((user) => user['userId'] == activeUserId).toList()[0]['username']),
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Enter new password:'
                        ),
                      ),
                      TextFormField(
                        controller: passwordController2,
                        obscureText: true,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          labelText: 'Confirm new password:'
                        ),
                      ),
                    ]
                  ),
              
                if(userData.isNotEmpty && !resetSuccess) 
                  if(userData.length == 1)
                    Expanded(
                      child: Text('Username: ${userData[0]['username']}'),
                    ),
                  if(userData.length > 1 && !resetSuccess)
                    Column (
                      children: <Widget> [
                        Text('There are multiple User Names associated with you email address. Choose the account you are resetting.'),
                        SizedBox(height: 10),
                        Row(children: [
                          Expanded(
                            child:  DropdownButton(
                              onChanged: ((value) {
                                setState(() {
                                  activeUserId = value; 
                                });
                              }),
                              items: userData.map((user) {
                                return DropdownMenuItem<dynamic> (
                                  value: user['userId'],
                                  child: Text(user['username']),
                                );
                              }).toList(),
                              value: activeUserId, 
                            ),
                          ),
                        ]),
                      ],
                    ),

                if(userData.isNotEmpty && !resetSuccess) 
                  TextFormField(
                    controller: resetCode,
                    decoration: const InputDecoration( 
                      labelText: 'Enter reset code from email',
                    )
                  ),
                Center(
                  child: Row(
                    children:[
                      if(resetSuccess)
                        ElevatedButton(
                          onPressed: sendPasswordReset,
                          child: const Text('Reset Password'),
                        ),  
                      if(userData.isEmpty)
                        ElevatedButton(
                          onPressed: resetPassword,
                          child: const Text('Send Reset Code to Email'),
                        ),  
                        if(userData.isNotEmpty && !resetSuccess)
                          ElevatedButton(
                           onPressed: validateResetCode,
                           child: const Text('Validate Code'),
                          ),
                      ElevatedButton(
                        onPressed: () {Navigator.pop(context);},
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
