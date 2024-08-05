import 'dart:convert';

/// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String date;
  String plant;
  String living;
  String quantity;
  String nursery;

  FeedbackForm(this.date, this.plant, this.living, this.quantity, this.nursery);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm("${json['Date']}", "${json['Plant']}",
        "${json['Living']}", "${json['Quantity']}",
        "${json['Nursery']}");
  }

  // Method to make GET parameters.
  dynamic toJson() => jsonEncode({
        'date': date,
        'plant': plant,
        'Living': living,
        'Quantity': quantity,
        'Nursery': nursery,
        'userName': 'rraymond'
      });
}
