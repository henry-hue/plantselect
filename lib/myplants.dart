import 'dart:io';
import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:collection/collection.dart';
import 'editplant.dart';
import 'package:gsheets/gsheets.dart';
import 'credentials.dart';

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

    List<List<String>> plants = await sheet.values.allRows();
    print(plants);
    return plants;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<dynamic>(
      future: sheetsPlants(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              List plant = snapshot.data![index];
              return ListTile(
                title: Column(
                  children: <Widget>[
                    Text('''${plant[4]} ${plant[2]}'''),
                    ElevatedButton(
                        iconAlignment: IconAlignment.end,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditPlant(
                                  plant: plant, username: widget.username)));
                        },
                        child: const Text('Edit'))
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SelectedPlants(plant: plant, picPath: widget.picPath),
                    ),
                  );
                },
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('${snapshot.error}'));
        }

        // By default, show a loading spinner
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class SelectedPlants extends StatelessWidget {
  final List plant;
  final Directory? picPath;

  final List<String> plantStr = [];

  final List<String> attr = [
    'Row',
    'Date',
    'Botanic Name',
    'Living',
    'Quantity',
    'Nursery',
    'Seed'
  ];
  final List<String> plantInfo = [];

  SelectedPlants({super.key, required this.plant, required this.picPath});
  @override
  Widget build(BuildContext context) {
    for (final value in plant) {
      plantStr.add(value.toString());
    }

    for (final pairs in IterableZip([attr, plantStr])) {
      plantInfo.add('${pairs[0]} : ${pairs[1]}');
    }

    // print out directory contents for debugging
    //picPath!.listSync().forEach((e) {
    // print(e.path);
    //});
    Image? picture;
    var attributeCount = plantInfo.length;
    if (picPath != null) {
      String path = picPath!.path;
      String name = plantStr[0];
      String fullPath = '$path/$name';
      picture = Image.file(File(fullPath));
      attributeCount += 1;
    }

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Colors.lightGreen,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Image.asset('assets/images/logo.png'),
      ),
      body: ListView.builder(
          itemCount: attributeCount,
          itemBuilder: (BuildContext context, int index) {
            if (index < plantInfo.length) {
              return Text(plantInfo[index]);
            } else {
              return picture;
            }
          }),
    );
  }
}
