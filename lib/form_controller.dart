
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'form.dart';

/// FormController is a class which does work of saving FeedbackForm in Google Sheets using 
/// HTTP GET request on Google App Script Web URL and parses response and sends result callback.
class FormController {
  
  // Google App Script Web URL.
  static const String url = ('https://script.google.com/macros/s/AKfycbwksZcn6sdzFTxKFzb2I0ttOgachwp8A_bgljMNR01eoypsdD8tQohzqOIT0SUKG6HW/exec');

  /// Async function which saves feedback, parses [feedbackForm] parameters
  /// and sends HTTP GET request on [URL]. On successful response, [callback] is called.
   void submitForm(
      FeedbackForm feedbackForm, void Function(String) callback) async {
    try {
      var uri = Uri.parse(url); 
      await http.post(uri, body: feedbackForm.toJson(), headers: {
          "content-type": "application/json"
        }).then((response) async {
        if (response.statusCode == 302) {
          var url = response.headers['location'];
          await http.get(url as Uri).then((response) {
            callback(convert.jsonDecode(response.body)['status']);
          });
        } else {
          callback(convert.jsonDecode(response.body)['status']);
        }
      });
    } catch (e) {
      print(e);
    }
  }
}