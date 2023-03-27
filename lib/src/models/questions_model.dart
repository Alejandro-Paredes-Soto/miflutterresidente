import 'dart:convert';

QuestionModel questionModelFromJson(String str) =>
    QuestionModel.fromJson(json.decode(str));

class QuestionModel {
  List<String> answer = [];
  String idFAQ;
  String nameFAQ;
  String descriptionFAQ;
  String note;
  String linkYT;
  QuestionModel(
      {this.idFAQ = '',
      this.nameFAQ = '',
      this.descriptionFAQ = '',
      this.note = '',
      this.linkYT = ''});

  factory QuestionModel.fromJson(Map<String, dynamic> json) => QuestionModel(
        idFAQ: json["idFAQ"],
        nameFAQ: json["nameFAQ"],
        descriptionFAQ: json["descriptionFAQ"],
        note: json["note"],
        linkYT: json["linkYT"],
      );
}
