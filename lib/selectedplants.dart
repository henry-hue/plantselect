import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'editplant.dart';
import 'main.dart';



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

  void gotoEditPlant(plant) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => EditPlant(
                plant: plant,
                username: widget.username,
                userId: widget.userId))).then((value) {
      setState(() {});
    });
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
      'Common Name : ${widget.plant['plant_name']}',
      'Living : ${widget.plant['living']}',
      'Quantity : ${widget.plant['quantity']}',
      'Nursery : ${widget.plant['nursery']}',
      'Origin : ${widget.plant['planted_as']}',
      'Notes : ${widget.plant['notes']}',
      'North American Natve : ${widget.plant['north_american_native']}',

      //   // 'Date : $date',
      //   // 'Sun : ${widget.plant[12]}',
      //   // 'Water : ${widget.plant[14]}',
      //   // 'Soil : ${widget.plant[13]}',
      //   // 'Plant Type : ${widget.plant[16]}',
      //   // 'Flowering Season : ${widget.plant[15]}',
      //   // 'Commercial Maintenance : ${widget.plant[17]}',
      //   // 'Living : ${widget.plant[2]}',
      //   // 'Quantity : ${widget.plant[3]}',
      //   // 'Nursery : ${widget.plant[4]}',
      //   // 'Origin : ${widget.plant[5]}',
      //   // 'Notes : ${widget.plant[8]}',
      //   // 'North American Native : ${widget.plant[9]}',
    ];

    String plantName = widget.plant['plant_name'];
    String name = '''$plantName.png''';

    var attributeCount = plantInfo.length + 1;

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
                  attributeCount += 1; // add room for picture at end
                }
              }

              return Center(
                  child: Column(children: <Widget>[
                Expanded(
                    child: SizedBox(
                        height: 400.0,
                        child: ListView.builder(
                            itemCount: attributeCount,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < 4) {
                                return Text(plantInfo[index]);
                              } else if (index == 7) {
                                return Container(child: picture);
                              } else if (index < plantInfo.length) {
                                return Text(plantInfo[index]);
                              } else {
                                return ElevatedButton(
                                    //iconAlignment: IconAlignment.end,
                                    onPressed: () {
                                      gotoEditPlant(widget.plant);
                                    },
                                    child: const Text('Edit'));
                              }
                            })))
              ]));
            }));
  }
}
