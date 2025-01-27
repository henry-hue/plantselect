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
      'Notes',
      'North American Native',
      'Date',
      'WishList',
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
                username: widget.username,
                wishList: (currentPageIndex == 2),
                ))).then((value) {
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
                selectedIcon: Icon(Icons.map),
                icon: Icon(Icons.map_outlined),
                label: 'Map',
              ),
               NavigationDestination(
                selectedIcon: Icon(Icons.card_giftcard),
                icon: Icon(Icons.card_giftcard_outlined),
                label: 'My WishList',
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
              // Build wishliat and myplants lists
              List<List<String>> myPlants = [];
              List<List<String>> wishListPlants = [];
              for (final plant in snapshot.data) {
                if (plant.length > 11 && plant[11] == 'true') {
                  wishListPlants.add(plant);
                } else {
                  myPlants.add(plant);
                }
              }
              return <Widget>[
                // Home page
                Card(
                  child: ListView.builder(
                      itemCount: myPlants.length,
                      itemBuilder: (context, index) {
                        List plant = myPlants[index];
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
                                            plant: plant,
                                            picPath: widget.picPath)))
                                .then((value) {
                              setState(() {});
                            });
                          },
                        );
                      }),
                ),
                Card(child: MapPage(data: myPlants)),


                Card(
                  child: ListView.builder(
                      itemCount: wishListPlants.length,
                      itemBuilder: (context, index) {
                        List plant = wishListPlants[index];
                        return ListTile(
                          leading: Text('title'),
                          title: Column(
                            children: <Widget>[
                              Text('''WishList Plant: ${plant[3]} ${plant[1]}'''),
                            ],
                          ),
                        );
                      }),
                ),
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

Future<String> getFile(String name) async {
  if (kIsWeb) {
    return "";
  }
  final path = await _photoLibrary;
  return '$path/$name';
}

// ignore: must_be_immutable
class SelectedPlants extends StatelessWidget {
  final List plant;
  final Directory? picPath;

  List<String> plantInfo = [];

  SelectedPlants({super.key, required this.plant, required this.picPath});
  @override
  Widget build(BuildContext context) {
    // gsheets returns date fields as a fractional number of days since 1/1/1900. Unix Epoch is 1/1/1970 
    // See https://stackoverflow.com/questions/66582839/flutter-get-form-google-sheet-but-date-time-can-not-convert/70747943
    var date = "";
    if (plant.length > 10) {
      date = DateTime.fromMillisecondsSinceEpoch(((double.parse('${plant[10]}')-25569)*86400000).toInt(),isUtc: true).toIso8601String();
    }
    var wishList = 'false';
    if (plant.length > 11) {
      wishList = '${plant[11]}';
    }
    plantInfo = [
      'Common Name : ${plant[1]}',
      'Living : ${plant[2]}',
      'Quantity : ${plant[3]}',
      'Nursery : ${plant[4]}',
      'Origin : ${plant[5]}',
      'Notes : ${plant[8]}',
      'North American Natve : ${plant[9]}',
      'Date : $date',
    ];

    String plantName = plant[1];
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
