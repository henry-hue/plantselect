import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plantselect/map.dart';
import 'plant.dart';
import 'editplant.dart';
import 'package:gsheets/gsheets.dart';
import 'credentials.dart';
import 'allplants.dart';
import 'main.dart';
import 'map.dart';

class MyPlants extends StatefulWidget {
  const MyPlants(
      {super.key,
      required this.plants,
      required this.picPath,
      required this.username});
  final List<Plant> plants;
  final Directory? picPath;
  final String username;

  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  sheetsPlants() async {
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);

    var sheet = ss.worksheetByTitle(widget.username);
    sheet ??= await ss.addWorksheet(widget.username);

    final firstRow = [
      '=IF(B1<>"", ROW(),)',
      'Plant',
      'Living',
      'Quantity',
      'Nursery',
      'Planted As',
      'latitude',
      'longitude',
    ];
    await sheet.values.insertRow(1, firstRow);
    List<List<String>> myplants = await sheet.values.allRows(fromRow: 2);
    myplants = myplants.reversed.toList();
    return myplants;
  }

  void gotoEditPlant(plant) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditPlant(plant: plant, username: widget.username)))
        .then((value) {
      setState(() {
        sheetsPlants();
      });
    });
  }

  void goToAddPlant() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPlant(
                plants: widget.plants,
                picPath: widget.picPath,
                username: widget.username))).then((value) {
      setState(() {});
    });
  }



  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    double myToolbarHeight = 200;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: SizedBox(
            height: myToolbarHeight,
            child: Image.asset('assets/images/topDesign.png'),
          ),
          toolbarHeight: myToolbarHeight,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goToAddPlant,
          tooltip: 'Add Plant',
          child: const Icon(Icons.add),
        ),
        bottomNavigationBar: NavigationBar(
            onDestinationSelected: (int index) {
              setState(() {
                currentPageIndex = index;
              });
            },
            indicatorColor: Colors.amber,
            selectedIndex: currentPageIndex,
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.home),
                icon: Icon(Icons.home_outlined),
                label: 'My Plants',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.business),
                icon: Icon(Icons.home_outlined),
                label: 'Map',
              ),
            ]),
        body: FutureBuilder<dynamic>(
          future: sheetsPlants(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length == 0) {
                return const ListTile(
                    title: Text('Click the plus button to add plants'));
              }
              return <Widget>[
                // Home page
                Card(
                  child: ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        List plant = snapshot.data![index];
                        return ListTile(
                          title: Column(
                            children: <Widget>[
                              Text('''${plant[3]} ${plant[1]}'''),
                              ElevatedButton(
                                  iconAlignment: IconAlignment.end,
                                  onPressed: () {
                                    gotoEditPlant(plant);
                                  },
                                  child: const Text('Edit'))
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SelectedPlants(
                                    plant: plant, picPath: widget.picPath),
                              ),
                            );
                          },
                        );
                      }),
                ),
                Card(child: MapPage(data: snapshot.data))
              ][currentPageIndex];
            } else if (snapshot.hasError) {
              return Center(child: Text('${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('Click the plus button to add plants'));
            }

            // By default, show a loading spinner
            return const Center(child: CircularProgressIndicator());
          },
        ));
  }
}

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

// ignore: must_be_immutable
class SelectedPlants extends StatelessWidget {
  final List plant;
  final Directory? picPath;

  final List<String> attr = [
    'Common Name',
    'Living',
    'Quantity',
    'Nursery',
    'Origin'
  ];
  List<String> plantInfo = [];

  SelectedPlants({super.key, required this.plant, required this.picPath});
  @override
  Widget build(BuildContext context) {
    plantInfo = [
      '${attr[0]} : ${plant[1]}',
      '${attr[1]} : ${plant[2]}',
      '${attr[2]} : ${plant[3]}',
      '${attr[3]} : ${plant[4]}',
      '${attr[4]} : ${plant[5]}',
    ];

    String plantName = plant[1];
    String name = '''$plantName.png''';

    var attributeCount = 6;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Image.asset('assets/images/logo.png'),
        ),
        body: FutureBuilder<File>(
            future: getFile(name),
            builder: (context, snapshot) {
              Image? picture;
              if (!kIsWeb) {
                picture = Image.file(snapshot.data!);
                attributeCount += 1; // add room for picture at end
              }

              return Center(
                  child: Column(children: <Widget>[
                Expanded(
                    child: SizedBox(
                        height: 400.0,
                        child: ListView.builder(
                            itemCount: attributeCount,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < plantInfo.length) {
                                return Text(plantInfo[index]);
                              } else {
                                return Container(child: picture);
                              }
                            })))
              ]));
            }));
  }
}
