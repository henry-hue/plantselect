// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import 'form_controller.dart';
import 'form.dart';

import 'package:gsheets/gsheets.dart';


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
  TextEditingController DateController = TextEditingController();
  TextEditingController PlantController = TextEditingController();
  TextEditingController NotesController = TextEditingController();

   // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
      final snackBar = SnackBar(content: Text(message));
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);

     // _scaffoldKey.currentState!.showSnackBar(snackBar); 
  }
  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {

    getSheet();
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed.
      FeedbackForm feedbackForm = FeedbackForm(
          DateController.text,
          PlantController.text,
          NotesController.text);

      FormController formController = FormController();

      _showSnackbar("Submitting Feedback");

      // Submit 'feedbackForm' and save it in Google Sheets.
      formController.submitForm(feedbackForm, (String response) {
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          // Feedback is saved succesfully in Google Sheets.
          _showSnackbar("Feedback Submitted");
        } else {
          // Error Occurred while saving data in Google Sheets.
          _showSnackbar("Error Occurred!");
        }
      });
    }
  }
  
 

  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-429220",
  "private_key_id": "411117d4ed4072be0b998c215671fedc01a9bc79",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCozx7gzo7L41F5\nR4IMUneZTpd6/Y067STb01W35Sdh28ot37ay+3fo5b8AmOaUlizGMz0yD0ZqcfWZ\nUyqa2Cih03j/XwhxHMzGfNyMUROlpLtARyVD4xE9pq85mtPlWwKS0I6U13UCmWyB\nTpVi6MkSHyJECZ4CSqLoAJGy1BXNcJG4IVSNIuXCibZHv1jAf0f6bPL2YCwWSUng\nrODvsAHYhEy1Q38Dh6FZaPOBCZ3w7mkeWbF1fmXgoxiZ/5twCwlSvLitnMJS/4ov\n4zRrLSqT44b1L0KMSTE709M3Yv8nMhWVP21zWzscwEwd+ySyW+HhVLc+/OQrq8zE\nBOuWJsTXAgMBAAECggEAIsiK1Ee7pMdyQks5wNA9VJmdHPqh30J+Fc22G+5b7w4a\n2tj+DGNEkfjFIppe6L8I+s4UDfyXxdc1hCJe5QklVjL8+6HZW3VTvJJ932vVYIxR\nCS2fwB1JsCpocLY2c0wNe7L9ri23LpHuibZnkbnltJY1uU9B/7bhWmzDmNWaqHnz\nKN3zNin6TJCmnx7CgraonxC4szGJc1+vW52sNWJ9rLGwtqOWEHYejdDv/DZizp9Y\nTAPoaGoTRPQHeV8XuE1vAqiaI2wPRB30D7yx/pYML4A/jy8yHghgeio+6QDFhciy\nVd7c0VHgXLPRwA3RaToNUDfTxD7Tr5oAbm8h1UBqAQKBgQDsokR44ZoEVSEJEVT6\nMvCoKkIcRobUNOfrSZhI7Lr5wFDVMFoSSFRa9+jgVQDWu9x3sH5j5FcXIh6D+7Z2\nTN5uulhsDxOzb2IgEQ/r2veLr7YE3K5RkHtGcrcgBF6HvfYNjyTvJTEM6xm9v+/Z\nwbIYAaQjV/ziqe74sWIIVe5IQwKBgQC2n9nmNUtMX9r3h5pDOfiSDiuZ8v3OFMVp\nmUKMuxh2NtkgnMraJvNLKMogRMkZnV7axK1rDvu2MaPj1V1yV9qRzB1iOu4DDm91\nYw6za6itWGp+KdD+FCyUmGDGPyf7iIKM53IZ511owtxFzREHKq7SLAdAQtsnc4aI\nsKxJFRth3QKBgApIgvE93JOTn3vlZOv6irrEG1tfNTzDj9CJwjRpFTcFRH3/O+rP\nedr6KwSUrRSn1UzePp/YrHA0616Q8bzyWjg1oOIRRanmjT0XgLmfKmLHoAFWFb01\nqiXFlm+twO3lM2wjbFd4JkmJbfTxAltUL4kbiSaADF1NRTVJgBkcot5BAoGABBc4\njkuLUD6lbP4Ampjl1H+0wlILFV6pvV/NedGHDr7TxkM81/4fXQOg43AnAQfhZA0b\nxVYklUQvY58X5MPLBZEI53ZidncQUBTT83jp4lgkqobNQ6O4C+wN3uLzRlMceYOF\nrsbb9MjInlellf+CwvpxfyMAPbX8wXsToN90KZECgYEAnaxiD8HqtJw+6JLKsDXb\nd7F1VPRhvWWKpYB0ddG2FTEeKo5njaQ8HtDVOeVs34pmtXFpjwz3RSHGiK/NEU5X\nd5OHfuvedyuHjpUnFlwsC0SJ7teEGYFStQu/Cutcs09baP5VkPqJzuZbQl8PXeg8\nHKxcMDxnQxWeyRLt/UXdikM=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-429220.iam.gserviceaccount.com",
  "client_id": "109873653600480588540",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-429220.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
static const _spreadsheetId = '1lHYYVl_AJE5lBt4F43CtAvuO7G2xXFgRFZ0jc4fyrCc';

// init GSheets
final gsheets = GSheets(_credentials);


void getSheet() async {
  // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  // get worksheet by its title
  var sheet = ss.worksheetByTitle('example');
  // create worksheet if it does not exist yet
  sheet ??= await ss.addWorksheet('example');

// update cell at 'B2' by inserting string 'new'
  await sheet.values.insertValue('making a good app', column: 2, row: 1);

}
 

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        );

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        
        appBar: AppBar(title: const Text('Add Plant')),
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
              //final Plant selectP = Plant filteredPlants[index];
              return ListTile(
                title: Text(item),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => selectedPlants(plant: filteredPlants[index]),
                    ),
                  );
                  });
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
                        controller: DateController,
                        
                        decoration: InputDecoration(
                          labelText: 'Date'
                        ),
                      ),
                      TextFormField(
                        controller: PlantController,
                        
                        
                        decoration: InputDecoration(
                          labelText: 'Plant'
                        ),
                      ),
                      TextFormField(
                        controller: NotesController,
                        
                        
                        decoration: InputDecoration(
                          labelText: 'Notes',
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
              floatingActionButton: FloatingActionButton(
        onPressed: () {
          
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => addingPlant(),
                    ),
                  );
                  
        },
      
        child: const Text('Add Plant', textAlign: TextAlign.center),
        
      ),

      body: ListView.builder(
          itemCount: plantInfo.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(plantInfo[index]);
          }),
    );
  }
}

class addingPlant extends StatelessWidget {
  //final Plant plant;

// Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a `GlobalKey<FormState>`,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // TextField Controllers
  TextEditingController DateController = TextEditingController();
  TextEditingController PlantController = TextEditingController();
  TextEditingController NotesController = TextEditingController();

   // Method to show snackbar with 'message'.
  _showSnackbar(String message) {
      final snackBar = SnackBar(content: Text(message));
      //ScaffoldMessenger.of(context).showSnackBar(snackBar);

     // _scaffoldKey.currentState!.showSnackBar(snackBar); 
  }
  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {

    getSheet();
    // Validate returns true if the form is valid, or false
    // otherwise.
    if (_formKey.currentState!.validate()) {
      // If the form is valid, proceed.
      FeedbackForm feedbackForm = FeedbackForm(
          DateController.text,
          PlantController.text,
          NotesController.text);

      FormController formController = FormController();

      _showSnackbar("Submitting Feedback");

      // Submit 'feedbackForm' and save it in Google Sheets.
      formController.submitForm(feedbackForm, (String response) {
        print("Response: $response");
        if (response == FormController.STATUS_SUCCESS) {
          // Feedback is saved succesfully in Google Sheets.
          _showSnackbar("Feedback Submitted");
        } else {
          // Error Occurred while saving data in Google Sheets.
          _showSnackbar("Error Occurred!");
        }
      });
    }
  }
  
 

  static const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheets-429220",
  "private_key_id": "411117d4ed4072be0b998c215671fedc01a9bc79",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCozx7gzo7L41F5\nR4IMUneZTpd6/Y067STb01W35Sdh28ot37ay+3fo5b8AmOaUlizGMz0yD0ZqcfWZ\nUyqa2Cih03j/XwhxHMzGfNyMUROlpLtARyVD4xE9pq85mtPlWwKS0I6U13UCmWyB\nTpVi6MkSHyJECZ4CSqLoAJGy1BXNcJG4IVSNIuXCibZHv1jAf0f6bPL2YCwWSUng\nrODvsAHYhEy1Q38Dh6FZaPOBCZ3w7mkeWbF1fmXgoxiZ/5twCwlSvLitnMJS/4ov\n4zRrLSqT44b1L0KMSTE709M3Yv8nMhWVP21zWzscwEwd+ySyW+HhVLc+/OQrq8zE\nBOuWJsTXAgMBAAECggEAIsiK1Ee7pMdyQks5wNA9VJmdHPqh30J+Fc22G+5b7w4a\n2tj+DGNEkfjFIppe6L8I+s4UDfyXxdc1hCJe5QklVjL8+6HZW3VTvJJ932vVYIxR\nCS2fwB1JsCpocLY2c0wNe7L9ri23LpHuibZnkbnltJY1uU9B/7bhWmzDmNWaqHnz\nKN3zNin6TJCmnx7CgraonxC4szGJc1+vW52sNWJ9rLGwtqOWEHYejdDv/DZizp9Y\nTAPoaGoTRPQHeV8XuE1vAqiaI2wPRB30D7yx/pYML4A/jy8yHghgeio+6QDFhciy\nVd7c0VHgXLPRwA3RaToNUDfTxD7Tr5oAbm8h1UBqAQKBgQDsokR44ZoEVSEJEVT6\nMvCoKkIcRobUNOfrSZhI7Lr5wFDVMFoSSFRa9+jgVQDWu9x3sH5j5FcXIh6D+7Z2\nTN5uulhsDxOzb2IgEQ/r2veLr7YE3K5RkHtGcrcgBF6HvfYNjyTvJTEM6xm9v+/Z\nwbIYAaQjV/ziqe74sWIIVe5IQwKBgQC2n9nmNUtMX9r3h5pDOfiSDiuZ8v3OFMVp\nmUKMuxh2NtkgnMraJvNLKMogRMkZnV7axK1rDvu2MaPj1V1yV9qRzB1iOu4DDm91\nYw6za6itWGp+KdD+FCyUmGDGPyf7iIKM53IZ511owtxFzREHKq7SLAdAQtsnc4aI\nsKxJFRth3QKBgApIgvE93JOTn3vlZOv6irrEG1tfNTzDj9CJwjRpFTcFRH3/O+rP\nedr6KwSUrRSn1UzePp/YrHA0616Q8bzyWjg1oOIRRanmjT0XgLmfKmLHoAFWFb01\nqiXFlm+twO3lM2wjbFd4JkmJbfTxAltUL4kbiSaADF1NRTVJgBkcot5BAoGABBc4\njkuLUD6lbP4Ampjl1H+0wlILFV6pvV/NedGHDr7TxkM81/4fXQOg43AnAQfhZA0b\nxVYklUQvY58X5MPLBZEI53ZidncQUBTT83jp4lgkqobNQ6O4C+wN3uLzRlMceYOF\nrsbb9MjInlellf+CwvpxfyMAPbX8wXsToN90KZECgYEAnaxiD8HqtJw+6JLKsDXb\nd7F1VPRhvWWKpYB0ddG2FTEeKo5njaQ8HtDVOeVs34pmtXFpjwz3RSHGiK/NEU5X\nd5OHfuvedyuHjpUnFlwsC0SJ7teEGYFStQu/Cutcs09baP5VkPqJzuZbQl8PXeg8\nHKxcMDxnQxWeyRLt/UXdikM=\n-----END PRIVATE KEY-----\n",
  "client_email": "gsheets@gsheets-429220.iam.gserviceaccount.com",
  "client_id": "109873653600480588540",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/gsheets%40gsheets-429220.iam.gserviceaccount.com",
  "universe_domain": "googleapis.com"
}
''';
static const _spreadsheetId = '1lHYYVl_AJE5lBt4F43CtAvuO7G2xXFgRFZ0jc4fyrCc';

// init GSheets
final gsheets = GSheets(_credentials);


void getSheet() async {
  // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  // get worksheet by its title
  var sheet = ss.worksheetByTitle('example');
  // create worksheet if it does not exist yet
  sheet ??= await ss.addWorksheet('example');

// update cell at 'B2' by inserting string 'new'
  await sheet.values.insertValue('a plant', column: 2, row: 2);

}

    /// Public factory
/// need this since the await needed to be async which couldnt be in constructor 
// /// I REMOVED STATIC
// Future<Spreadsheet> create() async {
  

//   // Do initialization that requires async
//   final ss = await gsheets.spreadsheet(_spreadsheetId);

//   // Return the fully initialized object
//   return ss;
// }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,  

      appBar: AppBar(
        title: Text('Add Plant'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Form(
                key: _formKey,
                child:
                  Padding(padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: DateController,
                        
                        decoration: InputDecoration(
                          labelText: 'Date'
                        ),
                      ),
                      TextFormField(
                        controller: PlantController,
                        
                        
                        decoration: InputDecoration(
                          labelText: 'Plant'
                        ),
                      ),
                      TextFormField(
                        controller: NotesController,
                        
                        
                        decoration: InputDecoration(
                          labelText: 'Notes',
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
            ],
          ),
        ),
    );
  }
}




