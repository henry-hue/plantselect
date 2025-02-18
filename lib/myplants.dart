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

enum SortOrder { date, common, scientific, deadPlants }

class MyPlants extends StatefulWidget {
  const MyPlants(
      {super.key,
      required this.plants,
      required this.picPath,
      required this.username,
      required this.logout});
  final List<Plant> plants;
  final Directory? picPath;
  final String username;
  final Function logout;

  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  SortOrder sortOrder = SortOrder.date;
  int currentPageIndex = 0;

  fetchMyPlants() async {
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
      'Origin',
      'latitude',
      'longitude',
      'Notes',
      'North American Native',
      'Date',
      'WishList',
      'Sun',
      'Soil',
      'Water',
      'Flowering Season',
      'Plant Type',
      'Annual Maintenance',
    ];
    await sheet.values.insertRow(1, firstRow);
    List<List<String>> allPlants = await sheet.values.allRows(fromRow: 2);
    List<List<String>> buildDeadPlants = [];
    List<List<String>> myplants = [];

    for (List<String> plant in allPlants) {
      if (plant[2] == 'Alive') {
        myplants.add(plant);
      }
    }

    for (List<String> plant in allPlants) {
      if (plant[2] == 'Dead') {
        buildDeadPlants.add(plant);
      }
    }

    if (sortOrder == SortOrder.date) {
      myplants = myplants.reversed.toList();
    } else if (sortOrder == SortOrder.common) {
      myplants.sort((a, b) => a[1].compareTo(b[1]));
    } else if (sortOrder == SortOrder.scientific) {
      myplants.sort((a, b) {
        List<String> aName = a[1].split('(');
        List<String> bName = b[1].split('(');
        if (aName.length < 2 || bName.length < 2) {
          return a[1].compareTo(b[1]);
        }
        return aName[1].compareTo(bName[1]);
      });
    } else if (sortOrder == SortOrder.deadPlants) {
      myplants = buildDeadPlants;
    }

    return myplants;
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

  @override
  Widget build(BuildContext context) {
    double myToolbarHeight = 150;

    return Scaffold(
        appBar: AppBar(
          leadingWidth: 25,
          backgroundColor: primaryColor,
          title: SizedBox(
            height: myToolbarHeight,
            //width: 600,
            child: Image.asset('assets/images/newdesign.png'),
          ),
          toolbarHeight: myToolbarHeight,
          

        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              Padding(padding: EdgeInsets.only(top: 20)),
              ExpansionTile(title: Text('Sort By:'), children: [
                ListTile(
                  title: Text('Date'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      sortOrder = SortOrder.date;
                    });
                  },
                ),
                ListTile(
                  title: Text('Common Name'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      sortOrder = SortOrder.common;
                    });
                  },
                ),
                ListTile(
                  title: Text('Scientific Name'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      sortOrder = SortOrder.scientific;
                    });
                  },
                ),
                ListTile(
                  title: Text('Dead Plants'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      sortOrder = SortOrder.deadPlants;
                    });
                  },
                ),
              ]),
              ListTile(
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  widget.logout();
                },
              ),
            ],
          ),
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
          future: fetchMyPlants(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length == 0) {
                return const ListTile(
                    title: Text('Click the plus button to add plants'));
              }
              // Build wishlist and myplants and deadPlants lists
              List<List<String>> myPlants = [];
              List<List<String>> wishListPlants = [];

              for (final plant in snapshot.data) {
                if (plant.length > 11 && plant[11] == 'true') {
                  //is the 11 check needed? need to change number for new columns if so
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
                        return Container(
                            color: (index % 2 == 0)
                                ? Colors.lightGreen[50]
                                : Colors.lightGreen[100],
                            child: ListTile(
                              title: plant[3].isEmpty
                                  ? Text(
                                      '''${plant[1]}''',
                                      textAlign: TextAlign.center,
                                    )
                                  : Text(
                                      '''${plant[1]}, Quantity: ${plant[3]}''',
                                      textAlign: TextAlign.center,
                                    ),
                              // subtitle: ElevatedButton(
                              //     iconAlignment: IconAlignment.end,
                              //     onPressed: () {
                              //       gotoEditPlant(plant);
                              //     },
                              //     child: const Text('Edit')),
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SelectedPlants(
                                              plant: plant,
                                              picPath: widget.picPath,
                                              username: widget.username,
                                            )));
                              },
                            ));
                      }),
                ),
                Card(child: MapPage(data: myPlants)),

                Card(
                  child: ListView.builder(
                      itemCount: wishListPlants.length,
                      itemBuilder: (context, index) {
                        List plant = wishListPlants[index];
                        return ListTile(
                          leading: Text('Wishlist Plant:'),
                          title: Column(
                            children: <Widget>[
                              Text('''${plant[1]} Quantity: ${plant[3]}'''),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SelectedPlants(
                                          plant: plant,
                                          picPath: widget.picPath,
                                          username: widget.username,
                                        )));
                          },
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
class SelectedPlants extends StatefulWidget {
  const SelectedPlants(
      {super.key,
      required this.plant,
      required this.picPath,
      required this.username});
  final String username;
  final List plant;
  final Directory? picPath;

  @override
  State<SelectedPlants> createState() => _SelectedPlantsState();
}

class _SelectedPlantsState extends State<SelectedPlants> {
  List<String> plantInfo = [];

  void gotoEditPlant(plant) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditPlant(plant: plant, username: widget.username)))
        .then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // gsheets returns date fields as a fractional number of days since 1/1/1900. Unix Epoch is 1/1/1970
    // See https://stackoverflow.com/questions/66582839/flutter-get-form-google-sheet-but-date-time-can-not-convert/70747943
    var date = "";
    if (widget.plant.length > 10) {
      date = DateTime.fromMillisecondsSinceEpoch(
              ((double.parse('${widget.plant[10]}') - 25569) * 86400000)
                  .toInt(),
              isUtc: true)
          .toIso8601String()
          .split('T')[0];
    }

    plantInfo = [
      '${widget.plant[1]}',
      'Date : $date',
      'Sun : ${widget.plant[12]}',
      'Water : ${widget.plant[14]}',
      'Soil : ${widget.plant[13]}',
      'Plant Type : ${widget.plant[16]}',
      'Flowering Season : ${widget.plant[15]}',
      'Commercial Maintenance : ${widget.plant[17]}',
      'Living : ${widget.plant[2]}',
      'Quantity : ${widget.plant[3]}',
      'Nursery : ${widget.plant[4]}',
      'Origin : ${widget.plant[5]}',
      'Notes : ${widget.plant[8]}',
      'North American Native : ${widget.plant[9]}',
    ];

    String plantName = widget.plant[1];
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
