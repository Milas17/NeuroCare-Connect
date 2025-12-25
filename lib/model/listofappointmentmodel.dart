// To parse this JSON data, do
// final listOfAppointmentModel = listOfAppointmentModelFromJson(jsonString);

import 'dart:convert';

ListOfAppointmentModel listOfAppointmentModelFromJson(String str) =>
    ListOfAppointmentModel.fromJson(json.decode(str));

String listOfAppointmentModelToJson(ListOfAppointmentModel data) =>
    json.encode(data.toJson());

class ListOfAppointmentModel {
  int? status;
  String? message;
  Result? result;

  ListOfAppointmentModel({
    this.status,
    this.message,
    this.result,
  });

  factory ListOfAppointmentModel.fromJson(Map<String, dynamic> json) =>
      ListOfAppointmentModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null
            ? Result.fromJson({})
            : Result.fromJson(json["result"]),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? {} : result?.toJson() ?? {},
      };
}

class Result {
  List<Datum>? today;
  List<Datum>? past;

  Result({
    this.today,
    this.past,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        today: List<Datum>.from(
            json["today"]?.map((x) => Datum.fromJson(x)) ?? []),
        past:
            List<Datum>.from(json["past"]?.map((x) => Datum.fromJson(x)) ?? []),
      );

  Map<String, dynamic> toJson() => {
        "today": List<dynamic>.from(today?.map((x) => x.toJson()) ?? []),
        "past": List<dynamic>.from(past?.map((x) => x.toJson()) ?? []),
      };
}

class Datum {
  int? id;
  int? doctorId;
  int? patientId;
  int? appointmentSlotsId;
  String? date;
  String? startTime;
  String? endTime;
  String? description;
  String? symptoms;
  String? doctorSymptoms;
  String? doctorDiagnosis;
  String? medicinesTaken;
  String? insuranceDetails;
  String? mobileNumber;
  int? status;
  String? createdAt;
  String? updatedAt;
  String? specialitiesName;
  String? specialitiesImage;
  String? doctorName;
  String? doctorImage;
  String? doctorEmail;
  String? doctorMobileNumber;
  String? patientsName;
  String? patientsEmail;
  String? patientsProfileImg;
  String? patientsMobileNumber;
  String? insuranceCompanyId;
  String? insuranceNo;
  String? insuranceCardPic;
  String? allergiesToMedicine;
  String? patientsQrcodeImg;

  Datum({
    this.id,
    this.doctorId,
    this.patientId,
    this.appointmentSlotsId,
    this.date,
    this.startTime,
    this.endTime,
    this.description,
    this.symptoms,
    this.doctorSymptoms,
    this.doctorDiagnosis,
    this.medicinesTaken,
    this.insuranceDetails,
    this.mobileNumber,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.specialitiesName,
    this.specialitiesImage,
    this.doctorName,
    this.doctorImage,
    this.doctorEmail,
    this.doctorMobileNumber,
    this.patientsName,
    this.patientsEmail,
    this.patientsProfileImg,
    this.patientsMobileNumber,
    this.insuranceCompanyId,
    this.insuranceNo,
    this.insuranceCardPic,
    this.allergiesToMedicine,
    this.patientsQrcodeImg,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: json["id"],
        doctorId: json["doctor_id"],
        patientId: json["patient_id"],
        appointmentSlotsId: json["appointment_slots_id"],
        date: json["date"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        description: json["description"],
        symptoms: json["symptoms"],
        doctorSymptoms: json["doctor_symptoms"],
        doctorDiagnosis: json["doctor_diagnosis"],
        medicinesTaken: json["medicines_taken"],
        insuranceDetails: json["insurance_details"],
        mobileNumber: json["mobile_number"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        specialitiesName: json["specialities_name"],
        specialitiesImage: json["specialities_image"],
        doctorName: json["doctor_name"],
        doctorImage: json["doctor_image"],
        doctorEmail: json["doctor_email"],
        doctorMobileNumber: json["doctor_mobile_number"],
        patientsName: json["patients_name"],
        patientsEmail: json["patients_email"],
        patientsProfileImg: json["patients_profile_img"],
        patientsMobileNumber: json["patients_mobile_number"],
        insuranceCompanyId: json["insurance_company_id"],
        insuranceNo: json["insurance_no"],
        insuranceCardPic: json["insurance_card_pic"],
        allergiesToMedicine: json["allergies_to_medicine"],
        patientsQrcodeImg: json["patients_qrcode_img"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "doctor_id": doctorId,
        "patient_id": patientId,
        "appointment_slots_id": appointmentSlotsId,
        "date": date,
        "startTime": startTime,
        "endTime": endTime,
        "description": description,
        "symptoms": symptoms,
        "doctor_symptoms": doctorSymptoms,
        "doctor_diagnosis": doctorDiagnosis,
        "medicines_taken": medicinesTaken,
        "insurance_details": insuranceDetails,
        "mobile_number": mobileNumber,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "specialities_name": specialitiesName,
        "specialities_image": specialitiesImage,
        "doctor_name": doctorName,
        "doctor_image": doctorImage,
        "doctor_email": doctorEmail,
        "doctor_mobile_number": doctorMobileNumber,
        "patients_name": patientsName,
        "patients_email": patientsEmail,
        "patients_profile_img": patientsProfileImg,
        "patients_mobile_number": patientsMobileNumber,
        "insurance_company_id": insuranceCompanyId,
        "insurance_no": insuranceNo,
        "insurance_card_pic": insuranceCardPic,
        "allergies_to_medicine": allergiesToMedicine,
        "patients_qrcode_img": patientsQrcodeImg,
      };
}
