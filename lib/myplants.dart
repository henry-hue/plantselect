import 'dart:io';
import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:collection/collection.dart';
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

  @override
  Widget build(BuildContext context) {
    double _myToolbarHeight = 200;
    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: SizedBox(
            height: _myToolbarHeight,
            child: Image.asset('assets/images/topDesign.png'),
          ),
          toolbarHeight: _myToolbarHeight,
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: goToAddPlant,
          tooltip: 'Add Plant',
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder<dynamic>(
          future: sheetsPlants(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.length == 0) {
                return const ListTile(
                    title: Text('Click the plus button to add plants'));
              }
              return ListView.builder(
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
                  });
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

    // print out directory contents for debugging
    //picPath!.listSync().forEach((e) {
    // print(e.path);
    //});
    // Image? picture;
    // var attributeCount = plantInfo.length;
    // if (picPath != null) {
    //   String path = picPath!.path;
    //   String name = plant[1];
    //   String fullPath = '$path/$name';
    //   picture = Image.file(File(fullPath));
    //   attributeCount += 1;
    // }

     Image? picture;
    var attributeCount = plantInfo.length;
    if (picPath != null) {
      String path = picPath!.path;
      //String name = plant[1];
      //String fullPath = '$path/$name';
      picture = Image.file(File(path));
      attributeCount += 1;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          title: Image.asset('assets/images/logo.png'),
        ),
        body: Center(
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
                          return picture;
                        }
                      })))
        ])));
  }
}
