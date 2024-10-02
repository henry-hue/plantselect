import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:image_picker/image_picker.dart';
import 'credentials.dart';


class EditPlant extends StatefulWidget {
  const EditPlant({super.key, required this.plant, required this.username});
  final List plant;
  final String username;

  @override
  State<EditPlant> createState() => _EditPlantState();

  
}

class _EditPlantState extends State<EditPlant> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();


  // TextField Controllers
  //TextEditingController DateController = TextEditingController();
  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController nurseryController = TextEditingController();


  bool isAlive = true;
  bool isSeed = true;

  void addRow() async {

    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);

    // get worksheet by its title
    var sheet = ss.worksheetByTitle(widget.username);
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet(widget.username);

    
    
    var index = widget.plant[0];
    //await sheet.values.map.appendRow(newRow);
      await sheet.values.insertValueByKeys(isSeed, columnKey: 'Seed', rowKey: index);
      await sheet.values.insertValueByKeys(isAlive, columnKey: 'Living', rowKey: index);
      await sheet.values.insertValueByKeys(quantityController.text, columnKey: 'Quantity', rowKey: index);

  }

  // Method to Submit Feedback and save it in Google Sheets
  void _submitForm() {
    addRow();
    
  }


  XFile? imageFile;

  selectFile() async {
    XFile? file = await ImagePicker().pickImage(
    source: ImageSource.camera, maxHeight: 1800, maxWidth: 1800);
    
    if (file != null) {
      setState(() {
        imageFile = XFile(file.path);
      });
      
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        key: _scaffoldKey,
        
        home: Scaffold(
            appBar: AppBar(
        
        backgroundColor: Colors.lightGreen,
        
        title: Image.asset('assets/images/logo.png'),
      ),
            body: Center(
                child: ListView(
                    //mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
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
                                  value: isAlive,
                                  title: const Text('Living Plant'),
                                  onChanged: (value) {
                                    setState(() {
                                      //save checkbox value to variable that store terms and notify form that state changed
                                      isAlive = !isAlive;
                                      state.didChange(value);
                                    });
                                  });
                            }),
                            FormField<bool>(builder: (state) {
                              return CheckboxListTile(
                                  value: isSeed,
                                  title: const Text('Seed'),
                                  onChanged: (value) {
                                    setState(() {
                                      //save checkbox value to variable that store terms and notify form that state changed
                                      isSeed = !isSeed;
                                      state.didChange(value);
                                    });
                                  });
                            }),
                          ],
                        ),
                      )),
                      ElevatedButton(onPressed: _submitForm,
                       child: const Text('Save Changes')),
                 
                ]))));
  }
}