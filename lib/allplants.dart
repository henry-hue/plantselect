// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'plant.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:collection/collection.dart';

import 'form_controller.dart';
import 'form.dart';
import 'gsheet.dart';


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

    addRow();
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
  

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        );

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
                        controller: DateController,
                        decoration: InputDecoration(
                          labelText: 'Date: mm/dd/yyyy'
                        ),
                      ),
                      TextFormField(
                        controller: PlantController,
                        decoration: InputDecoration(
                          labelText: 'Plant Name'
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
              

      body: ListView.builder(
          itemCount: plantInfo.length,
          itemBuilder: (BuildContext context, int index) {
            return Text(plantInfo[index]);
          }),
    );
  }
}

