import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'plant.dart';
import 'allplants.dart';
import 'main.dart';
import 'constants.dart';
import 'selectedplants.dart';

class MyPlants extends StatefulWidget {
  MyPlants(
      {super.key,
      required this.plants,
      required this.picPath,
      required this.username,
      required this.userId,
      required this.logout,
      required this.deleteAccount});
  final List<Plant> plants;
  final Directory? picPath;
  final String username;
  final Function logout;
  final int userId;
  final Function deleteAccount;
  bool sort = true;
  int columnIndex = 0;

  @override
  State<MyPlants> createState() => _MyPlantsState();
}

class _MyPlantsState extends State<MyPlants> {
  var isAscending = true;
  var sortColumnIndex = 0;
  int currentPageIndex = 0;
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

  

  Future<void> sheetsPlants() async {
    var response = await http.get(
      Uri.parse(
          '${Constants.apiUrl}/api/plants/user-list?userId=${widget.userId}&wishlist=${currentPageIndex == 2 ? 'Y' : 'N'}'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer ${Constants.apiAuthToken}'
      },
    );
    List<dynamic> plants = json.decode(response.body);
    setState(() {
      myPlants = plants.map((plant) => plant as Map<String, dynamic>).toList();
    });
  }

  void goToAddPlant() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => AddPlant(
                  //myPlants: widget.myPlants,
                  plants: widget.plants,
                  picPath: widget.picPath,
                  username: widget.username,
                  userId: widget.userId,
                  wishList: (currentPageIndex == 2),
                ))).then((value) {
      setState(() {
        sheetsPlants();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double myToolbarHeight = 120;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: true,
        //leadingWidth: 25,
        backgroundColor: primaryColor,
        title: SizedBox(
          height: myToolbarHeight,
          //width: 600,
          child: Image.asset('assets/images/finalfinaldesign.png'),
        ),
        toolbarHeight: myToolbarHeight,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 20)),
            // ExpansionTile(title: Text('Sort By:'), children: [
            //   ListTile(
            //     title: Text('Date'),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         sortOrder = SortOrder.date;
            //       });
            //     },
            //   ),
            //   ListTile(
            //     title: Text('Common Name'),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         sortOrder = SortOrder.common;
            //       });
            //     },
            //   ),
            //   ListTile(
            //     title: Text('Scientific Name'),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         sortOrder = SortOrder.scientific;
            //       });
            //     },
            //   ),
            //   ListTile(
            //     title: Text('Dead Plants'),
            //     onTap: () {
            //       Navigator.pop(context);
            //       setState(() {
            //         sortOrder = SortOrder.deadPlants;
            //       });
            //     },
            //   ),
            // ]),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                Navigator.pop(context);
                widget.logout();
              },
            ),
            ListTile(
              title: Text('Delete Account'),
              onTap: () {
                Navigator.pop(context);
                widget.deleteAccount();
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
            // NavigationDestination(
            //   selectedIcon: Icon(Icons.map),
            //   icon: Icon(Icons.map_outlined),
            //   label: 'Map',
            // ),
            NavigationDestination(
              selectedIcon: Icon(Icons.card_giftcard),
              icon: Icon(Icons.card_giftcard_outlined),
              label: 'My WishList',
            ),
          ]),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              sortAscending: widget.sort,
              sortColumnIndex: widget.columnIndex,
              columns: <DataColumn>[
                DataColumn(
                  label: const Expanded(
                    child: Text(
                      'Common Name',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      widget.sort = columnIndex == widget.columnIndex
                          ? !widget.sort
                          : true;
                      widget.columnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Expanded(
                    child: Text(
                      'Botanic Name',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      widget.sort = columnIndex == widget.columnIndex
                          ? !widget.sort
                          : true;
                      widget.columnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Expanded(
                    child: Text('Quantity',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                  onSort: (columnIndex, ascending) {
                    setState(() {
                      widget.sort = columnIndex == widget.columnIndex
                          ? !widget.sort
                          : true;
                      widget.columnIndex = columnIndex;
                    });
                    onSortColumn(columnIndex, ascending);
                  },
                ),
                DataColumn(
                  label: const Expanded(
                    child: Text('More Info',
                        style: TextStyle(fontStyle: FontStyle.italic)),
                  ),
                ),
              ],
              rows: myPlants
                  .where((plant) =>
                      plant['wishlist'] == (currentPageIndex == 2 ? 'Y' : 'N'))
                  .map((plant) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 250),
                        child: Text(plant['common_name'].toString()),
                      ),
                    ),
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 250),
                        child: Text(plant['botanic_name'].toString()),
                      ),
                    ),
                    DataCell(Text(plant['quantity'].toString())),
                    DataCell(ElevatedButton.icon(
                      iconAlignment: IconAlignment.end,
                      icon: const Icon(Icons.description),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectedPlants(
                                    username: widget.username,
                                    userId: widget.userId,
                                    plant: plant,
                                    picPath: widget.picPath))).then((value) {
                          setState(() {
                            sheetsPlants();
                          });
                        });
                      },
                      label: const Text('Plant Info'),
                    ))
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
