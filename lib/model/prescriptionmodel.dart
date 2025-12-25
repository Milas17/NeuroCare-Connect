// To parse this JSON data, do
//
//     final prescriptionModel = prescriptionModelFromJson(jsonString);

import 'dart:convert';

PrescriptionModel prescriptionModelFromJson(String str) =>
    PrescriptionModel.fromJson(json.decode(str));

String prescriptionModelToJson(PrescriptionModel data) =>
    json.encode(data.toJson());

class PrescriptionModel {
  int? status;
  String? message;
  List<Result>? result;

  PrescriptionModel({
    this.status,
    this.message,
    this.result,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  int? id;
  int? appointmentId;
  String? symptoms;
  String? diagnosis;
  String? laboratoryTest;
  String? pillName;
  int? howMany;
  int? howLong;
  String? whenToTake;
  String? note;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.appointmentId,
    this.symptoms,
    this.diagnosis,
    this.laboratoryTest,
    this.pillName,
    this.howMany,
    this.howLong,
    this.whenToTake,
    this.note,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        appointmentId: json["appointment_id"],
        symptoms: json["symptoms"],
        diagnosis: json["diagnosis"],
        laboratoryTest: json["laboratory_test"],
        pillName: json["pill_name"],
        howMany: json["how_many"],
        howLong: json["how_long"],
        whenToTake: json["when_to_take"],
        note: json["note"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "appointment_id": appointmentId,
        "symptoms": symptoms,
        "diagnosis": diagnosis,
        "laboratory_test": laboratoryTest,
        "pill_name": pillName,
        "how_many": howMany,
        "how_long": howLong,
        "when_to_take": whenToTake,
        "note": note,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
