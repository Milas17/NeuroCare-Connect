import 'dart:convert';

import 'package:kivicare_flutter/model/user_model.dart';

class ClinicDetailsModel {
  int? id;
  String? name;
  String? email;
  String? telephoneNo;
  List<Specialty>? specialties;
  String? address;
  String? city;
  String? country;
  String? postalCode;
  bool status = false;
  String? clinicAdminId;
  String? clinicLogo;
  String? profileImage;
  String? countryCode;
  String? countryCallingCode;
  String? clinicOwner;
  List<UserModel>? doctors;

  ClinicDetailsModel({
    this.id,
    this.name,
    this.email,
    this.telephoneNo,
    this.specialties,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.status = false,
    this.clinicAdminId,
    this.clinicLogo,
    this.profileImage,
    this.countryCode,
    this.countryCallingCode,
    this.clinicOwner,
    this.doctors,
  });

  factory ClinicDetailsModel.fromJson(Map<String, dynamic> json) {
    return ClinicDetailsModel(
      id: int.tryParse(json['id'].toString()),
      name: json['name'],
      email: json['email'],
      telephoneNo: json['telephone_no'],
      specialties: json['specialties'] != null ? (jsonDecode(json['specialties']) as List).map((e) => Specialty.fromJson(e)).toList() : [],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      postalCode: json['postal_code'],
      status: json['status'] != null && json['status'].toString() == "1",
      clinicAdminId: json['clinic_admin_id']?.toString(),
      clinicLogo: json['clinic_logo'],
      profileImage: json['profile_image'],
      countryCode: json['country_code'],
      countryCallingCode: json['country_calling_code'],
      clinicOwner: json['owner'], // fixed
      doctors: json['doctors'] != null ? (json['doctors'] as List).map((e) => UserModel.fromJson(e)).toList() : [],
    );
  }
}

class Specialty {
  int? id;
  String? label;

  Specialty({this.id, this.label});

  factory Specialty.fromJson(Map<String, dynamic> json) {
    return Specialty(
      id: int.tryParse(json['id'].toString()),
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
      };
}

class DoctorModel {
  String? doctorId;
  String? displayName;
  String? userEmail;
  String? mobileNumber;
  String? noOfExperience;
  String? imageFile;
  List<Specialty>? specialties;
  DoctorModel({
    this.doctorId,
    this.displayName,
    this.userEmail,
    this.mobileNumber,
    this.noOfExperience,
    this.imageFile,
    this.specialties,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      doctorId: json['doctorId']?.toString(),
      displayName: json['displayName'],
      userEmail: json['userEmail'],
      mobileNumber: json['mobileNumber'],
      noOfExperience: json['noOfExperience'],
      imageFile: json['imageFile'],
      specialties: json['specialties'] != null ? (jsonDecode(json['specialties']) as List).map((e) => Specialty.fromJson(e)).toList() : [],
    );
  }
}
