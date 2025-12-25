// To parse this JSON data, do
//
//     final appointmentModel = appointmentModelFromJson(jsonString);

import 'dart:convert';

AppointmentModel appointmentModelFromJson(String str) =>
    AppointmentModel.fromJson(json.decode(str));

String appointmentModelToJson(AppointmentModel data) =>
    json.encode(data.toJson());

class AppointmentModel {
  int? status;
  String? message;
  List<Result>? result;
  int? totalRows;
  int? totalPage;
  int? currentPage;
  bool? morePage;

  AppointmentModel({
    this.status,
    this.message,
    this.result,
    this.totalRows,
    this.totalPage,
    this.currentPage,
    this.morePage,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
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
  int? doctorId;
  int? patientId;
  int? appointmentSlotsId;
  String? date;
  String? startTime;
  String? endTime;
  int? diseasesId;
  String? symptoms;
  String? medicinesTaken;
  String? notes;
  String? insuranceDetails;
  int? status;
  String? createdAt;
  String? updatedAt;
  // int? appointmentType;
  String? appointmentType;
  String? diseasesName;
  String? specialitiesName;
  String? specialitiesImage;
  String? doctorName;
  String? doctorEmail;
  String? doctorMobileNo;
  String? doctorProfileImage;
  String? patientName;
  String? patientEmail;
  String? patientMobileNo;
  String? patientProfileImage;
  String? insuranceCompanyId;
  String? insuranceNo;
  String? doctorFirebaseId;
  String? patientFirebaseId;
  String? insuranceCardPic;
  String? allergiesToMedicine;
  String? qrcodeImg;
  String? type;
  String? roomId;
  String? attachment;

  Result(
      {this.id,
      this.doctorId,
      this.patientId,
      this.appointmentSlotsId,
      this.date,
      this.startTime,
      this.endTime,
      this.diseasesId,
      this.symptoms,
      this.medicinesTaken,
      this.notes,
      this.insuranceDetails,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.appointmentType,
      this.diseasesName,
      this.specialitiesName,
      this.specialitiesImage,
      this.doctorName,
      this.doctorEmail,
      this.doctorMobileNo,
      this.doctorProfileImage,
      this.patientName,
      this.patientEmail,
      this.patientMobileNo,
      this.patientProfileImage,
      this.insuranceCompanyId,
      this.doctorFirebaseId,
      this.patientFirebaseId,
      this.insuranceNo,
      this.insuranceCardPic,
      this.allergiesToMedicine,
      this.qrcodeImg,
      this.type,
      this.roomId,
      this.attachment});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        doctorId: json["doctor_id"],
        patientId: json["patient_id"],
        appointmentSlotsId: json["appointment_slots_id"],
        date: json["date"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        diseasesId: json["diseases_id"],
        symptoms: json["symptoms"],
        medicinesTaken: json["medicines_taken"],
        notes: json["notes"],
        insuranceDetails: json["insurance_details"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        appointmentType: json["appointment_type"],
        diseasesName: json["diseases_name"],
        specialitiesName: json["specialities_name"],
        specialitiesImage: json["specialities_image"],
        doctorName: json["doctor_name"],
        doctorEmail: json["doctor_email"],
        doctorMobileNo: json["doctor_mobile_no"],
        doctorProfileImage: json["doctor_profile_image"],
        // patientName: json["patient_name"],
        patientName: json["patient_full_name"],
        patientEmail: json["patient_email"],
        // patientMobileNo: json["patient_mobile_no"],
        patientMobileNo: json["patient_mobile_number"],
        // patientProfileImage: json["patient_profile_image"],
        patientProfileImage: json["patient_image"],
        insuranceCompanyId: json["insurance_company_id"],
        insuranceNo: json["insurance_no"],
        doctorFirebaseId: json["doctor_firebase_id"],
        patientFirebaseId: json["patient_firebase_id"],
        insuranceCardPic: json["insurance_card_pic"],
        allergiesToMedicine: json["allergies_to_medicine"],
        qrcodeImg: json["qrcode_img"],
        type: json["type"],
        roomId: json["room_id"],
        attachment: json["attachment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "doctor_id": doctorId,
        "patient_id": patientId,
        "appointment_slots_id": appointmentSlotsId,
        "date": date,
        "start_time": startTime,
        "end_time": endTime,
        "diseases_id": diseasesId,
        "symptoms": symptoms,
        "medicines_taken": medicinesTaken,
        "notes": notes,
        "insurance_details": insuranceDetails,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "appointment_type": appointmentType,
        "diseases_name": diseasesName,
        "specialities_name": specialitiesName,
        "specialities_image": specialitiesImage,
        "doctor_name": doctorName,
        "doctor_email": doctorEmail,
        "doctor_mobile_no": doctorMobileNo,
        "doctor_profile_image": doctorProfileImage,
        // "patient_name": patientName,
        "patient_full_name": patientName,
        "patient_email": patientEmail,
        // "patient_mobile_no": patientMobileNo,
        "patient_mobile_number": patientMobileNo,
        // "patient_profile_image": patientProfileImage,
        "patient_image": patientProfileImage,
        "doctor_firebase_id": doctorFirebaseId,
        "patient_firebase_id": patientFirebaseId,
        "insurance_company_id": insuranceCompanyId,
        "insurance_no": insuranceNo,
        "insurance_card_pic": insuranceCardPic,
        "allergies_to_medicine": allergiesToMedicine,
        "qrcode_img": qrcodeImg,
        "type": type,
        "room_id": roomId,
        "attachment": attachment,
      };
}
