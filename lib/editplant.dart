import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  TextEditingController quantityController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  bool isDead = false;
  String living = 'Alive';

  void addRow() async {
    var data = {
      'plantId': widget.plant['plant_id'],
      'quantity': quantityController.text,
      'notes': notesController.text,
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

    // // init GSheets
    // final gsheets = GSheets(credentials);
    // // fetch spreadsheet by its id
    // final ss = await gsheets.spreadsheet(spreadsheetId);

    // // get worksheet by its title
    // var sheet = ss.worksheetByTitle(widget.username);
    // // create worksheet if it does not exist yet
    // sheet ??= await ss.addWorksheet(widget.username);

    // if (isDead) {
    //   living = 'Dead';
    // }

    // var index = widget.plant['plant_id'];
    // //await sheet.values.map.appendRow(newRow);
    // await sheet.values
    //     .insertValueByKeys(living, columnKey: 'Living', rowKey: index);
    // await sheet.values.insertValueByKeys(quantityController.text,
    //     columnKey: 'Quantity', rowKey: index);
    //     await sheet.values.insertValueByKeys(notesController.text,
    //     columnKey: 'Notes', rowKey: index);
  }

  void _submitForm() {
    addRow();

    Navigator.pop(context);
  }

  XFile? imageFile;

  selectFile() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1800, maxWidth: 1800);

    if (file != null) {
      setState(() {
        imageFile = XFile(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.plant);
    quantityController.text = widget.plant['quantity'].toString();
    notesController.text = widget.plant['notes'] ?? '';
    isDead = widget.plant['living'] == 'N';

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Image.asset('assets/images/logo.png'),
        ),
        body: Center(
            child: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20),
            //TODO: Check for empty nursery before displaying in title
            child: Text(
                '''Edit the ${widget.plant['plant_name']} from ${widget.plant['nursery']}''',
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
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                      ),
                    ),
                    TextFormField(
                      controller: notesController,
                      // initialValue: widget.plant['notes'] ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
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
