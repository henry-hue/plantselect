// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'plant.dart';
import 'credentials.dart';
import 'package:gsheets/gsheets.dart';
import 'dart:io';

class AddPlant extends StatefulWidget {
  const AddPlant({super.key, required this.plants, required this.picPath, required this.username});
  final List<Plant> plants;
  final Directory? picPath;
  final String username;

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();
  //final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  //TextEditingController DateController = TextEditingController();
  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();

  bool isAlive = false;
  bool isSeed = false;

  void addRow() async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);

    // get worksheet by its title
    var sheet = ss.worksheetByTitle(widget.username);
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('new sheet by henry');

    DateTime now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    String justDate = date.toString().substring(0, 10);
    //await sheet.values.insertValue(DateController.text, column: 1, row: 2);
    final newRow = {
      '1' : '=IF(B1<>"", ROW(),)',
      'Date': justDate,
      'Plant': plantController.text,
      'Living': isAlive,
      'Quantity': quantityController.text,
      'Nursery': nurseryController.text,
      'Seed': isSeed
    };
    await sheet.values.map.appendRow(newRow);
  }

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {
    
    addRow();
    Navigator.pop(context);

  }

  getRowCount() async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);
    // get worksheet by its title
    var sheet = ss.worksheetByTitle('henry-hue');
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet('henry-hue');
    var row = await sheet.values.lastRow(length: 1);
    return int.parse(row![0]) + 1;
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
    final Directory dir = await getApplicationDocumentsDirectory();

    // getting a directory path for saving
    final String path = dir.path;

    File image = File(imageFile!.path);
    var name = await getRowCount();

    await image.copy('$path/$name');
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
            appBar: AppBar(
          // TRY THIS: Try changing the color here to a specific color (to
          // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
          // change color while the other colors stay the same.
          backgroundColor: Colors.lightGreen,
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Image.asset('assets/images/logo.png'),
        ),
            body: Center(
                child: ListView(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                  SearchAnchor(builder:
                      (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: controller,
                      padding: const WidgetStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      leading: const Icon(Icons.search),
                    );
                  }, suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                    String searchText = controller.text;
                    List<Plant> filteredPlants = widget.plants
                        .where((plant) => plant.values[0]
                            .toLowerCase()
                            .contains(searchText.toLowerCase()))
                        .toList();
                    return List<ListTile>.generate(
                      filteredPlants.length,
                      (int index) {
                        final String item = filteredPlants[index].values[0];
                        return ListTile(
                            title: Text(item),
                            onTap: () {
                              plantController.text = item;
                              controller.closeView(plantController.text);
                            });
                      },
                    );
                  }),
                  Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            TextFormField(
                              controller: plantController,
                              decoration: const InputDecoration(
                                  labelText: 'Plant Name'),
                            ),
                            TextFormField(
                              controller: quantityController,
                              decoration: const InputDecoration(
                                labelText: 'Quantity',
                              ),
                            ),
                            TextFormField(
                              controller: nurseryController,
                              decoration: const InputDecoration(
                                labelText: 'Nursery',
                              ),
                            ),
                            FormField<bool>(builder: (state) {
                              return CheckboxListTile(
                                  value: isAlive,
                                  title: const Text('Living Plant'),
                                  onChanged: (value) {
                                    setState(() {
                                      //save checkbox value to variable that store terms and notify form that state changed
                                      isAlive = !isAlive;
                                      state.didChange(value);
                                    });
                                  });
                            }),
                            FormField<bool>(builder: (state) {
                              return CheckboxListTile(
                                  value: isSeed,
                                  title: const Text('Seed'),
                                  onChanged: (value) {
                                    setState(() {
                                      //save checkbox value to variable that store terms and notify form that state changed
                                      isSeed = !isSeed;
                                      state.didChange(value);
                                    });
                                  });
                            }),
                          ],
                        ),
                      )),
                  if (imageFile == null)
                    ElevatedButton(
                      onPressed: selectFile,
                      child: const Text('Next: take picture'),
                    ),
                  if (imageFile != null)
                    Image.file(File(imageFile!.path)),


                    ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Submit Plant'),
                    )
                ])));
  }
}
