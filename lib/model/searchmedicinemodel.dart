// To parse this JSON data, do
// final searchMedicineModel = searchMedicineModelFromJson(jsonString);

import 'dart:convert';

SearchMedicineModel searchMedicineModelFromJson(String str) =>
    SearchMedicineModel.fromJson(json.decode(str));

String searchMedicineModelToJson(SearchMedicineModel data) =>
    json.encode(data.toJson());

class SearchMedicineModel {
  int? status;
  String? message;
  List<Result>? result;

  SearchMedicineModel({
    this.status,
    this.message,
    this.result,
  });

  factory SearchMedicineModel.fromJson(Map<String, dynamic> json) =>
      SearchMedicineModel(
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
  int? id;
  String? name;
  String? form;
  String? power;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.name,
    this.form,
    this.power,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        form: json["form"],
        power: json["power"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "form": form,
        "power": power,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
