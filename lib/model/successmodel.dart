// To parse this JSON data, do
// final successModel = successModelFromJson(jsonString);

import 'dart:convert';

SuccessModel successModelFromJson(String str) =>
    SuccessModel.fromJson(json.decode(str));

String successModelToJson(SuccessModel data) => json.encode(data.toJson());

class SuccessModel {
  SuccessModel({this.status, this.message, this.result});

  int? status;
  String? message;
  List<dynamic>? result;

  factory SuccessModel.fromJson(Map<String, dynamic> json) => SuccessModel(
      status: json["status"],
      message: json["message"],
      result: json["result"] == null
          ? []
          : List<dynamic>.from(json["result"].map((x) => x)));

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x) ?? {}),
      };
}
