// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'credentials.dart';
import 'package:gsheets/gsheets.dart';
import 'dart:io';
import 'main.dart';
import 'package:geolocator/geolocator.dart';
import 'constants.dart';

Future<String> get _photoLibrary async {
  final base = await getApplicationDocumentsDirectory();
  final directory =
      await Directory("${base.path}/images/").create(recursive: true);
  return directory.path;
}

Future<File> getFile(String name) async {
  if (kIsWeb) {
    return File("");
  }
  final path = await _photoLibrary;
  return File('$path/$name');
}

Future<File> copyFile(File src, File dest) async {
  return src.copySync(dest.path);
}

class AddPlant extends StatefulWidget 
{
  const AddPlant({
    super.key,
    required this.plants,
    required this.picPath,
    required this.username,
    required this.userId,
  });
  final List<Plant> plants;
  final Directory? picPath;
  final String username;
  final int userId;

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> 
{
  final _formKey = GlobalKey<FormState>();

  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  //TextEditingController nativeController = TextEditingController(text: "Unknown");

  bool isSeed = false;
  bool isAlive = true;
  String northAmericanNative = 'Unkown';

  Future<void> addRow() async {
    // // init GSheets
    // final gsheets = GSheets(credentials);
    // // fetch spreadsheet by its id
    // final ss = await gsheets.spreadsheet(spreadsheetId);

    // // get worksheet by its title
    // var sheet = ss.worksheetByTitle(widget.username);
    // // create worksheet if it does not exist yet
    // sheet ??= await ss.addWorksheet(widget.username);

    // if (isSeed) {
    //   plantedAs = 'Planted as Seed';
    // }

    // final newRow = {
    //   '1': '=IF(B1<>"", ROW(),)',
    //   'Plant': plantController.text,
    //   'Living': living,
    //   'Quantity': quantityController.text,
    //   'Nursery': nurseryController.text,
    //   'Planted As': plantedAs,
    //   'latitude': latitude,
    //   'longitude': longitude,
    //   'Notes': notesController.text,
    //   'North American Native': nativeController.text,
    //   'Date': DateTime.now().toIso8601String(),
    // };

    // await sheet.values.map.appendRow(newRow);

    var data = {
      'userId': widget.userId,
      'plantName': plantController.text, 
      'living': isAlive ? 'Y' : 'N',
      'quantity': quantityController.text,
      'nursery': nurseryController.text,
      'plantedAs': isSeed ? 'Seed' : 'Alive',
      'latitude': latitude,
      'longitude': longitude,
      'notes': notesController.text,
      'northAmericanNative': northAmericanNative,
    };
  
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/api/plants/save-user-plant'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',  
      },
      body: jsonEncode(data),
    );

  }

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() async {
    await addRow();
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
      final File image = File(file.path);

      String plantName = plantController.text;
      File dest = await getFile('''$plantName.png''');
      copyFile(image, dest);

      setState(() {
        imageFile = XFile(file.path);
      });
    }
  }

  String _location = 'Getting location...';
  String latitude = 'Unknown location';
  String longitude = 'Unknown location';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Function to get the current location
  Future<void> _getCurrentLocation() async 
  {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _location = 'Location services are disabled.';
      });
      return;
    }

    // Check for permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _location = 'Location permissions are denied.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _location = 'Location permissions are permanently denied.';
      });
      return;
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (mounted) {
      setState(() {
        _location =
            'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
        latitude = '${position.latitude}';
        longitude = '${position.longitude}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      backgroundColor: primaryColor,
      title: Image.asset('assets/images/logo.png'),
    ),
      body: Center(
      child: ListView(
      //mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SearchAnchor(
          builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const WidgetStatePropertyAll<EdgeInsets>(EdgeInsets.symmetric(horizontal: 16.0)),
                onTap: () {
                  controller.openView();
                },
                onChanged: (_) {
                  controller.openView();
                },
                leading: const Icon(Icons.search),
              );
            }, 
            suggestionsBuilder: (BuildContext context, SearchController controller) {
              String searchText = controller.text;
              List<Plant> filteredPlants = widget.plants
                .where((plant) => plant.botanicName
                .toLowerCase()
                .contains(searchText.toLowerCase()))
                .toList();
              return List<ListTile>.generate(
                filteredPlants.length,
                (int index) {
                  final String botanicName = filteredPlants[index].botanicName;
                  final String nativeStatus = filteredPlants[index].native == 1 ? 'Yes' : 'No';

                  return ListTile(
                    title: Text(botanicName),
                    onTap: () {
                      plantController.text = botanicName;
                      northAmericanNative = nativeStatus;
                      controller.closeView(plantController.text);
                    }
                  );
                },
              );
            }
          ),
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: plantController,
                    decoration: const InputDecoration(labelText: 'Plant Name'),
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
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                    ),
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration( 
                      labelText: 'North American Native',
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down),
                    items: ['Yes', 'No', 'Unknown'].map((String value) {
                      return DropdownMenuItem<String> (
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        northAmericanNative = newValue ?? 'Unknown';
                      });
                    }
                  ),
                  FormField<bool>(builder: (state) {
                    return CheckboxListTile(
                        value: isSeed,
                        title: const Text('Planted as Seed'),
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
            )
          ),
          if (!kIsWeb && imageFile == null)
            ElevatedButton(
              onPressed: selectFile,
              child: const Text('Next: take picture'),
            ),
            if (imageFile != null) Image.file(File(imageFile!.path)),
            ElevatedButton(
              onPressed: () {
                _getCurrentLocation();
                _submitForm();
              },
              child: const Text('Submit Plant'),
            )
         ]
       )
     )
    );
  }
}
