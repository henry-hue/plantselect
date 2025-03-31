// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'credentials.dart';
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

class AddPlant extends StatefulWidget {
  const AddPlant(
      {super.key,
      required this.plants,
      required this.picPath,
      required this.username,
      required this.userId,
      required this.wishList});
  final List<Plant> plants;
  final Directory? picPath;
  final String username;
  final int userId;
  final bool wishList;

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController gardenLocationNameController = TextEditingController();

  bool isSeed = false;
  bool isAlive = true;
  String northAmericanNative = 'Unknown';
  String sun = 'Unknown';
  String soil = 'Unknown';
  String water = 'Unknown';
  String type = 'Unknown';
  String flowering = 'Unknown';
  String maintenance = 'Unknown';

  Future<void> addRow() async {
    var data = {
      'userId': widget.userId,
      'plantName': plantController.text,
      'living': isAlive ? 'Y' : 'N',
      'quantity': quantityController.text,
      'nursery': nurseryController.text,
      'plantedAs': isSeed ? 'Seed' : 'Sapling',
      'latitude': latitude,
      'longitude': longitude,
      'notes': notesController.text,
      'gardenLocationName' : gardenLocationNameController.text,
      'northAmericanNative': northAmericanNative,
      'wishlist': widget.wishList ? 'Y' : 'N',
      'Sun': sun,
      'Soil': soil,
      'Water': water,
      'Plant Type': type,
      'Flowering Season': flowering,
      'Annual Maintenance': maintenance,
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

  void _submitForm() async {
    await addRow();
    Navigator.pop(context);
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
  Future<void> _getCurrentLocation() async {
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
    Position position = await Geolocator.getCurrentPosition();

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
                    .where((plant) => plant.botanicName
                        .toLowerCase()
                        .contains(searchText.toLowerCase()))
                    .toList();
                return List<ListTile>.generate(
                  //TODO: Alter api to return plant attributes
                  filteredPlants.length,
                  (int index) {
                    final String botanicName =
                        filteredPlants[index].botanicName;
                    final String nativeStatus =
                        filteredPlants[index].native == 1 ? 'Yes' : 'No';
                    //final String sunPref = filteredPlants[index].sun;
                    // final String soilPref = filteredPlants[index].soil;
                    // final String waterPref = filteredPlants[index].water;
                    // final String plantType = filteredPlants[index].type;
                    // final String floweringSeason =
                    //     filteredPlants[index].flowering;
                    // final String annualMaintenance =
                    //     filteredPlants[index].maintenance;

                    return ListTile(
                        title: Text(botanicName),
                        onTap: () {
                          plantController.text = botanicName;
                          northAmericanNative = nativeStatus;
                          //sun = sunPref;
                          // soil = soilPref;
                          // water = waterPref;
                          // type = plantType;
                          // flowering = floweringSeason;
                          // maintenance = annualMaintenance;

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
                          decoration:
                              const InputDecoration(labelText: 'Plant Name'),
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
                        TextFormField(
                          controller: gardenLocationNameController,
                          decoration: const InputDecoration(
                            labelText: 'Name of Location in Garden',
                          ),
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
                  )),
              if (!kIsWeb && !widget.wishList && imageFile == null)
                ElevatedButton(
                  onPressed: selectFile,
                  child: const Text('Next: take picture'),
                ),
              if (imageFile != null) Image.file(File(imageFile!.path)),
              ElevatedButton(
                onPressed: () {
                  if (!widget.wishList) {
                    _getCurrentLocation();
                  }
                  _submitForm();
                  //TODO: Is AddRow necessary after submitForm()
                  // addRow().then((result) {
                  //     if (context.mounted) {
                  //       Navigator.of(context).pop();
                  //     }
                  //   });
                },
                child: const Text('Submit Plant'),
              )
            ])));
  }
}
