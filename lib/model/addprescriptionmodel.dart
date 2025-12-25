// To parse this JSON data, do
// final addPrescriptionModel = addPrescriptionModelFromJson(jsonString);

import 'dart:convert';

AddPrescriptionModel addPrescriptionModelFromJson(String str) =>
    AddPrescriptionModel.fromJson(json.decode(str));

String addPrescriptionModelToJson(AddPrescriptionModel data) =>
    json.encode(data.toJson());

class AddPrescriptionModel {
  AddPrescriptionModel({
    this.status,
    this.message,
    this.id,
  });

  int? status;
  String? message;
  int? id;

  factory AddPrescriptionModel.fromJson(Map<String, dynamic> json) =>
      AddPrescriptionModel(
        status: json["status"],
        message: json["message"],
        id: json["id"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "id": id,
      };
}
