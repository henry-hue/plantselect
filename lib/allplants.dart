import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

class AllPlants extends StatefulWidget {
  const AllPlants({super.key, required this.plants});
  final List<Plant> plants;

  @override
  State<AllPlants> createState() => _AllPlantsState();
}

class _AllPlantsState extends State<AllPlants> {
  List<Plant> addedPlants = [];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            itemCount: widget.plants.length,
            itemBuilder: (context, index) {
              Plant plant = widget.plants[index];
              return ListTile(
                title: Text(plant.values[0]),
                //leading: Image.network(plant.imageUrl),
                subtitle: Text('Botanic Name: ${plant.values[1]}'),
                trailing: Column(
                  children: <Widget>[
                    ElevatedButton(
                        child: Text('Add Plant'),
                        onPressed: () {
                          addedPlants.add(plant);
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
  }
}

class selectedPlants extends StatelessWidget {
  final Plant plant;
  final List<String> plantStr = [];

  final List<String> attr = [
    'Common Name',
    'Botanic Name',
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
    'Elevation Guide',
    'Description',
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
    String url = plantStr[20];
    String fixedUrl = url.replaceAll("plantselect.org", "plantselect.org/plant");
    final Uri uri = Uri.parse(fixedUrl);

    return Scaffold(
      appBar: AppBar(
          title: new InkWell(
              child: new Text(
                'Additional Info',
                style: TextStyle(
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () => launchUrl(uri, webOnlyWindowName: "_blank"))),
      body: ListView.builder(
          itemCount: plantInfo.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(plantInfo[index]);
          }),
    );
  }
}
