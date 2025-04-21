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
      setState(() {sheetsPlants();});
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
    // gsheets returns date fields as a fractional number of days since 1/1/1900. Unix Epoch is 1/1/1970
    // See https://stackoverflow.com/questions/66582839/flutter-get-form-google-sheet-but-date-time-can-not-convert/70747943

    //THE FOLLOWING CODE CHUNK NEEDS DATE IN PLANTINFO
    // var date = "";
    // if (widget.plant.length > 10) {
    //   date = DateTime.fromMillisecondsSinceEpoch(
    //           ((double.parse('${widget.plant[10]}') - 25569) * 86400000)
    //               .toInt(),
    //           isUtc: true)
    //       .toIso8601String()
    //       .split('T')[0];
    // }
    plantInfo = [
      'Botanic Name : ${widget.plant['botanic_name']}',
      'Common Name : ${widget.plant['common_name']}',
      'Living : ${widget.plant['living'] == 'Y' ? 'Yes' : 'No'}',
      'Quantity : ${widget.plant['quantity']}',
      'Nursery : ${widget.plant['nursery']}',
      'Origin : ${widget.plant['planted_as']}',
      'Notes : ${widget.plant['notes']}',
      'North American Natve : ${widget.plant['north_american_native']}',
      'Name of Location in Garden : ${widget.plant['garden_location_name']}',
      'Planted As : ${widget.plant['planted_as']}',
      'Plant Type : ${widget.plant['plant_type']}',
      'Sun : ${widget.plant['sun'] == 1 ? "Full Sun": "Partial Sun"}',
      'Wet : ${widget.plant['wet'] == 1 ? "Moist": "Semi Arid"}',   
      'Flowering Season : ${widget.plant['flower_season']}',
      'Maintenance : ${widget.plant['commercial_maintenance']}',
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

              return Column(children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ListTile(
                          title: Text(
                            '${widget.plant['botanic_name']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 23,
                            ),
                          ),
                          subtitle: Row(children: <Widget>[
                            ElevatedButton(
                              onPressed: () {
                                _submitForm();
                              },
                              child: Text('Delete'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                gotoEditPlant(widget.plant);
                              },
                              child: Text('Edit'),
                            ),
                          ])),
                    ),
                  ],
                ),
                Expanded(
                    child: ListView.builder(
                        itemCount: attributeCount,
                        itemBuilder: (BuildContext context, int index) {
                          if (index == plantInfo.length) {
                            return ListTile(
                            title: picture);
                          }
                          return ListTile(
                            title: Html(data:plantInfo[index]),
                          );
                        }))
              ]);
            }));
  }
}
