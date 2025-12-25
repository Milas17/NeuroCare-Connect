// To parse this JSON data, do
//
//     final appointmentStatusModel = appointmentStatusModelFromJson(jsonString);

import 'dart:convert';

AppointmentStatusModel appointmentStatusModelFromJson(String str) =>
    AppointmentStatusModel.fromJson(json.decode(str));

String appointmentStatusModelToJson(AppointmentStatusModel data) =>
    json.encode(data.toJson());

class AppointmentStatusModel {
  List<Result>? result;

  AppointmentStatusModel({
    this.result,
  });

  factory AppointmentStatusModel.fromJson(Map<String, dynamic> json) =>
      AppointmentStatusModel(
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
      };
}

class Result {
  String? name;
  dynamic value;

  Result({
    this.name,
    this.value,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        name: json["name"],
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "value": value,
      };
}
