
/// FeedbackForm is a data class which stores data fields of Feedback.
class FeedbackForm {
  String Date;
  String Plant;
  String Notes;

  FeedbackForm(this.Date, this.Plant, this.Notes);

  factory FeedbackForm.fromJson(dynamic json) {
    return FeedbackForm("${json['Date']}", "${json['Plant']}",
        "${json['Notes']}");
  }

  // Method to make GET parameters.
  Map toJson() => {
        'date': Date,
        'plant': Plant,
        'notes': Notes,
        'userName': 'rraymondr'
      };
}
