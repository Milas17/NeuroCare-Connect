import 'dart:io';

import 'package:kivicare_flutter/model/clinic_list_model.dart';
import 'package:kivicare_flutter/model/encounter_module.dart';
import 'package:kivicare_flutter/model/module_config_model.dart';
import 'package:kivicare_flutter/model/prescription_module.dart';
import 'package:kivicare_flutter/model/qualification_model.dart';
import 'package:kivicare_flutter/model/rating_model.dart';
import 'package:kivicare_flutter/model/speciality_model.dart';
import 'package:kivicare_flutter/model/user_permission.dart';
import 'package:nb_utils/nb_utils.dart';

class UserModel {
  // String properties
  String? consumerKey;
  String? consumerSecretKey;

  String? apiNonce;
  String? doctorId;
  String? firstName;
  String? lastName;

  String? userName;

  String? userDisplayName;
  String? userEmail;
  String? userNiceName;
  String? mobileNumber;

  String? address;
  String? city;
  String? country;
  String? dob;

  String? gender;

  String? noOfExperience;

  String? postalCode;

  String? profileImage;
  String? role;

  String? zoomId;
  String? signatureImg;
  String? state;

  String? userLogin;
  String? bloodGroup;

  String? available;
  String? clinicId;
  String? clinicName;
  String? displayName;
  String? userStatus;
  String? charges;
  String? duration;
  String? serviceImage;
  String? mappingTableId;
  String? status;

  String? serviceId;

  String? totalEncounter;

  // Int properties
  int? userId;
  int? iD;

  // Bool properties
  bool isCheck;
  bool? multiple;
  bool? isTelemed;

  // List properties
  List<Clinic>? clinic;
  List<EncounterModule>? encounterModules;
  List<ModuleConfig>? moduleConfig;

  List<PrescriptionModule>? prescriptionModule;
  List<Qualification>? qualifications;
  List<SpecialtyModel>? specialties;
  List<RatingData>? ratingList;
  UserPermission? permissions;

  // File property
  File? imageFile;

  // Object properties

  UserModel({
    // String properties
    this.address,
    this.apiNonce,
    this.consumerKey,
    this.consumerSecretKey,
    this.firstName,
    this.userName,
    this.city,
    this.country,
    this.dob,
    this.imageFile,
    this.gender,
    this.lastName,
    this.mobileNumber,
    this.noOfExperience,
    this.postalCode,
    this.prescriptionModule,
    this.profileImage,
    this.qualifications,
    this.role,
    this.specialties,
    this.userDisplayName,
    this.userEmail,
    this.userId,
    this.userNiceName,
    this.zoomId,
    this.signatureImg,
    this.userLogin,
    this.bloodGroup,
    this.state,
    this.available,
    this.clinicId,
    this.clinicName,
    this.displayName,
    this.ratingList,
    this.iD,
    this.serviceId,
    this.userStatus,
    this.doctorId,
    this.isCheck = false,
    this.charges,
    this.duration,
    this.serviceImage,
    this.mappingTableId,
    this.multiple,
    this.status,
    this.isTelemed,
    this.clinic,
    this.encounterModules,
    this.moduleConfig,
    this.totalEncounter,
    this.permissions,
  });

  String get getDoctorSpeciality => specialties.validate().map((e) => e.label.validate()).join(', ');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      apiNonce: json['nounce'],
      consumerKey: json['consumer_key'],
      consumerSecretKey: json['consumer_secret'],
      role: json['role'],
      firstName: json['first_name'] != null ? json['first_name'] : json['display_name'].toString().split(' ').first,
      lastName: json['last_name'] != null ? json['last_name'] : json['display_name'].toString().split(' ').last,
      userName: json['user_name'],
      userDisplayName: json['display_name'],
      userEmail: json['email'] != null
          ? json['email']
          : json['user_email'] != null
              ? json['user_email']
              : null,
      userId: json['user_id'].runtimeType == String ? (json['user_id'] as String).toInt() : json['user_id'],
      iD: json['ID'],
      doctorId: json['doctor_id'],
      displayName: json['display_name'],
      userNiceName: json['user_nicename'],
      userStatus: json['user_status'],
      gender: json['gender'],
      mobileNumber: json['mobile_number'] is String ? json['mobile_number'] : '',
      dob: json['dob'],
      city: json['city'],
      country: json['country'],
      address: json['address'],
      clinic: json['clinic'] != null ? (json['clinic'] as List).map((i) => Clinic.fromJson(i)).toList() : null,
      encounterModules: json['enocunter_modules'] != null ? (json['enocunter_modules'] as List).map((i) => EncounterModule.fromJson(i)).toList() : null,
      moduleConfig: json['module_config'] != null ? (json['module_config'] as List).map((i) => ModuleConfig.fromJson(i)).toList() : null,
      noOfExperience: json['no_of_experience'],
      postalCode: json['postal_code'],
      prescriptionModule: json['prescription_module'] != null ? (json['prescription_module'] as List).map((i) => PrescriptionModule.fromJson(i)).toList() : null,
      profileImage: json['profile_image'],
      qualifications: json['qualifications'] != null ? (json['qualifications'] as List).map((i) => Qualification.fromJson(i)).toList() : null,
      specialties: json['specialties'] != null
          ? (json['specialities'].runtimeType == String ? (json['specialties']).split(',').map((e) => SpecialtyModel(label: e)).toList() : (json['specialties'] as List).map((e) => SpecialtyModel.fromJson(e)).toList())
          : json['specialties'],
      zoomId: json['zoom_id'],
      signatureImg: json['signature_img'],
      state: json['state'],
      userLogin: json['user_login'],
      bloodGroup: json['blood_group'],
      available: json['available'],
      clinicName: json['clinic_name'],
      ratingList: json['review'] != null
          ? (json['review'] as List).map((i) => RatingData.fromJson(i)).toList()
          : json['reviews'] != null
              ? (json['reviews'] as List).map((i) => RatingData.fromJson(i)).toList()
              : null,
      permissions: json['permissions'] != null ? UserPermission.fromJson(json['permissions']) : null,
      charges: json['charges'],
      serviceId: json['service_id'],
      duration: json['duration'],
      serviceImage: json['image'],
      isTelemed: json['is_telemed'],
      mappingTableId: json['mapping_table_id'],
      multiple: json['is_multiple_selection'],
      status: json['status'].runtimeType == int ? (json['status'] as int).toString() : json['status'],
      totalEncounter: json['total_encounter'],
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};

    json['consumer_key'] = consumerKey;
    json['consumer_secret'] = consumerSecretKey;
    json['nounce'] = apiNonce;
    json['doctor_id'] = doctorId;
    json['first_name'] = firstName;
    json['last_name'] = lastName;
    json['mobile_number'] = mobileNumber;
    json['address'] = address;
    json['city'] = city;
    json['country'] = country;
    json['dob'] = dob;
    json['gender'] = gender;
    json['no_of_experience'] = noOfExperience;
    json['postal_code'] = postalCode;
    json['profile_image'] = profileImage;
    json['role'] = role;
    json['zoom_id'] = zoomId;
    json['signature_img'] = signatureImg;
    json['state'] = state;
    json['user_login'] = userLogin;
    json['blood_group'] = bloodGroup;
    json['available'] = available;
    json['clinic_id'] = clinicId;
    json['clinic_name'] = clinicName;
    json['display_name'] = displayName;
    json['review'] = ratingList?.map((x) => x.toJson()).toList();
    json['ID'] = iD;
    json['service_id'] = serviceId;
    json['user_status'] = userStatus;
    json['isCheck'] = isCheck;
    json['charges'] = charges;
    json['duration'] = duration;
    json['image'] = serviceImage;
    json['mapping_table_id'] = mappingTableId;
    json['is_multiple_selection'] = multiple;
    json['status'] = status;
    json['is_telemed'] = isTelemed;
    json['clinic'] = clinic?.map((x) => x.toJson()).toList();
    json['enocunter_modules'] = encounterModules?.map((x) => x.toJson()).toList();
    json['module_config'] = moduleConfig?.map((x) => x.toJson()).toList();
    json['total_encounter'] = totalEncounter;
    return json;
  }
}
