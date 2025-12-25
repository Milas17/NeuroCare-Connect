// To parse this JSON data, do
//
//     final doctorProfileModel = doctorProfileModelFromJson(jsonString);

import 'dart:convert';

DoctorProfileModel doctorProfileModelFromJson(String str) =>
    DoctorProfileModel.fromJson(json.decode(str));

String doctorProfileModelToJson(DoctorProfileModel data) =>
    json.encode(data.toJson());

class DoctorProfileModel {
  int? status;
  String? message;
  List<Result>? result;

  DoctorProfileModel({
    this.status,
    this.message,
    this.result,
  });

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) =>
      DoctorProfileModel(
        status: json["status"],
        message: json["message"],
        result:
            List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "result": List<dynamic>.from(result?.map((x) => x.toJson()) ?? {}),
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
  String? countryCode;
  String? mobileNumber;
  String? countryName;
  String? bio;
  String? practicingTenure;
  String? dateOfBirth;
  int? fees;
  String? workingTime;
  String? image;
  String? address;
  String? latitude;
  String? longitude;
  String? area;
  String? city;
  String? state;
  String? country;
  String? instagramUrl;
  String? facebookUrl;
  String? twitterUrl;
  String? referenceCode;
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
  String? specialtiesName;
  int? avgRating;
  int? totalReview;
  int? patientCount;
  int? isKyc;
  int? isFavorite;
  String? degreeDocument;
  String? caseStudies;
  List<KycDetail>? kycDetails;

  Result(
      {this.id,
      this.firebaseId,
      this.specialtiesId,
      this.userName,
      this.fullName,
      this.email,
      this.password,
      this.countryCode,
      this.mobileNumber,
      this.countryName,
      this.bio,
      this.practicingTenure,
      this.dateOfBirth,
      this.fees,
      this.workingTime,
      this.image,
      this.address,
      this.latitude,
      this.longitude,
      this.area,
      this.city,
      this.state,
      this.country,
      this.instagramUrl,
      this.facebookUrl,
      this.twitterUrl,
      this.referenceCode,
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
      this.specialtiesName,
      this.avgRating,
      this.totalReview,
      this.isKyc,
      this.patientCount,
      this.isFavorite,
      this.kycDetails,
      this.caseStudies,
      this.degreeDocument});

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        firebaseId: json["firebase_id"],
        specialtiesId: json["specialties_id"],
        userName: json["user_name"],
        fullName: json["full_name"],
        email: json["email"],
        password: json["password"],
        countryCode: json["country_code"],
        mobileNumber: json["mobile_number"],
        countryName: json["country_name"],
        bio: json["bio"],
        practicingTenure: json["practicing_tenure"],
        dateOfBirth: json["date_of_birth"],
        fees: json["fees"],
        workingTime: json["working_time"],
        image: json["image"],
        address: json["address"],
        latitude: json["latitude"],
        longitude: json["longitude"],
        area: json["area"],
        city: json["city"],
        state: json["state"],
        country: json["country"],
        instagramUrl: json["instagram_url"],
        facebookUrl: json["facebook_url"],
        twitterUrl: json["twitter_url"],
        referenceCode: json["reference_code"],
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
        // specialtiesName: json["specialties_name"],
        specialtiesName: json["speciality_name"],
        avgRating: json["avg_rating"],
        isKyc: json["is_kyc"],
        totalReview: json["total_review"],
        patientCount: json["patient_count"],
        isFavorite: json["is_favorite"],
        caseStudies: json["case_studies"],
        degreeDocument: json["certificate"],
        kycDetails: json["kyc_details"] == null
            ? []
            : List<KycDetail>.from(
                json["kyc_details"].map((x) => KycDetail.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firebase_id": firebaseId,
        "specialties_id": specialtiesId,
        "user_name": userName,
        "full_name": fullName,
        "email": email,
        "password": password,
        "country_code": countryCode,
        "mobile_number": mobileNumber,
        "country_name": countryName,
        "bio": bio,
        "practicing_tenure": practicingTenure,
        "date_of_birth": dateOfBirth,
        "fees": fees,
        "working_time": workingTime,
        "image": image,
        "address": address,
        "latitude": latitude,
        "longitude": longitude,
        "area": area,
        "city": city,
        "state": state,
        "country": country,
        "instagram_url": instagramUrl,
        "facebook_url": facebookUrl,
        "twitter_url": twitterUrl,
        "reference_code": referenceCode,
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
        // "specialties_name": specialtiesName,
        "speciality_name": specialtiesName,
        "avg_rating": avgRating,
        "is_kyc": isKyc,
        "total_review": totalReview,
        "patient_count": patientCount,
        "is_favorite": isFavorite,
        "case_studies": caseStudies,
        "certificate": degreeDocument,
        "kyc_details":
            List<dynamic>.from(kycDetails?.map((x) => x.toJson()) ?? []),
      };
}

class KycDetail {
  String? licPersonName;
  String? licNumber;
  String? licAddress;
  int? postalCode;
  String? dateOfBirth;
  String? instituteName;
  String? instituteAddress;
  String? degree;
  String? batchYear;
  String? clinicName;
  String? role;
  String? clinicAddress;
  String? licFrontImg;
  String? licBackImg;
  String? degreeDocument;

  KycDetail({
    this.licPersonName,
    this.licNumber,
    this.licAddress,
    this.postalCode,
    this.dateOfBirth,
    this.instituteName,
    this.instituteAddress,
    this.degree,
    this.batchYear,
    this.clinicName,
    this.role,
    this.clinicAddress,
    this.licFrontImg,
    this.licBackImg,
    this.degreeDocument,
  });

  factory KycDetail.fromJson(Map<String, dynamic> json) => KycDetail(
        licPersonName: json["lic_person_name"],
        licNumber: json["lic_number"],
        licAddress: json["lic_address"],
        postalCode: json["postal_code"],
        dateOfBirth: json["date_of_birth"],
        instituteName: json["institute_name"],
        instituteAddress: json["institute_address"],
        degree: json["degree"],
        batchYear: json["batch_year"],
        clinicName: json["clinic_name"],
        role: json["role"],
        clinicAddress: json["clinic_address"],
        licFrontImg: json["lic_front_img"],
        licBackImg: json["lic_back_img"],
        degreeDocument: json["degree_document"],
      );

  Map<String, dynamic> toJson() => {
        "lic_person_name": licPersonName,
        "lic_number": licNumber,
        "lic_address": licAddress,
        "postal_code": postalCode,
        "date_of_birth": dateOfBirth,
        "institute_name": instituteName,
        "institute_address": instituteAddress,
        "degree": degree,
        "batch_year": batchYear,
        "clinic_name": clinicName,
        "role": role,
        "clinic_address": clinicAddress,
        "lic_front_img": licFrontImg,
        "lic_back_img": licBackImg,
        "degree_document": degreeDocument,
      };
}
