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

  bool isDead = false;

  void addRow() async {
    var data = {
      'botanic_name': widget.plant['botanic_name'],
      'common_name': widget.plant['common_name'],
      'quantity': widget.plant['quantity'],
      'notes': widget.plant['notes'],
      'living': isDead ? 'N' : 'Y',
      'type': widget.plant['plant_type'],
      'plantId': widget.plant['plant_id'],
      'planted_as': widget.plant['planted_as'],
      'sun': widget.plant['sun'],
      'wet': widget.plant['wet'],
      'blooms': widget.plant['blooms'],
      'maintenance_schedule': widget.plant['maintenance_schedule'],
      'north_american_native': widget.plant['naNative'],
      'nursery': widget.plant['nursery'],
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
        body: Align(
            child: ListView(children: <Widget>[
          Text(
            '''
            Editing:
            ${widget.plant['botanic_name']}
            ${widget.plant['common_name']}''',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
            textAlign: TextAlign.center,
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
                        widget.plant['common_name'] = value;
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
                    TextFormField(
                      initialValue: widget.plant['plant_type'],
                      decoration: const InputDecoration(
                        labelText: 'Type',
                      ),
                      onChanged: (value) {
                        widget.plant['plant_type'] = value;
                      },
                    ),
                    TextFormField(
                      initialValue: widget.plant['planted_as'],
                      decoration: const InputDecoration(
                        labelText: 'Planted As',
                      ),
                      onChanged: (value) {
                        widget.plant['plant_as'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['sun'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'Sun',
                      ),
                      onChanged: (value) {
                        widget.plant['sun'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['wet'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'Wet',
                      ),
                      onChanged: (value) {
                        widget.plant['wet'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['blooms'],
                      decoration: const InputDecoration(
                        labelText: 'Blooms',
                      ),
                      onChanged: (value) {
                        widget.plant['blooms'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['maintenance_schedule'],
                      decoration: const InputDecoration(
                        labelText: 'Maintenance',
                      ),
                      onChanged: (value) {
                        widget.plant['maintenance_schedule'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['north_american_native'].toString(),
                      decoration: const InputDecoration(
                        labelText: 'North American Native',
                      ),
                      onChanged: (value) {
                        widget.plant['north_american_native'] = value;
                      },
                    ),TextFormField(
                      initialValue: widget.plant['nursery'],
                      decoration: const InputDecoration(
                        labelText: 'Nursery',
                      ),
                      onChanged: (value) {
                        widget.plant['nursery'] = value;
                      },
                    ),
                  ],
                ),
              )),
          ElevatedButton(
              onPressed: _submitForm, child: const Text('Save Changes')),
        ])));
  }
}
