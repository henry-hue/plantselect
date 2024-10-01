import 'dart:io';
import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:collection/collection.dart';
import 'editplant.dart';
import 'package:gsheets/gsheets.dart';

const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheet-access-429203",
  "private_key_id": "b3f0d46463047aa0dcc9c509f450b07d5b7ed5c6",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDLGxGD21I+u0I7\nPQ0gkjgVm+pMMQzSVUf2b0f1liJLz4jyIixsK5g42sxRheY/aSCLpxdzHHK94eOX\nrh9Lt72yaUyzf0JXgf0oGQQxWCQF1Q5jV1ERevd5j1+AShK8vDmNliKjrg7jTrsg\nK0+WzQP/B7PEeghH5vYmKEWO6eraoPYxw586845LvBHvv6VuaZw9HlOyOi7h1YnY\nJX8tFjcFUUGCrw4O5gTjSptUpXjba/TE8KQhcmy6WnHK5P8XVhUZ+arvME4Jr4pC\ncLyIxnd6V4aGWX82v8BMKvke4w06wEooMeaACJXRjPR1RKjnP8i9mYQyKTcWcp/3\n/oxcUfk3AgMBAAECggEAArj5qqFRgGrFMAMY/nNHUi7VXLEZoWYoQUrrlYSuMAL3\nrHs9yjNpZnW0YHFhjT8NAyI5w77BYP86rElWvQ6Y+d/EefF+Q6sH6DYxorGyReu9\ntiIxAYF6+MOtvYwApUwGn3nAPB50r6JaCsvZ1MUpxQzm4X7bRo93hDps+EX1cnnI\nwKpY2Lrvs5MT2ElZXJon1e4I63ipnsYy0JCtXxaCdLpZg+n9FCgr/AG4UoWE2g8B\nzrV341CaXMHxThfyPPF2bpDD/XqaOm5PPXOKDsKIxY1W6AmKLghwIRs2aQkE2IFg\n5VSRYEYl4KsSsHagaUMw5SB8bXa43bfqBWbGLC2CBQKBgQD3yC9M4DKULp12vScY\n4qFtrp2aEX+QzUsTkInIEw9S2P/e+3ti2ZQBlkfyGBp7MidQyV18cqXMXCcUiVDk\nfvJAHBIhxmNN6XFgR9D8zvLxweNANEdk/zbpUuKmUUOD5QsrpSeVFt9uMNHaAy/5\n2Y4NnXHrXMU/0gTDqAqcvQVcRQKBgQDR145YKPyW4wxqt9uHdevlrih5FGSgSMFd\nuYzfPQfAsrZui20T7R/Zk+h7/4onT0POLHNdEsEQdEI1LWX3E3NQGkJK33w4gNU1\nRI9IKY24sP2vQzmGTqq9wRZXr1ZtpOePqYQ2EJD/LQ6h8FAqyZ8I++jIfjduLZ4q\nBpQKvK29SwKBgQCiUiUScokP5B3JrI6RUd440TxzsuTjwmldbsGkLUBLoNa2h/7D\nug+onn+RTFMEw81XsiKpJR4Sa4g6ft5cYgFnGDyUnbduUfCxBzsUcqpa0A6Ef/sJ\nYdviLCdIl1HodMLFm9L7a1mBgT/oV1A1mFzj9HGtoz+g2H/AgTQ6i+WYFQKBgEqU\nDacPihYmQ7d5+K/AHULYDtJZiRneQbsJwyNkEWlPGr9XFkFKuVMe2jWXsIYgCb0w\n1x9xFuS+LPmxVNfnNch2TLFHlGKQhzYTU8kV26SUYtTzU3KEavJduY8YZeM6BIJu\ngOqmIKJQZS7wtc0/MyKCRU1cbl7eH6RYCi12uVjZAoGBAKb7zcAmxPDqnRonETOw\njfREMc5A55jL7Qr4PZ/Wx6cnSgEybCWZH1edRbwM/2aErmHDrtaoXzwC5Wf/mZbS\n2yz0Cv8aJkeVX7TBd9aGLkpGThkbcSxEQyqe6t2HWU1pimPOKhjDIbTLHPXSYey4\nTFpyCowSLY7YSHXlVEew1+85\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheet-access-429203.iam.gserviceaccount.com",
  "client_id": "116158027720527848898",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheet-access-429203.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';

const _spreadsheetId = '1lHYYVl_AJE5lBt4F43CtAvuO7G2xXFgRFZ0jc4fyrCc';

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
    final gsheets = GSheets(_credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(_spreadsheetId);

    var sheet = ss.worksheetByTitle(widget.username);
      sheet ??= await ss.addWorksheet(widget.username);

    List<List<String>> plants = await sheet!.values.allRows();
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
