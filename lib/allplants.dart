// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';


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
const tab = 'rraymond';

class AddPlant extends StatefulWidget {
  const AddPlant({super.key, required this.plants});
  final List<Plant> plants;

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // TextField Controllers
  //TextEditingController DateController = TextEditingController();
  TextEditingController PlantController = TextEditingController();
  TextEditingController LivingController = TextEditingController();
  TextEditingController QuantityController = TextEditingController();
  TextEditingController NurseryController = TextEditingController();

   // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
      final snackBar = SnackBar(content: Text(message));
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);

     // _scaffoldKey.currentState!.showSnackBar(snackBar); 
  }
  
  void addRow() async {
    // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  print("hello");
   // get worksheet by its title
  var sheet = ss.worksheetByTitle(tab);
  // create worksheet if it does not exist yet
  sheet ??= await ss.addWorksheet(tab);

  // update cell at 'B2' by inserting string 'new'
  DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day); 
    String justDate = date.toString().substring(0,10);
  //await sheet.values.insertValue(DateController.text, column: 1, row: 2);
  final newRow = {
    'Date': justDate,
    'Plant': PlantController.text,
    'Living': LivingController.text,
    'Quantity': QuantityController.text,
    'Nursery': NurseryController.text
  };
  await sheet.values.map.appendRow(newRow);

  }
  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {
    
    // Validate returns true if the form is valid, or false
    // otherwise.
    // if (_formKey.currentState!.validate()) {
    //   // If the form is valid, proceed.
    //   FeedbackForm feedbackForm = FeedbackForm(
    //       justDate,
    //       PlantController.text,
    //       LivingController.text,
    //       QuantityController.text,
    //       NurseryController.text);

    //   FormController formController = FormController();

    //   _showSnackbar("Submitting Feedback");

    //   // Submit 'feedbackForm' and save it in Google Sheets.
    //   formController.submitForm(feedbackForm, (String response) {
    //     print("Response: $response");
    //     if (response == FormController.STATUS_SUCCESS) {
    //       // Feedback is saved succesfully in Google Sheets.
    //       _showSnackbar("Feedback Submitted");
    //     } else {
    //       // Error Occurred while saving data in Google Sheets.
    //       _showSnackbar("Error Occurred!");
    //     }
    //   });
    // }
    
    addRow();

  }
  

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        );
    DateTime now = new DateTime.now();
    DateTime date = new DateTime(now.year, now.month, now.day); 
    String justDate = date.toString().substring(0,10);

    return MaterialApp(
      
      key: _scaffoldKey,
      theme: themeData,
      home: Scaffold(
        
        appBar: AppBar(title: const Text('search for plant or type in plant name')),
        body: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget> [
          SearchAnchor(
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
            );
          }, suggestionsBuilder:
          (BuildContext context, SearchController controller) {
            String searchText = controller.text;
            List<Plant> filteredPlants = widget.plants.where((plant) =>
              plant.values[0].toLowerCase().contains(searchText.toLowerCase()))
          .toList();
            return List<ListTile>.generate(filteredPlants.length, (int index) {
              final String item = filteredPlants[index].values[0];
              return ListTile(
                title: Text(item),
                onTap: () {
                  PlantController.text = item;
                  }
                  );
                },
              );
            }
            ),
            Form(
                key: _formKey,
                child:
                  Padding(padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      
                      TextFormField(
                        controller: PlantController,
                        decoration: InputDecoration(
                          labelText: 'Plant Name'
                        ),
                      ),
                      TextFormField(
                        controller: LivingController,
                        decoration: InputDecoration(
                          labelText: 'Alive or Dead',
                        ),
                      ),
                      TextFormField(
                        controller: QuantityController,
                        decoration: InputDecoration(
                          labelText: 'Quantity',
                        ),
                      ),
                      TextFormField(
                        controller: NurseryController,
                        decoration: InputDecoration(
                          labelText: 'Nursery',
                        ),
                      ),
                    ],
                  ),
                ) 
              ),
              ElevatedButton(
                onPressed:_submitForm,
                child: Text('Submit to My Plants'),
              ),
          ]
          )
            )
            )
            );
          }
        
  }              


// class selectedPlants extends StatelessWidget {
//   final Plant plant;
//   final List<String> plantStr = [];

//   final List<String> attr = [
//     'Common Name',
//     'Botanic Name',
//     'Plant Type',
//     'Height',
//     'Width',
//     'Flowering Season',
//     'Flower Color',
//     'Sun',
//     'Water Needs',
//     'USDA Hardiness Zone',
//     'Soil Type',
//     'Deer Resistant',
//     'Good for Pollination',
//     'Winter Interest',
//     'North American Native',
//     'Year Introduced',
//     'Annual Commercial Maintenance',
//     '5-10 Year Commercial Maintenance',
//     'Elevation Guide',
//     'Description',
//   ];
//   final List<String> plantInfo = [];

//   selectedPlants({required this.plant});
//   @override
//   Widget build(BuildContext context) {
//     for (final value in plant.values) {
//       plantStr.add(value.toString());
//     }

//     for (final pairs in IterableZip([attr, plantStr])) {
//       plantInfo.add('${pairs[0]} : ${pairs[1]}');
//     }
//     String url = plantStr[20];
//     String fixedUrl = url.replaceAll("plantselect.org", "plantselect.org/plant");
//     final Uri uri = Uri.parse(fixedUrl);

//     return Scaffold(
//       appBar: AppBar(
//           title: new InkWell(
//               child: new Text(
//                 'Additional Info',
//                 style: TextStyle(
//                   decoration: TextDecoration.underline,
//                 ),
//               ),
//               onTap: () => launchUrl(uri, webOnlyWindowName: "_blank"))),
              

//       body: ListView.builder(
//           itemCount: plantInfo.length,
//           itemBuilder: (BuildContext context, int index) {
//             return Text(plantInfo[index]);
//           }),
//     );
//   }
// }

