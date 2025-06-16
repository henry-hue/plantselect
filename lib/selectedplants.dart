import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'editplant.dart';
import 'main.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'constants.dart';

Future<String> get _photoLibrary async {
  final base = await getApplicationDocumentsDirectory();
  final directory =
      await Directory("${base.path}/images/").create(recursive: true);
  return directory.path;
}

Future<String> getFile(String name) async {
  if (kIsWeb) {
    return "";
  }
  final path = await _photoLibrary;
  return '$path/$name';
}

// ignore: must_be_immutable
class SelectedPlants extends StatefulWidget {
  const SelectedPlants(
      {super.key,
      required this.plant,
      required this.picPath,
      required this.username,
      required this.userId});
  final String username;
  final Map<String, dynamic> plant;
  final Directory? picPath;
  final int userId;

  @override
  State<SelectedPlants> createState() => _SelectedPlantsState();
}

class _SelectedPlantsState extends State<SelectedPlants> {
  List<String> plantInfo = [];
  List<Map<String, dynamic>> myPlants = [];

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

  void gotoEditPlant(plant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPlant(
                plant: plant,
                username: widget.username,
                userId: widget.userId))).then((value) {
      setState(() {
        sheetsPlants();
      });
    });
  }

  Future<void> deleteRow() async {
    var data = {
      'plantId': widget.plant['plant_id'],
    };
    var response = await http.post(
      Uri.parse('${Constants.apiUrl}/api/plants/delete-user-plant'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}',
        'content-type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  void _submitForm() async {
    await deleteRow();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
//print(widget.plant);

    plantInfo = [
      'Botanic Name: ${widget.plant['botanic_name']}',
      'Common Name: ${widget.plant['common_name']}',
      'Living: ${widget.plant['living'] == 'Y' ? 'Yes' : 'No'}',
      'Quantity: ${widget.plant['quantity']}',
      'Notes: ${widget.plant['notes']}',
      'Name of Location in Garden: ${widget.plant['garden_location_name']}',
      'Planted As: ${widget.plant['planted_as']}',
      'Plant Type: ${widget.plant['type']}',
      'Sun: ${widget.plant['sun'] == 1 ? "Full Sun" : "Partial Sun"}',
      'Wet: ${widget.plant['wet'] == 1 ? "Moist" : "Semi Arid"}',
      'Blooms: ${widget.plant['blooms']}',
      'Maintenance: ${widget.plant['maintenance_schedule']}',
      'North American Native: ${widget.plant['naNative'] == 1 ? 'Yes' : 'No'}',
      'Nursery: ${widget.plant['nursery']}',
    ];

    String plantName = widget.plant['botanic_name'];
    String name = '''$plantName.png''';

    var attributeCount = plantInfo.length;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Image.asset('assets/images/logo.png'),
        ),
        body: FutureBuilder<String>(
            future: getFile(name),
            builder: (context, snapshot) {
              Image? picture;
              if (!kIsWeb && snapshot.hasData) {
                File file = File(snapshot.data!);
                if (file.existsSync()) {
                  picture = Image.file(file);
                  attributeCount += 1;
                }
              }

              return Column(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ListTile(
                      //titleAlignment: ListTileTitleAlignment.center,
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '''
                               ${widget.plant['botanic_name']}
                               ${widget.plant['common_name']}''',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                _submitForm();
                              },
                              child: Text(
                                'Delete',
                                textAlign: TextAlign.center,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                gotoEditPlant(widget.plant);
                              },
                              child: Text(
                                'Edit',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                    ),
                    Expanded(
                        child: ListView.builder(
                            itemCount: attributeCount,
                            itemBuilder: (BuildContext context, int index) {
                              if (index == plantInfo.length) {
                                return ListTile(title: picture);
                              }
                              return ListTile(
                                title: Html(data: plantInfo[index]),
                              );
                            }))
                  ]);
            }));
  }
}
