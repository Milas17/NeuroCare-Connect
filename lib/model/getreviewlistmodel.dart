// To parse this JSON data, do
//
//     final feedbackModel = feedbackModelFromJson(jsonString);

import 'dart:convert';

GetReviewListModel feedbackModelFromJson(String str) =>
    GetReviewListModel.fromJson(json.decode(str));

String feedbackModelToJson(GetReviewListModel data) =>
    json.encode(data.toJson());

class GetReviewListModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  GetReviewListModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory GetReviewListModel.fromJson(Map<String, dynamic> json) =>
      GetReviewListModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? []
            : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
        totalRows: json["total_rows"],
        totalPage: json["total_page"],
        currentPage: json["current_page"],
        morePage: json["more_page"],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
        "total_rows": totalRows,
        "total_page": totalPage,
        "current_page": currentPage,
        "more_page": morePage,
      };
}

class Result {
  int? id;
  int? commentId;
  int? patientId;
  int? doctorId;
  String? review;
  int? rating;
  int? status;
  String? createdAt;
  String? updatedAt;
  int? avgRating;
  String? patientName;
  String? patientsImg;

  Result({
    this.id,
    this.commentId,
    this.patientId,
    this.doctorId,
    this.review,
    this.rating,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.avgRating,
    this.patientName,
    this.patientsImg,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        commentId: json["comment_id"],
        patientId: json["patient_id"],
        doctorId: json["doctor_id"],
        review: json["review"],
        rating: json["rating"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        avgRating: json["avg_rating"],
        // patientName: json["patient_name"],
        patientName: json["patient_full_name"],
        // patientsImg: json["patients_img"],
        patientsImg: json["patient_image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "comment_id": commentId,
        "patient_id": patientId,
        "doctor_id": doctorId,
        "review": review,
        "rating": rating,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "avg_rating": avgRating,
        // "patient_name": patientName,
        "patient_full_name": patientName,
        // "patients_img": patientsImg,
        "patient_image": patientsImg,
      };
}
