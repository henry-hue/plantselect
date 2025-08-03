// ignore_for_file: must_be_immutable
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'dart:io';
import 'main.dart';
import 'package:geolocator/geolocator.dart';
import 'constants.dart';
import 'package:flutter_html/flutter_html.dart';

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
  TextEditingController commonNameController = TextEditingController();
  TextEditingController naNativeController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  TextEditingController gardenLocationNameController = TextEditingController();
  TextEditingController plantTypeController = TextEditingController();
  TextEditingController sunController = TextEditingController();
  TextEditingController waterController = TextEditingController();
  TextEditingController floweringController = TextEditingController();
  TextEditingController maintenanceController = TextEditingController();

  List<Map<String, dynamic>> myPlants = [];

  bool isSeed = false;
  bool isAlive = true;
  String naNative = 'Unknown';
  String sun = 'Unknown';
  String water = 'Unknown';
  String type = 'Unknown';
  String flowering = 'Unknown';
  String maintenance = 'Unknown';

  Future<void> addRow() async {
    // if (quantityController.text == Text('0').toString()) {
    //   quantityController.text = 'N/A';
    // }

    var data = {
      'userId': widget.userId,
      'botanicName': plantController.text,
      'commonName': commonNameController.text,
      'living': isAlive ? 'Y' : 'N',
      'quantity': quantityController.text,
      'nursery': nurseryController.text,
      'plantedAs': isSeed ? 'Seed' : 'Sapling',
      'latitude': latitude,
      'longitude': longitude,
      'notes': notesController.text,
      'garden_location_name': gardenLocationNameController.text,
      'north_american_native': naNativeController.text,
      'wishlist': widget.wishList ? 'Y' : 'N',
      'sun': sunController.text,
      'type': plantTypeController.text,
      'wet': waterController.text,
      'blooms': floweringController.text,
      'maintenance_schedule': maintenanceController.text,
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

      String botanicName = plantController.text;
      File dest = await getFile('''$botanicName.png''');
      copyFile(image, dest);

      setState(() {
        imageFile = XFile(file.path);
      });
    }
  }

  final String _location = 'Getting location...';
  String latitude = 'Unknown location';
  String longitude = 'Unknown location';

  @override
  void initState() {
    super.initState();
    sheetsPlants();
  }

  Future<void> sheetsPlants() async {
    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/api/plants/user-list?userId=${widget.userId}&wishlist=${'N'}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}'
      },
    );
    List<dynamic> plants = json.decode(response.body);
    myPlants = plants.map((plant) => plant as Map<String, dynamic>).toList();

    setState(() {
      myPlants.removeWhere((item) => item['garden_location_name'] == null);
    });
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
                    .where((plant) =>
                        plant.botanicName
                            .toLowerCase()
                            .contains(searchText.toLowerCase()) ||
                        plant.commonName
                            .toLowerCase()
                            .contains(searchText.toLowerCase()))
                    .toList();
                return List<ListTile>.generate(filteredPlants.length,
                    (int index) {
                  final String botanicName = filteredPlants[index].botanicName;
                  final String commonName = filteredPlants[index].commonName;
                  final String naNative =
                      filteredPlants[index].naNative == 1 ? 'Yes' : 'No';
                  final String? plantType = filteredPlants[index].plantType;
                  final String flowering = filteredPlants[index].flowering;
                  final String sun = filteredPlants[index].sun == 1
                      ? 'Full Sun'
                      : 'Partial Sun';
                  final String water =
                      filteredPlants[index].water == 1 ? 'Wet' : 'Damp';
                  final String maintenance = filteredPlants[index].maintenance;

                  final String fullName = '$commonName ($botanicName)';

                  return ListTile(
                      title: Html(data: fullName),
                      onTap: () {
                        commonNameController.text = commonName;
                        plantController.text = botanicName;
                        naNativeController.text = naNative;

                        plantTypeController.text = plantType ?? "Unknown";
                        sunController.text = sun ?? "Unknown";
                        waterController.text = water ?? "Unknown";
                        floweringController.text = flowering ?? "Unknown";
                        maintenanceController.text = maintenance ?? "Unknown";

                        controller.closeView(fullName);
                      });
                });
              }),
              Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextFormField(
                          controller: plantController,
                          decoration: const InputDecoration(
                              labelText: 'Scientific Plant Name'),
                              
                        ),
                        TextFormField(
                          controller: commonNameController,
                          decoration:
                              const InputDecoration(labelText: 'Common Name'),
                              
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
                        Flexible(
                          fit: FlexFit.loose,
                          child: SizedBox(
                            height: 64,
                            child: DropdownButton<String>(
                              isExpanded: true,
                              hint: Text(
                                'Garden Locations',
                                
                              ),
                              items: myPlants
                                  .map((e) =>
                                      e['garden_location_name'].toString())
                                  .toSet()
                                  .toList()
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              underline: Container(
                                  height: 1,
                                  color: const Color.fromARGB(255, 66, 64, 64)),
                              onChanged: (String? value) {
                                setState(() {
                                  gardenLocationNameController.text = value!;
                                });
                              },
                            ),
                          ),
                        ),
                        FormField<bool>(builder: (state) {
                          return CheckboxListTile(
                              value: isSeed,
                              title: const Text('Planted as Seed',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  //save checkbox value to variable that store terms and notify form that state changed
                                  isSeed = !isSeed;
                                  state.didChange(value);
                                });
                              });
                        }
                        ),
                        Text(
                          'Autofilled Fields for Plant Select Plants',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        TextFormField(
                          controller: naNativeController,
                          decoration: const InputDecoration(
                            labelText: 'North American Native',
                          ),
                        ),
                        TextFormField(
                          controller: plantTypeController,
                          decoration: const InputDecoration(
                            labelText: 'Plant Type',
                          ),
                        ),
                        TextFormField(
                          controller: sunController,
                          decoration: const InputDecoration(
                            labelText: 'Sun',
                          ),
                        ),
                        TextFormField(
                          controller: waterController,
                          decoration: const InputDecoration(
                            labelText: 'Water',
                          ),
                        ),
                        TextFormField(
                          controller: floweringController,
                          decoration: const InputDecoration(
                            labelText: 'Flowering Season',
                          ),
                        ),
                        TextFormField(
                          controller: maintenanceController,
                          decoration: const InputDecoration(
                            labelText: 'Maintenance',
                          ),
                        ),
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
                  _submitForm();
                },
                child: const Text('Submit Plant'),
              )
            ])));
  }
}
