import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'plant.dart';
import 'package:collection/collection.dart';

import 'editplant.dart';

class MyPlants extends StatefulWidget {
  const MyPlants(
      {super.key, required this.plants, required Directory? this.picPath});
  final List<Plant> plants;
  final Directory? picPath;
  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  Future<List<Plant>> fetchPlants() async {
    const String url =
        'https://script.googleusercontent.com/macros/echo?user_content_key=oowhxHnTBvTx7NHq7s1-L1bFZ0Q5OX-lWqpDVv2h5N2IGGRrgfRHsAb0BVEtOziJrwRAxBVdlrl3J7fKsXV_FYyKhgiEheghm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnJigKuI4g_xMEZuR9PYl2cL-3n2F4eLbuz74z0T9PLbN9cs2I0JMs9mDQ6rNaHt20Sn8bVbBb5Jc0m5V72Znp5U9UcY3T9_dZx1DRVMwfnbWA-elmIfAQ60&lib=MOSwzJUSqFdCcsvaTtaA8SOrAvy20VzFd';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<dynamic> values = data.sublist(1);
      List<Plant> plants = values.map((json) => Plant.fromJson(json)).toList();
      return plants;
    } else {
      throw Exception('Failed to load plants');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Plant>>(
      future: fetchPlants(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Plant plant = snapshot.data![index];
              return ListTile(
                title: Column(
                  children: <Widget>[
                    Text(
                        '''${plant.values[1]}: ${plant.values[4]} ${plant.values[2]}'''),
                    ElevatedButton(
                        child: Text('Edit'),
                        iconAlignment: IconAlignment.end,
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditPlant(plant: plant)));
                        })
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
  final Plant plant;
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
    for (final value in plant.values) {
      plantStr.add(value.toString());
    }

    for (final pairs in IterableZip([attr, plantStr])) {
      plantInfo.add('${pairs[0]} : ${pairs[1]}');
    }

//Directory dir = directory();
    // getting a directory path for saving
    String path = picPath!.path;
    String name = plantStr[0];
    String fullPath = '$path/$name';
    print(fullPath);

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
          itemCount: plantInfo.length + 1,
          itemBuilder: (BuildContext context, int index) {
            if (index < plantInfo.length) {
              return Text(plantInfo[index]);
            } else {
              return Container(
                child: Image.file(File(fullPath)),
              );
            }
          }),
    );
  }
}
