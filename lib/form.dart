import 'dart:convert';

/// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String Date;
  String Plant;
  String Living;
  String Quantity;
  String Nursery;

  FeedbackForm(this.Date, this.Plant, this.Living, this.Quantity, this.Nursery);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm("${json['Date']}", "${json['Plant']}",
        "${json['Living']}", "${json['Quantity']}",
        "${json['Nursery']}");
  }

  // Method to make GET parameters.
  dynamic toJson() => jsonEncode({
        'date': Date,
        'plant': Plant,
        'Living': Living,
        'Quantity': Quantity,
        'Nursery': Nursery,
        'userName': 'rraymond'
      });
}
