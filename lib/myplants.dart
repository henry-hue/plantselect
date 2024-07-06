import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'package:collection/collection.dart';


class MyPlants extends StatefulWidget {
  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {

 Future<List<Plant>> fetchPlants() async {
    final String url =
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
                title: Text(plant.values[0]),
                //leading: Image.network(plant.imageUrl),
                subtitle: Text('Botanic Name: ${plant.values[1]}'),
                

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


class selectedPlants extends StatelessWidget {
  final Plant plant;
  final List<String> plantStr = [];

  final List<String> attr = [
    'Date',	
    'Botanic Name',
    'Notes'
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
  return Scaffold(
      appBar: AppBar(
        title:  new Text(plant.values[1]),
      ),
      body: ListView.builder(
    itemCount: plantInfo.length,
    itemBuilder: (BuildContext context,int index){
  return Text(plantInfo[index]);
}),
      );

}
}

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar Sample')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Change brightness mode',
                  child: IconButton(
                    isSelected: isDark,
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.brightness_2_outlined),
                  ),
                )
              ],
            );
          }, suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
        ),
      ),
    );
  }
}

