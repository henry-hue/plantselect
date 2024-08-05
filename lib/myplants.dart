import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'package:collection/collection.dart';




class MyPlants extends StatefulWidget {
  const MyPlants({super.key, required this.plants});
  final List<Plant> plants;
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
              title: Center(child: Text('${plant.values[3]} ${plant.values[1]}',
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 15),)),
            subtitle: Center(child: 
            Text('''${plant.values[2]} ${plant.values[0]}
                    ''')),
                
                
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SelectedPlants(plant: plant),
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
  final List<String> plantStr = [];

  final List<String> attr = [
    'Date',	
    'Botanic Name',
    'Notes'
  ];
  final List<String> plantInfo = [];

  SelectedPlants({super.key, required this.plant});
  @override
  Widget build(BuildContext context) {
    for (final value in plant.values) {
      plantStr.add(value.toString());
    }
    

    for (final pairs in IterableZip([attr, plantStr])) {
      plantInfo.add('${pairs[0]} : ${pairs[1]}');
    }
  return Scaffold(
      appBar: AppBar(
        title:  Text(plant.values[1]),
      ),
      body: ListView.builder(
    itemCount: plantInfo.length,
    itemBuilder: (BuildContext context,int index){
  return Text(plantInfo[index]);
}),
      );
}
}