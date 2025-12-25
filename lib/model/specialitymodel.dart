// To parse this JSON data, do
// final specialityModel = specialityModelFromJson(jsonString);

import 'dart:convert';

SpecialityModel specialityModelFromJson(String str) =>
    SpecialityModel.fromJson(json.decode(str));

String specialityModelToJson(SpecialityModel data) =>
    json.encode(data.toJson());

class SpecialityModel {
  int? status;
  String? message;
  List<Speciality>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  SpecialityModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory SpecialityModel.fromJson(Map<String, dynamic> json) =>
      SpecialityModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Speciality>.from(
                json["result"]?.map((x) => Speciality.fromJson(x)) ?? []),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null
            ? []
            : List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Speciality {
  int? id;
  String? name;
  String? image;
  int? status;
  String? createdAt;
  String? updatedAt;

  Speciality({
    this.id,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Speciality.fromJson(Map<String, dynamic> json) => Speciality(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
