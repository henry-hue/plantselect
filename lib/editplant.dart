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
  TextEditingController plantController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController notesController = TextEditingController();

  bool isDead = false;
  @override
  void initState() {
    super.initState();
    quantityController.text = widget.plant[3];
    notesController.text = widget.plant[8];
    isDead = widget.plant[2] == 'Dead';
  }

  Future<dynamic> updateRow() async {
    // init GSheets
    final gsheets = GSheets(credentials);
    // fetch spreadsheet by its id
    final ss = await gsheets.spreadsheet(spreadsheetId);

    // get worksheet by its title
    var sheet = ss.worksheetByTitle(widget.username);
    // create worksheet if it does not exist yet
    sheet ??= await ss.addWorksheet(widget.username);

    String living = (isDead) ? "Dead" : "Alive";

    var index = widget.plant[0];
    //await sheet.values.map.appendRow(newRow);
    await sheet.values
        .insertValueByKeys(living, columnKey: 'Living', rowKey: index);
    await sheet.values.insertValueByKeys(quantityController.text,
        columnKey: 'Quantity', rowKey: index);
    return await sheet.values.insertValueByKeys(notesController.text,
        columnKey: 'Notes', rowKey: index);
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
            child: ListView(children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 20),
            child: Text('''Edit plant ${widget.plant[1]}''',
                style: Theme.of(context).textTheme.titleLarge!),
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
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                      ),
                    ),
                    CheckboxListTile(
                        value: isDead,
                        title: const Text('Mark Plant as Dead'),
                        onChanged: (value) {
                          setState(() {
                            isDead = !isDead;
                          });
                        }),
                  ],
                ),
              )),
          ElevatedButton(
              onPressed: () {
                updateRow().then((result) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                });
              },
              child: const Text('Save Changes')),
        ])));
  }
}
