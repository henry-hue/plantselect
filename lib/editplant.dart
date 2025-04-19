import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'main.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;

class EditPlant extends StatefulWidget {
  const EditPlant(
      {super.key,
      required this.plant,
      required this.username,
      required this.userId});
  final Map<String, dynamic> plant;
  final String username;
  final int userId;

  @override
  State<EditPlant> createState() => _EditPlantState();
}

class _EditPlantState extends State<EditPlant> {
  final _formKey = GlobalKey<FormState>();
  // TextField Controllers
  TextEditingController plantController = TextEditingController();

  bool isDead = false;

  void addRow() async {
    var data = {
      'botanic_name': widget.plant['botanic_name'],
      'common_name': widget.plant['common_name'],
      'plantId': widget.plant['plant_id'],
      'quantity': widget.plant['quantity'],
      'notes': widget.plant['notes'],
      'living': isDead ? 'N' : 'Y',
    };

    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/api/plants/update-user-plant'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  void _submitForm() {
    addRow();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Image.asset('assets/images/logo.png'),
        ),
        body: Center(
            child: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20),
            child: Text('''Edit the ${widget.plant['botanic_name']}''',
                style: Theme.of(context).textTheme.titleLarge!),
          ),
          Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      initialValue: widget.plant['botanic_name'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'Botanic Name',
                      ),
                      onChanged: (value) {
                        widget.plant['botanic_name'] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: widget.plant['common_name'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'Common Name',
                      ),
                      onChanged: (value) {
                        widget.plant['commmon_name'] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: widget.plant['quantity'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                      onChanged: (value) {
                        widget.plant['quantity'] = int.parse(value);
                      },
                    ),
                    TextFormField(
                      initialValue: widget.plant['notes'],
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                      onChanged: (value) {
                        widget.plant['notes'] = value;
                      },
                    ),
                    FormField<bool>(builder: (state) {
                      return CheckboxListTile(
                          value: isDead,
                          title: const Text('Plant is Dead'),
                          onChanged: (value) {
                            setState(() {
                              //save checkbox value to variable that store terms and notify form that state changed
                              isDead = !isDead;
                              widget.plant['living'] = isDead ? 'N' : 'Y';
                              state.didChange(value);
                            });
                          });
                    }),
                  ],
                ),
              )),
          ElevatedButton(
              onPressed: _submitForm, child: const Text('Save Changes')),
        ])));
  }
}
