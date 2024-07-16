import 'package:gsheets/gsheets.dart';

const _credentials = r'''
{
  "type": "service_account",
  "project_id": "gsheet-access-429203",
  "private_key_id": "b3f0d46463047aa0dcc9c509f450b07d5b7ed5c6",
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
const tab = 'rob4';
void addRow() async {
    // init GSheets
  final gsheets = GSheets(_credentials);
  // fetch spreadsheet by its id
  final ss = await gsheets.spreadsheet(_spreadsheetId);

  print("hi");
   // get worksheet by its title
  var sheet = ss.worksheetByTitle(tab);
  // create worksheet if it does not exist yet
  sheet ??= await ss.addWorksheet(tab);

  // update cell at 'B2' by inserting string 'new'
  await sheet.values.insertValue('newt', column: 2, row: 2);
  // prints 'new'
  print(await sheet.values.value(column: 2, row: 2));
  // get cell at 'B2' as Cell object
  final cell = await sheet.cells.cell(column: 2, row: 2);
  // prints 'new'
  print(cell.value);
  // update cell at 'B2' by inserting 'new2'
  await cell.post('new2');
  // prints 'new2'
  print(cell.value);
  // also prints 'new2'
  print(await sheet.values.value(column: 2, row: 2));
}
