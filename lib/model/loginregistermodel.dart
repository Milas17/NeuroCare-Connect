// To parse this JSON data, do
// final loginRegisterModel = loginRegisterModelFromJson(jsonString);

import 'dart:convert';

LoginRegisterModel loginRegisterModelFromJson(String str) =>
    LoginRegisterModel.fromJson(json.decode(str));

String loginRegisterModelToJson(LoginRegisterModel data) =>
    json.encode(data.toJson());

class LoginRegisterModel {
  int? status;
  String? message;
  List<Result>? result;

  LoginRegisterModel({
    this.status,
    this.message,
    this.result,
  });

  factory LoginRegisterModel.fromJson(Map<String, dynamic> json) =>
      LoginRegisterModel(
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
  String? firebaseId;
  int? specialtiesId;
  String? userName;
  String? fullName;
  String? email;
  String? password;
  String? mobileNumber;
  String? aboutUs;
  String? profileImg;
  String? address;
  String? latitude;
  String? longitude;
  String? instagramUrl;
  String? facebookUrl;
  String? twitterUrl;
  String? services;
  String? workingTime;
  String? healthCare;
  String? referenceCode;
  int? totalPoints;
  int? fees;
  String? bankName;
  String? bankCode;
  String? bankAddress;
  String? accountNo;
  String? ifscNo;
  String? idProofImg;
  int? walletAmount;
  int? deviceType;
  String? deviceToken;
  int? type;
  int? status;
  String? createdAt;
  String? updatedAt;

  Result({
    this.id,
    this.firebaseId,
    this.specialtiesId,
    this.userName,
    this.fullName,
    this.email,
    this.password,
    this.mobileNumber,
    this.aboutUs,
    this.profileImg,
    this.address,
    this.latitude,
    this.longitude,
    this.instagramUrl,
    this.facebookUrl,
    this.twitterUrl,
    this.services,
    this.workingTime,
    this.healthCare,
    this.referenceCode,
    this.totalPoints,
    this.fees,
    this.bankName,
    this.bankCode,
    this.bankAddress,
    this.accountNo,
    this.ifscNo,
    this.idProofImg,
    this.walletAmount,
    this.deviceType,
    this.deviceToken,
    this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        firebaseId: json["firebase_id"],
        specialtiesId: json["specialties_id"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        password: json["password"],
        mobileNumber: json["mobile_number"],
        aboutUs: json["about_us"],
        profileImg: json["profile_img"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        instagramUrl: json["instagram_url"],
        facebookUrl: json["facebook_url"],
        twitterUrl: json["twitter_url"],
        services: json["services"],
        workingTime: json["working_time"],
        healthCare: json["health_care"],
        referenceCode: json["reference_code"],
        totalPoints: json["total_points"],
        fees: json["fees"],
        bankName: json["bank_name"],
        bankCode: json["bank_code"],
        bankAddress: json["bank_address"],
        accountNo: json["account_no"],
        ifscNo: json["ifsc_no"],
        idProofImg: json["id_proof_img"],
        walletAmount: json["wallet_amount"],
        deviceType: json["device_type"],
        deviceToken: json["device_token"],
        type: json["type"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: json["updated_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firebase_id": firebaseId,
        "specialties_id": specialtiesId,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "password": password,
        "mobile_number": mobileNumber,
        "about_us": aboutUs,
        "profile_img": profileImg,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "instagram_url": instagramUrl,
        "facebook_url": facebookUrl,
        "twitter_url": twitterUrl,
        "services": services,
        "working_time": workingTime,
        "health_care": healthCare,
        "reference_code": referenceCode,
        "total_points": totalPoints,
        "fees": fees,
        "bank_name": bankName,
        "bank_code": bankCode,
        "bank_address": bankAddress,
        "account_no": accountNo,
        "ifsc_no": ifscNo,
        "id_proof_img": idProofImg,
        "wallet_amount": walletAmount,
        "device_type": deviceType,
        "device_token": deviceToken,
        "type": type,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
