import 'package:kivicare_flutter/model/tax_model.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';

class AppointmentDetailsModel {
  int? id;
  int? patientId;
  String? patientName;
  String? patientEmail;
  String? patientProfileImg;
  int? clinicId;
  String? clinicName;
  String? clinicEmail;
  String? clinicProfileImg;
  int? doctorId;
  String? doctorName;
  String? doctorEmail;
  String? doctorProfileImg;
  List<VisitType>? visitType;
  List<AppointmentReport>? appointmentReport;
  String? appointmentEndDate;
  String? appointmentEndTime;
  String? appointmentStartDate;
  String? appointmentStartTime;
  String? appointmentType;
  int? paymentStatus;
  String? description;
  int? status;
  TaxModel? taxData;
  num? allServiceCharges;
  num? discount;
  num? totalAmount;
  String? appointmentGlobalStartDate;
  String? googleMeetData;
  ZoomData? zoomData;
  num? encounterStatus;
  String? encounterId;

  AppointmentDetailsModel({
    this.id,
    this.patientId,
    this.patientName,
    this.patientEmail,
    this.patientProfileImg,
    this.clinicId,
    this.clinicName,
    this.clinicEmail,
    this.clinicProfileImg,
    this.doctorId,
    this.doctorName,
    this.doctorEmail,
    this.doctorProfileImg,
    this.visitType,
    this.appointmentReport,
    this.appointmentEndDate,
    this.appointmentEndTime,
    this.appointmentStartDate,
    this.appointmentStartTime,
    this.appointmentType,
    this.paymentStatus,
    this.description,
    this.status,
    this.taxData,
    this.allServiceCharges,
    this.discount,
    this.totalAmount,
    this.appointmentGlobalStartDate,
    this.googleMeetData,
    this.zoomData,
    this.encounterStatus,
    this.encounterId,
  });

  factory AppointmentDetailsModel.fromJson(Map<String, dynamic> json) {
    return AppointmentDetailsModel(
        id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
        patientId: json['patient_id'] != null ? int.tryParse(json['patient_id'].toString()) : null,
        patientName: json['patient_name'],
        patientEmail: json['patient_email'],
        patientProfileImg: json['patient_profile_img'],
        clinicId: json['clinic_id'] != null ? int.tryParse(json['clinic_id'].toString()) : null,
        clinicName: json['clinic_name'],
        clinicEmail: json['clinic_email'],
        clinicProfileImg: json['clinic_profile_image'],
        doctorId: json['doctor_id'] != null ? int.tryParse(json['doctor_id'].toString()) : null,
        doctorName: json['doctor_name'],
        doctorEmail: json['doctor_email'],
        doctorProfileImg: json['doctor_profile_img'],
        visitType: json['visit_type'] != null ? (json['visit_type'] as List).map((e) => VisitType.fromJson(e)).toList() : null,
        googleMeetData: json['google_meet_data'],
        appointmentReport: json['appointment_report'] != null ? (json['appointment_report'] as List).map((e) => AppointmentReport.fromJson(e)).toList() : null,
        appointmentEndDate: json['appointment_end_date'],
        appointmentEndTime: json['appointment_end_time'],
        appointmentStartDate: json['appointment_start_date'],
        appointmentStartTime: json['appointment_start_time'],
        appointmentGlobalStartDate: json['start_date'],
        appointmentType: json['appointment_type'],
        paymentStatus: json['payment_status'], // string ("paid/unpaid")
        description: json['description'],
        status: json['status'] != null ? int.tryParse(json['status'].toString()) : null,
        taxData: json['tax_data'] != null ? TaxModel.fromJson(json['tax_data']) : null,
        allServiceCharges: json['all_service_charges'],
        discount: json['discount'] ?? 0,
        totalAmount: json['actual_amount'],
        zoomData: json['zoom_data'] != null ? new ZoomData.fromJson(json['zoom_data']) : null,
        encounterStatus: json['encounter_status'],
        encounterId: json['encounter_id']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['id'] = id;
    json['patient_id'] = patientId;
    json['patient_name'] = patientName;
    json['patient_email'] = patientEmail;
    json['patient_profile_img'] = patientProfileImg;
    json['clinic_id'] = clinicId;
    json['clinic_name'] = clinicName;
    json['clinic_email'] = clinicEmail;
    json['clinic_profile_image'] = clinicProfileImg;
    json['doctor_id'] = doctorId;
    json['doctor_name'] = doctorName;
    json['doctor_email'] = doctorEmail;
    json['doctor_profile_img'] = doctorProfileImg;
    if (visitType != null) {
      json['visit_type'] = visitType!.map((e) => e.toJson()).toList();
    }
    if (appointmentReport != null) {
      json['appointment_report'] = appointmentReport!.map((e) => e.toJson()).toList();
    }
    if (this.zoomData != null) {
      json['zoom_data'] = this.zoomData!.toJson();
    }
    json['google_meet_data'] = googleMeetData;
    json['appointment_end_date'] = appointmentEndDate;
    json['appointment_end_time'] = appointmentEndTime;
    json['appointment_start_date'] = appointmentStartDate;
    json['appointment_start_time'] = appointmentStartTime;
    json['start_date'] = appointmentGlobalStartDate;
    json['appointment_type'] = appointmentType;
    json['payment_status'] = paymentStatus;
    json['description'] = description;
    json['status'] = status;
    if (taxData != null) {
      json['tax_data'] = taxData!.toJson();
    }
    json['all_service_charges'] = allServiceCharges;
    json['discount'] = discount;
    json['actual_amount'] = totalAmount;
    json['encounter_status'] = this.encounterStatus;
    json['encounter_id'] = this.encounterId;

    return json;
  }
}

class AppointmentReport {
  int? id;
  String? url;

  AppointmentReport({this.id, this.url});

  factory AppointmentReport.fromJson(Map<String, dynamic> json) {
    return AppointmentReport(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    json['id'] = id;
    json['url'] = url;
    return json;
  }
}

class ZoomData {
  String? id;
  String? appointmentId;
  String? zoomId;
  String? zoomUuid;
  String? startUrl;
  String? joinUrl;
  String? password;
  String? createdAt;

  ZoomData({this.id, this.appointmentId, this.zoomId, this.zoomUuid, this.startUrl, this.joinUrl, this.password, this.createdAt});

  ZoomData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    appointmentId = json['appointment_id'];
    zoomId = json['zoom_id'];
    zoomUuid = json['zoom_uuid'];
    startUrl = json['start_url'];
    joinUrl = json['join_url'];
    password = json['password'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['appointment_id'] = this.appointmentId;
    data['zoom_id'] = this.zoomId;
    data['zoom_uuid'] = this.zoomUuid;
    data['start_url'] = this.startUrl;
    data['join_url'] = this.joinUrl;
    data['password'] = this.password;
    data['created_at'] = this.createdAt;
    return data;
  }
}
