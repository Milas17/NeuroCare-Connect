// To parse this JSON data, do
//
//     final getMedicineListModel = getMedicineListModelFromJson(jsonString);

import 'dart:convert';

GetMedicineListModel getMedicineListModelFromJson(String str) =>
    GetMedicineListModel.fromJson(json.decode(str));

String getMedicineListModelToJson(GetMedicineListModel data) =>
    json.encode(data.toJson());

class GetMedicineListModel {
  int? status;
  String? message;
  List<Result>? result;

  GetMedicineListModel({
    this.status,
    this.message,
    this.result,
  });

  factory GetMedicineListModel.fromJson(Map<String, dynamic> json) =>
      GetMedicineListModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? [] // if null, return empty list
            : List<Result>.from(
                json["result"].map((x) => Result.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class Result {
  String? pillName;
  int? total;

  Result({
    this.pillName,
    this.total,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        pillName: json["pill_name"],
        total: json["total"],
      );

  Map<String, dynamic> toJson() => {
        "pill_name": pillName,
        "total": total,
      };
}
