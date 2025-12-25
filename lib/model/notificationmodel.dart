// // To parse this JSON data, do
// //
// //     final notificationModel = notificationModelFromJson(jsonString);

// import 'dart:convert';

// NotificationModel notificationModelFromJson(String str) =>
//     NotificationModel.fromJson(json.decode(str));

// String notificationModelToJson(NotificationModel data) =>
//     json.encode(data.toJson());

// class NotificationModel {
//   int? status;
//   String? message;
//   List<Result>? result;
//   int? totalRows;
//   int? totalPage;
//   int? currentPage;
//   bool? morePage;

//   NotificationModel({
//     this.status,
//     this.message,
//     this.result,
//     this.totalRows,
//     this.totalPage,
//     this.currentPage,
//     this.morePage,
//   });

//   factory NotificationModel.fromJson(Map<String, dynamic> json) =>
//       NotificationModel(
//         status: json["status"],
//         message: json["message"],
//         result: json["result"] == null
//             ? []
//             : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
//         totalRows: json["total_rows"],
//         totalPage: json["total_page"],
//         currentPage: json["current_page"],
//         morePage: json["more_page"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
//         "total_rows": totalRows,
//         "total_page": totalPage,
//         "current_page": currentPage,
//         "more_page": morePage,
//       };
// }

// class Result {
//   int? id;
//   String? title;
//   String? message;
//   String? image;
//   int? doctorId;
//   int? patientId;
//   int? appointmentId;
//   // int? type;
//   String? type;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   String? doctorName;
//   String? doctorProfileImage;
//   String? patientName;
//   String? patientProfileImage;

//   Result({
//     this.id,
//     this.title,
//     this.message,
//     this.image,
//     this.doctorId,
//     this.patientId,
//     this.appointmentId,
//     this.type,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.doctorName,
//     this.doctorProfileImage,
//     this.patientName,
//     this.patientProfileImage,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         id: json["id"],
//         title: json["title"],
//         message: json["message"],
//         image: json["image"],
//         doctorId: json["doctor_id"],
//         patientId: json["patient_id"],
//         appointmentId: json["appointment_id"],
//         type: json["type"],
//         status: json["status"],
//         createdAt: json["created_at"],
//         updatedAt: json["updated_at"],
//         doctorName: json["doctor_name"],
//         doctorProfileImage: json["doctor_profile_image"],
//         patientName: json["patient_name"],
//         patientProfileImage: json["patient_profile_image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "title": title,
//         "message": message,
//         "image": image,
//         "doctor_id": doctorId,
//         "patient_id": patientId,
//         "appointment_id": appointmentId,
//         "type": type,
//         "status": status,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//         "doctor_name": doctorName,
//         "doctor_profile_image": doctorProfileImage,
//         "patient_name": patientName,
//         "patient_profile_image": patientProfileImage,
//       };
// }

// // To parse this JSON data, do
// //
// //     final notificationModel = notificationModelFromJson(jsonString);

// import 'dart:convert';

// NotificationModel notificationModelFromJson(String str) =>
//     NotificationModel.fromJson(json.decode(str));

// String notificationModelToJson(NotificationModel data) =>
//     json.encode(data.toJson());

// class NotificationModel {
//   int? status;
//   String? message;
//   List<Result>? result;
//   int? totalRows;
//   int? totalPage;
//   int? currentPage;
//   bool? morePage;

//   NotificationModel({
//     this.status,
//     this.message,
//     this.result,
//     this.totalRows,
//     this.totalPage,
//     this.currentPage,
//     this.morePage,
//   });

//   factory NotificationModel.fromJson(Map<String, dynamic> json) =>
//       NotificationModel(
//         status: json["status"],
//         message: json["message"],
//         result: json["result"] == null
//             ? []
//             : List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
//         totalRows: json["total_rows"],
//         totalPage: json["total_page"],
//         currentPage: json["current_page"],
//         morePage: json["more_page"],
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? []),
//         "total_rows": totalRows,
//         "total_page": totalPage,
//         "current_page": currentPage,
//         "more_page": morePage,
//       };
// }

// class Result {
//   int? id;
//   String? title;
//   String? message;
//   String? image;
//   int? doctorId;
//   int? patientId;
//   int? appointmentId;
//   int? type;
//   int? status;
//   String? createdAt;
//   String? updatedAt;
//   String? doctorName;
//   String? doctorProfileImage;
//   String? patientName;
//   String? patientProfileImage;

//   Result({
//     this.id,
//     this.title,
//     this.message,
//     this.image,
//     this.doctorId,
//     this.patientId,
//     this.appointmentId,
//     this.type,
//     this.status,
//     this.createdAt,
//     this.updatedAt,
//     this.doctorName,
//     this.doctorProfileImage,
//     this.patientName,
//     this.patientProfileImage,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         id: json["id"],
//         title: json["title"],
//         message: json["message"],
//         image: json["image"],
//         doctorId: json["doctor_id"],
//         patientId: json["patient_id"],
//         appointmentId: json["appointment_id"],
//         type: json["type"],
//         status: json["status"],
//         createdAt: json["created_at"],
//         updatedAt: json["updated_at"],
//         doctorName: json["doctor_name"],
//         doctorProfileImage: json["doctor_profile_image"],
//         patientName: json["patient_name"],
//         patientProfileImage: json["patient_profile_image"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "title": title,
//         "message": message,
//         "image": image,
//         "doctor_id": doctorId,
//         "patient_id": patientId,
//         "appointment_id": appointmentId,
//         "type": type,
//         "status": status,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//         "doctor_name": doctorName,
//         "doctor_profile_image": doctorProfileImage,
//         "patient_name": patientName,
//         "patient_profile_image": patientProfileImage,
//       };
// }

class NotificationModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  NotificationModel(
      {this.status,
      this.message,
      this.result,
      this.currentPage,
      this.morePage,
      this.totalPage,
      this.totalRows});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['result'] != null) {
      result = <Result>[];
      json['result'].forEach((v) {
        result!.add( Result.fromJson(v));
      });
    }
    totalRows = json['total_rows'];
    totalPage = json['total_page'];
    currentPage = json['current_page'];
    morePage = json['more_page'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (result != null) {
      data['result'] = result!.map((v) => v.toJson()).toList();
    }
    data['total_rows'] = totalRows;
    data['total_page'] = totalPage;
    data['current_page'] = currentPage;
    data['more_page'] = morePage;
    return data;
  }
}

class Result {
  int? id;
  String? type;
  int? doctorId;
  int? patientId;
  int? drugstoreId;
  int? receptionistId;
  int? contentId;
  String? title;
  String? message;
  String? image;
  int? status;
  int? isRead;
  String? createdAt;
  String? updatedAt;
  int? appointmentId;
  String? doctorName;
  String? doctorProfileImage;
  String? patientName;
  String? patientProfileImage;

  Result(
      {this.id,
      this.type,
      this.doctorId,
      this.patientId,
      this.drugstoreId,
      this.receptionistId,
      this.contentId,
      this.title,
      this.message,
      this.image,
      this.status,
      this.isRead,
      this.createdAt,
      this.updatedAt,
      this.appointmentId});

  Result.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
    doctorId = json['doctor_id'];
    patientId = json['patient_id'];
    drugstoreId = json['drugstore_id'];
    receptionistId = json['receptionist_id'];
    contentId = json['content_id'];
    title = json['title'];
    message = json['message'];
    image = json['image'];
    status = json['status'];
    isRead = json['is_read'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    appointmentId = json['appointment_id'];
    doctorName = json["doctor_name"];
    doctorProfileImage = json["doctor_profile_image"];
    patientName = json["patient_name"];
    patientProfileImage = json["patient_profile_image"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['type'] = type;
    data['doctor_id'] = doctorId;
    data['patient_id'] = patientId;
    data['drugstore_id'] = drugstoreId;
    data['receptionist_id'] = receptionistId;
    data['content_id'] = contentId;
    data['title'] = title;
    data['message'] = message;
    data['image'] = image;
    data['status'] = status;
    data['is_read'] = isRead;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['appointment_id'] = appointmentId;
    data['doctor_name'] = doctorName;
    data['doctor_profile_image'] = doctorProfileImage;
    data['patient_name'] = patientName;
    data['patient_profile_image'] = patientProfileImage;

    return data;
  }
}
