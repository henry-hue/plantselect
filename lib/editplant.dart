import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:image_picker/image_picker.dart';
import 'credentials.dart';
import 'main.dart';

class EditPlant extends StatefulWidget {
  const EditPlant({super.key, required this.plant, required this.username});
  final List plant;
  final String username;

  @override
  State<EditPlant> createState() => _EditPlantState();
}

class _EditPlantState extends State<EditPlant> {
  final _formKey = GlobalKey<FormState>();

  // TextField Controllers
  //TextEditingController DateController = TextEditingController();
  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();

  bool isDead = false;
  String living = 'Alive';

  void addRow() async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);

    // get worksheet by its title
    var sheet = ss.worksheetByTitle(widget.username);
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet(widget.username);

    if (isDead) {
      living = 'Dead';
    }

    var index = widget.plant[0];
    //await sheet.values.map.appendRow(newRow);
    await sheet.values
        .insertValueByKeys(living, columnKey: 'Living', rowKey: index);
    await sheet.values.insertValueByKeys(quantityController.text,
        columnKey: 'Quantity', rowKey: index);
  }

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {
    addRow();

    Navigator.pop(context);
  }

  XFile? imageFile;

  selectFile() async {
    XFile? file = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1800, maxWidth: 1800);

    if (file != null) {
      setState(() {
        imageFile = XFile(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
              backgroundColor: primaryColor,

          title: Image.asset('assets/images/logo.png'),
        ),
        body: Center(
         
              
          
            child: ListView(
             
                  
                children: <Widget>[
                  Padding(
                        padding: const EdgeInsets.only(top: 10.0, left: 20),
                  child: Text('''Edit the ${widget.plant[4]} ${widget.plant[2]}''',
              style: Theme.of(context).textTheme.titleLarge!
              ),
                  ),

              Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity',
                          ),
                        ),
                        FormField<bool>(builder: (state) {
                          return CheckboxListTile(
                              value: isDead,
                              title: const Text('Plant is Dead'),
                              onChanged: (value) {
                                setState(() {
                                  //save checkbox value to variable that store terms and notify form that state changed
                                  isDead = !isDead;
                                  state.didChange(value);
                                });
                              });
                        }),
                      ],
                    ),
                  )),
              ElevatedButton(
                  onPressed: _submitForm, child: const Text('Save Changes')),
            ]
            )
          
            )
            );
  }
}
