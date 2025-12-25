// To parse this JSON data, do
//
//     final prescriptionDetailModel = prescriptionDetailModelFromJson(jsonString);

import 'dart:convert';

PrescriptionDetailModel prescriptionDetailModelFromJson(String str) =>
    PrescriptionDetailModel.fromJson(json.decode(str));

String prescriptionDetailModelToJson(PrescriptionDetailModel data) =>
    json.encode(data.toJson());

class PrescriptionDetailModel {
  PrescriptionDetailModel({
    this.status,
    this.message,
    this.result,
  });

  int? status;
  String? message;
  List<Result>? result;

  factory PrescriptionDetailModel.fromJson(Map<String, dynamic> json) =>
      PrescriptionDetailModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(
                json["result"]?.map((x) => Result.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  Result({
    this.symptoms,
    this.diagnosis,
    this.date,
    this.prescription,
  });

  String? symptoms;
  String? diagnosis;
  DateTime? date;
  List<Prescription>? prescription;

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        symptoms: json["symptoms"],
        diagnosis: json["diagnosis"],
        date: DateTime.parse(json["date"]),
        prescription: json["prescription"] != null
            ? List<Prescription>.from(
                json["prescription"].map((x) => Prescription.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "symptoms": symptoms,
        "diagnosis": diagnosis,
        "date":
            "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "prescription":
            List<dynamic>.from(prescription!.map((x) => x.toJson())),
      };
}

class Prescription {
  Prescription({
    this.id,
    this.appointmentId,
    this.medicineId,
    this.amount,
    this.howMay,
    this.howLong,
    this.whenToTake,
    this.note,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.name,
    this.form,
    this.power,
  });

  String? id;
  String? appointmentId;
  String? medicineId;
  String? amount;
  String? howMay;
  String? howLong;
  String? whenToTake;
  String? note;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;
  String? form;
  String? power;

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json["id"],
        appointmentId: json["appointment_id"],
        medicineId: json["medicine_id"],
        amount: json["amount"],
        howMay: json["how_may"],
        howLong: json["how_long"],
        whenToTake: json["when_to_take"],
        note: json["note"],
        status: json["status"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        name: json["name"],
        form: json["form"],
        power: json["power"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "appointment_id": appointmentId,
        "medicine_id": medicineId,
        "amount": amount,
        "how_may": howMay,
        "how_long": howLong,
        "when_to_take": whenToTake,
        "note": note,
        "status": status,
        "created_at": createdAt.toString(),
        "updated_at": updatedAt.toString(),
        "name": name,
        "form": form,
        "power": power,
      };
}
