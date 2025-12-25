// To parse this JSON data, do
//
//     final patientListGraphModel = patientListGraphModelFromJson(jsonString);

import 'dart:convert';

PatientListGraphModel patientListGraphModelFromJson(String str) =>
    PatientListGraphModel.fromJson(json.decode(str));

String patientListGraphModelToJson(PatientListGraphModel data) =>
    json.encode(data.toJson());

class PatientListGraphModel {
  int? status;
  String? message;
  List<Result>? result;

  PatientListGraphModel({
    this.status,
    this.message,
    this.result,
  });

  factory PatientListGraphModel.fromJson(Map<String, dynamic> json) =>
      PatientListGraphModel(
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
  int? monday;
  int? tuesday;
  int? wednesday;
  int? thursday;
  int? friday;
  int? saturday;
  int? sunday;

  Result({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        monday: json["Monday"],
        tuesday: json["Tuesday"],
        wednesday: json["Wednesday"],
        thursday: json["Thursday"],
        friday: json["Friday"],
        saturday: json["Saturday"],
        sunday: json["Sunday"],
      );

  Map<String, dynamic> toJson() => {
        "Monday": monday,
        "Tuesday": tuesday,
        "Wednesday": wednesday,
        "Thursday": thursday,
        "Friday": friday,
        "Saturday": saturday,
        "Sunday": sunday,
      };
}
