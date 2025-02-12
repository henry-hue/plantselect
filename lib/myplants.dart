import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'editplant.dart';
import 'allplants.dart';
import 'main.dart';
import 'constants.dart';

class MyPlants extends StatefulWidget {
  MyPlants({
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
  bool sort = true;
  int columnIndex = 0;

  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  var isAscending = true;
  var sortColumnIndex = 0;
  List<Map<String, dynamic>> myPlants = [];
 
  @override
  void initState() {
    super.initState();
    sheetsPlants();
  }

  onSortColumn(int columnIndex, bool ascending) {
    print('in sort');
    print(myPlants);
    const columns = ['plant_name', 'quantity', 'nursery', 'planted_as'];
    var columnName = columns[columnIndex];
    if (ascending) {
      myPlants.sort((a, b) => a[columnName].compareTo(b[columnName]));
    } else {
      myPlants.sort((a, b) => b[columnName].compareTo(a[columnName]));
    }
    print('after sort');
    print(myPlants);
  }

  Future <void> sheetsPlants() async {
    // final gsheets = GSheets(credentials);
    // // fetch spreadsheet by its id
    // final ss = await gsheets.spreadsheet(spreadsheetId);

    // var sheet = ss.worksheetByTitle(widget.username);
    // sheet ??= await ss.addWorksheet(widget.username);

    // final firstRow = [
    //   '=IF(B1<>"", ROW(),)',
    //   'Plant',
    //   'Living',
    //   'Quantity',
    //   'Nursery',
    //   'Planted As',
    //   'latitude',
    //   'longitude',
    //   'Notes',
    //   'North American Native',
    //   'Date',
    // ];
    // await sheet.values.insertRow(1, firstRow);
    // List<List<String>> myplants = await sheet.values.allRows(fromRow: 2);
    // myplants = myplants.reversed.toList();
    // return myplants;

    var response = await http.get(
      Uri.parse('${Constants.apiUrl}/api/plants/user-list?userId=${widget.userId}'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}'},
    );
    List<dynamic> plants = json.decode(response.body);
    setState(() {
      myPlants = plants.map((plant) => plant as Map<String, dynamic>).toList();
    });
  }
  

  void gotoEditPlant(plant) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    EditPlant(plant: plant, username: widget.username, userId: widget.userId)))
        .then((value) async {
          await sheetsPlants();
      // setState(() async {
      //   await sheetsPlants();
      // });
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
                userId: widget.userId))
              )
              .then((value) {
                setState(() {
                  sheetsPlants();
                });
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
        body: Padding (
          padding: const EdgeInsets.all(0.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView (
              scrollDirection: Axis.horizontal,
              child:
                DataTable(
                      sortAscending: widget.sort,
                      sortColumnIndex: widget.columnIndex,
                      columns: <DataColumn> [
                        DataColumn(
                          label: const Expanded (
                            child: Text (
                              'Plant Name',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          onSort:(columnIndex, ascending) {
                            setState(() {
                              widget.sort = columnIndex == widget.columnIndex ? !widget.sort : true;
                              widget.columnIndex = columnIndex;
                            });
                            onSortColumn(columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: const Expanded (
                            child: Text (
                              'Quantity',
                              style: TextStyle(fontStyle: FontStyle.italic)
                            ),
                          ),
                          onSort:(columnIndex, ascending) {
                            setState(() {
                              widget.sort = columnIndex == widget.columnIndex ? !widget.sort : true;
                              widget.columnIndex = columnIndex;
                            });
                            onSortColumn(columnIndex, ascending);
                          },
                        ),
                        
                        DataColumn(
                          label: const Expanded (
                            child: Text (
                              'Living',
                              style: TextStyle(fontStyle: FontStyle.italic)
                            ),
                          ),
                          onSort:(columnIndex, ascending) {
                            setState(() {
                              widget.sort = columnIndex == widget.columnIndex ? !widget.sort : true;
                              widget.columnIndex = columnIndex;
                            });
                            onSortColumn(columnIndex, ascending);
                          },
                        ),
                        DataColumn(
                          label: const Expanded (
                            child: Text (
                              'Action',
                              style: TextStyle(fontStyle: FontStyle.italic)
                            ),
                          ),
                        ),
                      ],

                      rows: myPlants.map((plant) {
                        return DataRow(
                            cells: <DataCell> [
                              DataCell(
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 250),
                                  child:Text(plant['plant_name'].toString()),
                                ),
                              ),
                              DataCell(Text(plant['quantity'].toString())),
                              DataCell(Text(plant['living'] == 'Y' ? 'Yes' : 'No')),
                              DataCell(
                                ElevatedButton.icon(
                                  iconAlignment: IconAlignment.end,
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    gotoEditPlant(plant);
                                  },
                                  label: const Text('Edit'),
                                )
                              )
                            ],
                          );
                        }).toList(),
                            
                  ),
            ),
          ),
        ),
    );
  }










                // Home page
                // Card(
                //   child: ListView.builder(
                //       itemCount: snapshot.data!.length,
                //       itemBuilder: (context, index) {
                //         Map<String, dynamic> plant = snapshot.data![index];
                //         return ListTile(
                //           title: Column(
                //             children: <Widget>[
                //               Text('''${plant['quantity']} ${plant['plant_name']}'''),
                //               ElevatedButton(
                //                   iconAlignment: IconAlignment.end,
                //                   onPressed: () {
                //                     gotoEditPlant(plant);
                //                   },
                //                   child: const Text('Edit'))
                //             ],
                //           ),
                //            onTap: () {
                //              Navigator.push(
                //                      context,
                //                      MaterialPageRoute(
                //                          builder: (context) => SelectedPlants(
                //                              plant: plant,
                //                              picPath: widget.picPath)))
                //                  .then((value) {
                //                setState(() {});
                //              });
                //            },
                //         );
                //       }),
                // ),
                //Card(child: MapPage(data: snapshot.data))
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
  final Map<String,dynamic> plant;
  final Directory? picPath;

  List<String> plantInfo = [];

  SelectedPlants({super.key, required this.plant, required this.picPath});
  @override
  Widget build(BuildContext context) {
    // gsheets returns date fields as a fractional number of days since 1/1/1900. Unix Epoch is 1/1/1970 
    // See https://stackoverflow.com/questions/66582839/flutter-get-form-google-sheet-but-date-time-can-not-convert/70747943
    var date = "";
    if (plant.length > 10) {
      date = DateTime.fromMillisecondsSinceEpoch(((double.parse('${plant['insert_date']}')-25569)*86400000).toInt(),isUtc: true).toIso8601String();
    }
    plantInfo = [
      'Common Name : ${plant['plant_name']}',
      'Living : ${plant['living']}',
      'Quantity : ${plant['quantity']}',
      'Nursery : ${plant['nursery']}',
      'Origin : ${plant['origin']}',
      'Notes : ${plant['notes']}',
      'North American Natve : ${plant['north_american_native']}',
      'Date : $date',
    ];

    String plantName = plant['plant_name'];
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
