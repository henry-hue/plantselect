import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'plant.dart';

import 'package:collection/collection.dart';

class AllPlants extends StatefulWidget {
  @override
  State<AllPlants> createState() => _AllPlantsState();
}

class _AllPlantsState extends State<AllPlants> {
  List<Plant> favorites = [];
  Future<List<Plant>> fetchPlants() async {
    final String url =
        'https://script.googleusercontent.com/macros/echo?user_content_key=_B-W-AHmjR26KU5dTCw1S-B2DHZEuws01wTIWfteAhh1hJmlRPaKDGo9Y28yztqfS4hpvU0auyjWeXE6R04QW4DiUHEKgbgXm5_BxDlH2jW0nuo2oDemN9CCS2h10ox_1xSncGQajx_ryfhECjZEnO2U0Bl7BUAklHHeNRDrUcIoEcGPmrrlK_ulnafppH3w7o8FAM3ee_EkorPOGtTMgbRERG-Fn53JVefYCVkuXGQB2G7xa3afN9z9Jw9Md8uu&lib=MxnqXoKCpdNq7DADJrJEvDBtmPjijWW5o';
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
                title: Text(plant.values[0]),
                //leading: Image.network(plant.imageUrl),
                subtitle: Text('Botanic Name: ${plant.values[1]}'),
                trailing: Column(
                  children: <Widget>[
                    ElevatedButton(
                        child: Text('Add Plant'),
                        onPressed: () {
                          favorites.add(plant);
                        })
                  ],
                ),

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => selectedPlants(plant: plant),
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
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

// ...
class SecondScreen extends StatelessWidget {
  //final Plant favorites;

  //SecondScreen({required this.favorites});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Image.asset('assets/images/logo.png'),
        //     title: Text('Your Plants', style: TextStyle(
        // fontWeight: FontWeight.w300, // light
        // fontStyle: FontStyle.italic, // italic ),
        //   ),),),
      ),
      // body: Center(
      //   child: Plant favorites,
      // ),
    );
  }
}

class selectedPlants extends StatelessWidget {
  final Plant plant;
  final List<String> plantStr = [];

  final List<String> attr = [
    'Plant Type',
    'Height',
    'Width',
    'Flowering Season',
    'Flower Color',
    'Sun',
    'Water Needs',
    'USDA Hardiness Zone',
    'Soil Type',
    'Deer Resistant',
    'Good for Pollination',
    'Winter Interest',
    'North American Native',
    'Year Introduced',
    'Annual Commercial Maintenance',
    '5-10 Year Commercial Maintenance',
    'Elevation Guide	Description	Web Link'
  ];
  final List<String> plantInfo = [];

  selectedPlants({required this.plant});
  @override
  Widget build(BuildContext context) {
    for (final value in plant.values) {
      plantStr.add(value.toString());
    }

    for (final pairs in IterableZip([attr, plantStr])) {
      plantInfo.add('${pairs[0]} : ${pairs[1]}');
    }
    return Table(
        border: TableBorder.all(width: 1.0, color: Colors.black),
        children: [
          for (final info in plantInfo)
            TableRow(children: [
              TableCell(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  new Text(info),
                ],
              ))
            ])
        ]);

    // throw Exception('Failed to load plant info');
  }
}
