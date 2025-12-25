// To parse this JSON data, do
//
//     final appointmentDetailsModel = appointmentDetailsModelFromJson(jsonString);

import 'dart:convert';

AppointmentDetailsModel appointmentDetailsModelFromJson(String str) => AppointmentDetailsModel.fromJson(json.decode(str));

String appointmentDetailsModelToJson(AppointmentDetailsModel data) => json.encode(data.toJson());

class AppointmentDetailsModel {
    int? status;
    String? message;
    List<Result>? result;

    AppointmentDetailsModel({
        this.status,
        this.message,
        this.result,
    });

    factory AppointmentDetailsModel.fromJson(Map<String, dynamic> json) => AppointmentDetailsModel(
        status: json["status"],
        message: json["message"],
        result: json["result"] == null ? [] : List<Result>.from(json["result"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": result == null ? [] : List<dynamic>.from(result!.map((x) => x.toJson())),
    };
}

class Result {
    int? id;
    String? appointmentNo;
    int? doctorId;
    int? patientId;
    int? familyMemberType;
    String? relationPatientName;
    DateTime? date;
    String? startTime;
    String? endTime;
    int? appointmentSlotsId;
    int? appointmentScheduleId;
    int? diseasesId;
    String? symptoms;
    String? medicinesTaken;
    String? notes;
    String? attachment;
    String? roomId;
    int? status;
    String? createdAt;
    String? updatedAt;
    String? appointmentType;
    String? appointmentStatus;
    String? diseasesName;
    String? specialitName;
    String? specialitImage;
    String? slotsStartTime;
    String? slotsEndTime;
    String? doctorUserName;
    String? doctorFullName;
    String? doctorEmail;
    String? doctorMobileNumber;
    String? doctorFirebaseId;
    String? doctorImage;
    int? doctorAvgRating;
    String? patientUserName;
    String? patientFullName;
    String? patientEmail;
    String? patientMobileNumber;
    String? patientFirebaseId;
    String? patientImage;
    String? insuranceCompanyId;
    String? insuranceNo;
    String? allergiesToMedicine;
    String? insuranceCardPic;
    List<Payment>? payment;

    Result({
        this.id,
        this.appointmentNo,
        this.doctorId,
        this.patientId,
        this.familyMemberType,
        this.relationPatientName,
        this.date,
        this.startTime,
        this.endTime,
        this.appointmentSlotsId,
        this.appointmentScheduleId,
        this.diseasesId,
        this.symptoms,
        this.medicinesTaken,
        this.notes,
        this.attachment,
        this.roomId,
        this.status,
        this.createdAt,
        this.updatedAt,
        this.appointmentType,
        this.appointmentStatus,
        this.diseasesName,
        this.specialitName,
        this.specialitImage,
        this.slotsStartTime,
        this.slotsEndTime,
        this.doctorUserName,
        this.doctorFullName,
        this.doctorEmail,
        this.doctorMobileNumber,
        this.doctorFirebaseId,
        this.doctorImage,
        this.doctorAvgRating,
        this.patientUserName,
        this.patientFullName,
        this.patientEmail,
        this.patientMobileNumber,
        this.patientFirebaseId,
        this.patientImage,
        this.insuranceCompanyId,
        this.insuranceNo,
        this.allergiesToMedicine,
        this.insuranceCardPic,
        this.payment,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        appointmentNo: json["appointment_no"],
        doctorId: json["doctor_id"],
        patientId: json["patient_id"],
        familyMemberType: json["family_member_type"],
        relationPatientName: json["relation_patient_name"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        startTime: json["start_time"],
        endTime: json["end_time"],
        appointmentSlotsId: json["appointment_slots_id"],
        appointmentScheduleId: json["appointment_schedule_id"],
        diseasesId: json["diseases_id"],
        symptoms: json["symptoms"],
        medicinesTaken: json["medicines_taken"],
        notes: json["notes"],
        attachment: json["attachment"],
        roomId: json["room_id"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
        appointmentType: json["appointment_type"],
        appointmentStatus: json["appointment_status"],
        diseasesName: json["diseases_name"],
        specialitName: json["specialit_name"],
        specialitImage: json["specialit_image"],
        slotsStartTime: json["slots_start_time"],
        slotsEndTime: json["slots_end_time"],
        doctorUserName: json["doctor_user_name"],
        doctorFullName: json["doctor_full_name"],
        doctorEmail: json["doctor_email"],
        doctorMobileNumber: json["doctor_mobile_number"],
        doctorFirebaseId: json["doctor_firebase_id"],
        doctorImage: json["doctor_image"],
        doctorAvgRating: json["doctor_avg_rating"],
        patientUserName: json["patient_user_name"],
        patientFullName: json["patient_full_name"],
        patientEmail: json["patient_email"],
        patientMobileNumber: json["patient_mobile_number"],
        patientFirebaseId: json["patient_firebase_id"],
        patientImage: json["patient_image"],
        insuranceCompanyId: json["insurance_company_id"],
        insuranceNo: json["insurance_no"],
        allergiesToMedicine: json["allergies_to_medicine"],
        insuranceCardPic: json["insurance_card_pic"],
        payment: json["payment"] == null ? [] : List<Payment>.from(json["payment"]!.map((x) => Payment.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "appointment_no": appointmentNo,
        "doctor_id": doctorId,
        "patient_id": patientId,
        "family_member_type": familyMemberType,
        "relation_patient_name": relationPatientName,
        "date": "${date!.year.toString().padLeft(4, '0')}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}",
        "start_time": startTime,
        "end_time": endTime,
        "appointment_slots_id": appointmentSlotsId,
        "appointment_schedule_id": appointmentScheduleId,
        "diseases_id": diseasesId,
        "symptoms": symptoms,
        "medicines_taken": medicinesTaken,
        "notes": notes,
        "attachment": attachment,
        "room_id": roomId,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "appointment_type": appointmentType,
        "appointment_status": appointmentStatus,
        "diseases_name": diseasesName,
        "specialit_name": specialitName,
        "specialit_image": specialitImage,
        "slots_start_time": slotsStartTime,
        "slots_end_time": slotsEndTime,
        "doctor_user_name": doctorUserName,
        "doctor_full_name": doctorFullName,
        "doctor_email": doctorEmail,
        "doctor_mobile_number": doctorMobileNumber,
        "doctor_firebase_id": doctorFirebaseId,
        "doctor_image": doctorImage,
        "doctor_avg_rating": doctorAvgRating,
        "patient_user_name": patientUserName,
        "patient_full_name": patientFullName,
        "patient_email": patientEmail,
        "patient_mobile_number": patientMobileNumber,
        "patient_firebase_id": patientFirebaseId,
        "patient_image": patientImage,
        "insurance_company_id": insuranceCompanyId,
        "insurance_no": insuranceNo,
        "allergies_to_medicine": allergiesToMedicine,
        "insurance_card_pic": insuranceCardPic,
        "payment": payment == null ? [] : List<dynamic>.from(payment!.map((x) => x.toJson())),
    };
}

class Payment {
    int? id;
    int? appointmentId;
    int? appointmentType;
    int? patientId;
    int? doctorId;
    int? promoCodesId;
    int? totalPrice;
    int? discountAmount;
    int? payableAmount;
    String? transactionId;
    String? description;
    String? receiptUrl;
    int? adminCommissionType;
    int? adminCommissionValue;
    int? adminEarning;
    int? doctorEarning;
    int? status;
    String? createdAt;
    String? updatedAt;

    Payment({
        this.id,
        this.appointmentId,
        this.appointmentType,
        this.patientId,
        this.doctorId,
        this.promoCodesId,
        this.totalPrice,
        this.discountAmount,
        this.payableAmount,
        this.transactionId,
        this.description,
        this.receiptUrl,
        this.adminCommissionType,
        this.adminCommissionValue,
        this.adminEarning,
        this.doctorEarning,
        this.status,
        this.createdAt,
        this.updatedAt,
    });

    factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json["id"],
        appointmentId: json["appointment_id"],
        appointmentType: json["appointment_type"],
        patientId: json["patient_id"],
        doctorId: json["doctor_id"],
        promoCodesId: json["promo_codes_id"],
        totalPrice: json["total_price"],
        discountAmount: json["discount_amount"],
        payableAmount: json["payable_amount"],
        transactionId: json["transaction_id"],
        description: json["description"],
        receiptUrl: json["receipt_url"],
        adminCommissionType: json["admin_commission_type"],
        adminCommissionValue: json["admin_commission_value"],
        adminEarning: json["admin_earning"],
        doctorEarning: json["doctor_earning"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "appointment_id": appointmentId,
        "appointment_type": appointmentType,
        "patient_id": patientId,
        "doctor_id": doctorId,
        "promo_codes_id": promoCodesId,
        "total_price": totalPrice,
        "discount_amount": discountAmount,
        "payable_amount": payableAmount,
        "transaction_id": transactionId,
        "description": description,
        "receipt_url": receiptUrl,
        "admin_commission_type": adminCommissionType,
        "admin_commission_value": adminCommissionValue,
        "admin_earning": adminEarning,
        "doctor_earning": doctorEarning,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
    };
}
