import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:yourappname/model/addprescriptionmodel.dart';
import 'package:yourappname/model/appointmentdetailsmodel.dart';
import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/appointmentstatusmodel.dart';
import 'package:yourappname/model/blogmodel.dart';
import 'package:yourappname/model/chatusermodel.dart';
import 'package:yourappname/model/doctorprofilemodel.dart';
import 'package:yourappname/model/downloadprescriptionmodel.dart';
import 'package:yourappname/model/generalsettingmodel.dart';
import 'package:yourappname/model/getmedicinelistmodel.dart';
import 'package:yourappname/model/getreviewlistmodel.dart';
import 'package:yourappname/model/loginregistermodel.dart';
import 'package:yourappname/model/notificationmodel.dart';
import 'package:yourappname/model/onboardingmodel.dart';
import 'package:yourappname/model/pagesmodel.dart';
import 'package:yourappname/model/patientlistgraphmodel.dart';
import 'package:yourappname/model/prescriptionmodel.dart';
import 'package:yourappname/model/searchmedicinemodel.dart';
import 'package:yourappname/model/sociallinkmodel.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/timeslotmodel.dart';
import 'package:yourappname/model/workingtimeslotmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:path/path.dart';
import 'package:yourappname/utils/utils.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:http/http.dart' as http;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../model/attachmentuploadmodel.dart';
import '../utils/app_string.dart';

class ApiService {
  String baseUrl = Constant.baseurl;

  late Dio dio;

  ApiService() {
    dio = Dio();
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        compact: true,
      ),
    );
  }

  // genaral_setting API
  Future<GeneralSettingModel> genaralSetting() async {
    GeneralSettingModel generalSettingModel;
    String generalsetting = "general_setting";
    Response response = await dio.post('$baseUrl$generalsetting');
    generalSettingModel = GeneralSettingModel.fromJson(response.data);
    return generalSettingModel;
  }

  // get_pages API
  Future<PagesModel> getPages() async {
    PagesModel responseModel;
    String apiName = "get_pages";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    responseModel = PagesModel.fromJson(response.data);
    return responseModel;
  }

  // get_social_link
  Future<SocialLinkModel> getSocialLinks() async {
    SocialLinkModel responseModel;
    String apiName = "get_social_link";
    Response response = await dio.post(
      '$baseUrl$apiName',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    responseModel = SocialLinkModel.fromJson(response.data);
    return responseModel;
  }

  // doctor_registration API
  Future<LoginRegisterModel> doctorRegistration(
      fullName,
      email,
      password,
      mobile,
      fees,
      firebaseid,
      deviceToken,
      deviceType,
      address,
      specialtiesID,
      practicingTenure,
      dateOfBirth,
      latitude,
      longitude,
      area,
      city,
      state,
      country,
      countryCode,
      countryName,
      docProfileImg) async {
    MultipartFile imageFile = await MultipartFile.fromFile(
      docProfileImg.path,
      filename: basename(docProfileImg.path),
    );
    FormData formData = FormData.fromMap({
      'login_type': "1",
      'full_name': fullName,
      'email': email,
      'password': password,
      'mobile_number': mobile,
      // 'fees': fees,
      'consultation_fees': fees,
      'address': address,
      'specialties_id': specialtiesID,
      'practicing_tenure': practicingTenure,
      "date_of_birth": dateOfBirth,
      "firebase_id": firebaseid,
      'device_token': deviceToken,
      'device_type': deviceType,
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'city': city,
      'state': state,
      'country': country,
      'country_code': countryCode,
      'country_name': countryName,
      "speciality_id": specialtiesID,
      "image": (docProfileImg.path.isNotEmpty ? (imageFile) : ""),
    });
    LoginRegisterModel registerModel;
    String registration = "registration";
    Response response = await dio.post(
      '$baseUrl$registration',
      data: formData,
      // data: {
      //   'login_type': "1",
      //   'full_name': fullName,
      //   'email': email,
      //   'password': password,
      //   'mobile_number': mobile,
      //   // 'fees': fees,
      //   'consultation_fees': fees,
      //   'address': address,
      //   'specialties_id': specialtiesID,
      //   'practicing_tenure': practicingTenure,
      //   "date_of_birth": dateOfBirth,
      //   "firebase_id": firebaseid,
      //   'device_token': deviceToken,
      //   'device_type': deviceType,
      //   'latitude': latitude,
      //   'longitude': longitude,
      //   'area': area,
      //   'city': city,
      //   'state': state,
      //   'country': country,
      //   'country_code': countryCode,
      //   'country_name': countryName,
      //   "speciality_id": specialtiesID,
      //   "image": (docProfileImg.path.isNotEmpty ? (imageFile) : ""),
      // },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    printLog("Resgiter Model data :- ${response.data}");
    registerModel = LoginRegisterModel.fromJson(response.data);

    return registerModel;
  }

  // doctor_registration API
  Future<SuccessModel> doctorKYC(
      licPersonName,
      licNumber,
      licAddress,
      postalCode,
      role,
      degree,
      batchYear,
      clinicName,
      licFrontImage,
      licBackImage,
      instituteName,
      instituteAddress,
      clinicAddress,
      dateOfBirth,
      bankName,
      bankcode,
      bankAddress,
      ifscno,
      accountNo,
      idProofimg,
      docProfileImg,
      doctorId) async {
    printLog("lic_front_img == $licFrontImage");
    printLog("lic_back_img == $licBackImage");
    printLog("degree_document == $docProfileImg");
    SuccessModel kycVerificationModel;
    String registration = "kyc_verification";

    // Create a FormData object
    FormData formData = FormData.fromMap({
      'doctor_id': doctorId,
      'lic_person_name': licPersonName,
      'lic_number': licNumber,
      'lic_address': licAddress,
      'postal_code': postalCode,
      'date_of_birth': dateOfBirth,
      "institute_name": instituteName,
      "institute_address": instituteAddress,
      'degree': degree,
      "clinic_name": clinicName,
      "role": role,
      'clinic_address': clinicAddress,
      'batch_year': batchYear,
      'bank_name': bankName,
      'bank_code': bankcode,
      'clinic_latitude': "",
      'clinic_longitude': "",
      'bank_address': bankAddress,
      'ifsc_code': ifscno,
      'account_no': accountNo,
      'id_proof_img': idProofimg != null
          ? await MultipartFile.fromFile(
              idProofimg.path,
              filename: basename(idProofimg.path),
            )
          : null,
      'lic_front_img': licFrontImage != null
          ? await MultipartFile.fromFile(
              licFrontImage.path,
              filename: basename(licFrontImage.path),
            )
          : null,
      'lic_back_img': licBackImage != null
          ? await MultipartFile.fromFile(
              licBackImage.path,
              filename: basename(licBackImage.path),
            )
          : null,
      "degree_document": docProfileImg != null
          ? await MultipartFile.fromFile(
              docProfileImg.path,
              filename: basename(docProfileImg.path),
            )
          : null,
    });

    Response response = await dio.post(
      '$baseUrl$registration',
      data: formData,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    kycVerificationModel = SuccessModel.fromJson(response.data);
    printLog("Kyc Verification Model :- ${kycVerificationModel.toJson()}");
    return kycVerificationModel;
  }

  // doctor_login API
  Future<LoginRegisterModel> doctorLogin(
      email, password, type, firebaseid, deviceToken) async {
    printLog("email :==> $email");
    printLog("password :==> $password");
    printLog("type :==> $type");
    printLog("deviceToken :==> $deviceToken");

    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: {
        'login_type': "1",
        'email': email,
        'password': password,
        'type': type,
        "firebase_id": firebaseid,
        'device_token': deviceToken
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // doctor_login OTP API
  Future<LoginRegisterModel> doctorOTPLogin(mobileNumber, countryCode,
      countryName, type, firebaseid, deviceType, deviceToken) async {
    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: {
        'login_type': "1",
        'mobile_number': mobileNumber,
        'device_type': deviceType,
        'device_token': deviceToken,
        'type': type,
        "firebase_id": firebaseid,
        'country_code': countryCode,
        'country_name': countryName
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // doctor_login Social API
  Future<LoginRegisterModel> doctorLoginSocial(
      email, type, firebaseid, deviceToken) async {
    printLog("email :==> $email");
    printLog("type :==> $type");
    printLog("deviceToken :==> $deviceToken");

    LoginRegisterModel loginModel;
    String doctorLogin = "login";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: {
        'login_type': "1",
        'email': email,
        'type': type,
        "firebase_id": firebaseid,
        'device_token': deviceToken
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    loginModel = LoginRegisterModel.fromJson(response.data);
    return loginModel;
  }

  // forgot_password API
  Future<OnboardingModel> onBoardingScreen() async {
    OnboardingModel onboardingModel;
    String doctorLogin = "get_onboarding_screen";
    var type = {'type': 1};
    Response response = await dio.post(
      data: type,
      '$baseUrl$doctorLogin',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("onboardingModel statuscode :===> ${response.statusCode}");
    printLog("onboardingModel Message :===> ${response.statusMessage}");
    printLog("onboardingModel data :===> ${response.data}");
    onboardingModel = OnboardingModel.fromJson(response.data);
    return onboardingModel;
  }

  // doctor_forgot_password API
  Future<SuccessModel> forgotPassword(email) async {
    SuccessModel successModel;
    String doctorLogin = "forgot_password";
    Response response = await dio.post(
      '$baseUrl$doctorLogin',
      data: {
        'login_type': "1",
        'email': email,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // change_password API
  Future<SuccessModel> changePassword(
      currentPassword, newPassword, confirmPassword) async {
    SuccessModel successModel;
    String doctorChangePassword = "change_password";
    Response response = await dio.post(
      '$baseUrl$doctorChangePassword',
      data: {
        'login_type': "1",
        'current_password': currentPassword,
        'doctor_id': Constant.userID ?? "",
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // doctor_detail API
  Future<DoctorProfileModel> doctorDetails(userId) async {
    printLog("userId :==> $userId");

    DoctorProfileModel doctorProfileModel;
    String doctorProfile = "get_profile";
    printLog("doctorProfile API :==> $baseUrl$doctorProfile");
    Response response = await dio.post(
      '$baseUrl$doctorProfile',
      // data: {'doctor_id': userId, 'login_type': 1},
      data: {'type_id': userId, 'login_type': 1},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    doctorProfileModel = DoctorProfileModel.fromJson(response.data);
    return doctorProfileModel;
  }

// doctor_pending_appoinment API
  Future<AppointmentModel> pendingappointment(doctorId, pageNo) async {
    AppointmentModel appointmentModel;
    String pendingAppoinment = "pending_appointment_by_doctor";
    printLog("upcomingAppoinment API :==> $baseUrl$pendingAppoinment");
    Response response = await dio.post(
      '$baseUrl$pendingAppoinment',
      data: {'doctor_id': doctorId, 'page_no': pageNo},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    appointmentModel = AppointmentModel.fromJson(response.data);
    return appointmentModel;
  }

// patient_history API
  Future<AppointmentModel> patientHistory(doctorId, pageNo) async {
    AppointmentModel patientHistoryModel;
    String patientHistory = "patient_history";
    printLog("upcomingAppoinment API :==> $baseUrl$patientHistory");
    Response response = await dio.post(
      '$baseUrl$patientHistory',
      data: {'doctor_id': doctorId, "page_no": pageNo},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    patientHistoryModel = AppointmentModel.fromJson(response.data);
    return patientHistoryModel;
  }

  // download_prescription API
  Future<DownloadPrescriptionModel> downloadPrescription(
    appointmentId,
  ) async {
    DownloadPrescriptionModel downloadPrescriptionModel;
    String downloadPrescription = "download_prescription";
    printLog("download_prescription API :==> $baseUrl$downloadPrescription");
    Response response = await dio.post(
      '$baseUrl$downloadPrescription',
      data: {
        'appointment_id': appointmentId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    downloadPrescriptionModel =
        DownloadPrescriptionModel.fromJson(response.data);
    return downloadPrescriptionModel;
  }

// get_patient_list API
  Future<PatientListGraphModel> getPatientList() async {
    PatientListGraphModel patientListGraphModel;
    // String getPatientlistData = "get_patient_list";
    String getPatientlistData = "get_patient_visit";
    Response response = await dio.post(
      '$baseUrl$getPatientlistData',
      data: {'doctor_id': Constant.userID},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    patientListGraphModel = PatientListGraphModel.fromJson(response.data);
    return patientListGraphModel;
  }

// get_blog API
  Future<BlogModel> getBlog() async {
    BlogModel blogModel;
    String getBlog = "get_blog";
    Response response = await dio.post(
      '$baseUrl$getBlog',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    blogModel = BlogModel.fromJson(response.data);
    return blogModel;
  }

//search_appointment API
  Future<AppointmentModel> searchAppointment(name, pageNo) async {
    printLog("doctor :==> ${Constant.userID}");

    AppointmentModel searchappointmentModel;
    String searchAppoinment = "search_appointment";
    printLog("upcomingAppoinment API :==> $baseUrl$searchAppoinment");
    Response response = await dio.post(
      '$baseUrl$searchAppoinment',
      data: {
        'type_id': Constant.userID,
        'type': "1",
        'name': name,
        'page_no': pageNo
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("upcomingAppointment statuscode :===> ${response.statusCode}");
    printLog("upcomingAppointment Message :===> ${response.statusMessage}");
    printLog("upcomingAppointment data :===> ${response.data}");
    searchappointmentModel = AppointmentModel.fromJson(response.data);
    return searchappointmentModel;
  }

// today_appointment_by_doctor API
  Future<AppointmentModel> todayappointment(doctorId, pageNo) async {
    AppointmentModel appointmentModel;
    String todayAppoinment = "today_appointment_by_doctor";
    printLog("upcomingAppoinment API :==> $baseUrl$todayAppoinment");
    Response response = await dio.post(
      '$baseUrl$todayAppoinment',
      data: {'doctor_id': doctorId, 'page_no': pageNo},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    appointmentModel = AppointmentModel.fromJson(response.data);
    return appointmentModel;
  }

  // get_all_doctor_appoinment API
  Future<AppointmentModel> appoinmentList(doctorId) async {
    AppointmentModel responseModel;
    String apiName = "get_all_doctor_appoinment";
    Response response = await dio.post(
      '$baseUrl$apiName',
      data: {
        'doctor_id': doctorId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    responseModel = AppointmentModel.fromJson(response.data);
    return responseModel;
  }

  // patient_appoinment API
  Future<AppointmentModel> patientAppoinment(patientId, String pageNo) async {
    printLog("patientId :==> $patientId");

    AppointmentModel listOfAppointmentModel;
    String upcomingAppoinment = "get_appointment_list";
    printLog("upcomingAppoinment API :==> $baseUrl$upcomingAppoinment");
    Response response = await dio.post(
      '$baseUrl$upcomingAppoinment',
      data: {
        "doctor_id": Constant.userID,
        'patient_id': patientId,
        'page_no': pageNo
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    listOfAppointmentModel = AppointmentModel.fromJson(response.data);
    return listOfAppointmentModel;
  }

  // appoinment_calling API
  Future<SuccessModel> appoinmentCalling(appointmentId) async {
    SuccessModel successModel;
    String appoinmentCalling = "appointment_calling";
    printLog("appointment_calling API :==> $baseUrl$appoinmentCalling");
    Response response = await dio.post(
      '$baseUrl$appoinmentCalling',
      data: {
        'appointment_id': appointmentId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // appoinment_status_update API
  Future<SuccessModel> appoinmentStatusUpdate(appointmentId, status) async {
    SuccessModel successModel;
    String appoinmentStatusUpdate = "appoinment_status_update";
    printLog("appoinmentStatusUpdate API :==> $baseUrl$appoinmentStatusUpdate");
    Response response = await dio.post(
      '$baseUrl$appoinmentStatusUpdate',
      data: {
        'appointment_id': appointmentId,
        'status': status,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // update_reschedule_appointment API
  Future<SuccessModel> updateShedule(
      appointmentId, date, startTime, endTime) async {
    SuccessModel successModel;
    String updateSchedule = "update_reschedule_appointment";
    printLog("appoinmentStatusUpdate API :==> $baseUrl$updateSchedule");
    Response response = await dio.post(
      '$baseUrl$updateSchedule',
      data: {
        'doctor_id': Constant.userID,
        'appointment_id': appointmentId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // doctor_upcoming_appoinment API
  Future<AppointmentDetailsModel> appoinmentDetails(appointmentId) async {
    AppointmentDetailsModel appointmentModel;
    String appoinmentDetail = "appointment_details";
    printLog("appoinmentDetail API :==> $baseUrl$appoinmentDetail");
    Response response = await dio.post(
      '$baseUrl$appoinmentDetail',
      data: {
        'appointment_id': appointmentId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    appointmentModel = AppointmentDetailsModel.fromJson(response.data);
    printLog("Appointment Details :- ${appointmentModel.toJson()}");
    return appointmentModel;
  }

  // // get_prescription_detail API
  // Future<PrescriptionDetailModel> prescriptionHistory(patientId) async {
  //   PrescriptionDetailModel prescriptionDetailModel;
  //   String appoinmentDetail = "get_prescription_detail";
  //   printLog("prescriptionDetails API :==> $baseUrl$appoinmentDetail");
  //   Response response = await dio.post(
  //     '$baseUrl$appoinmentDetail',
  //     data: {
  //       'patient_id': patientId,
  //     },
  //     options: Options(contentType: Headers.formUrlEncodedContentType),
  //   );
  //   prescriptionDetailModel = PrescriptionDetailModel.fromJson(response.data);
  //   return prescriptionDetailModel;
  // }

  // update_appoinment API
  Future<SuccessModel> updateAppoinment(
      appointmentId, doctorSymptoms, doctorDiagnosis) async {
    SuccessModel successModel;
    String updateAppoinment = "update_appoinment";
    printLog("updateAppoinment API :==> $baseUrl$updateAppoinment");
    Response response = await dio.post(
      '$baseUrl$updateAppoinment',
      data: {
        'appointment_id': appointmentId,
        'doctor_symptoms': doctorSymptoms,
        'doctor_diagnosis': doctorDiagnosis,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_medicine_history API
  Future<AppointmentModel> medicineHistory(patentID) async {
    printLog("patientID :==> ${Constant.userID}");

    AppointmentModel appointmentModel;
    String medicineHistory = "get_medicine_history";
    printLog("medicineHistory API :==> $baseUrl$medicineHistory");
    Response response = await dio.post(
      '$baseUrl$medicineHistory',
      data: {
        'patient_id': patentID,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("medicineHistory statuscode :===> ${response.statusCode}");
    printLog("medicineHistory Message :===> ${response.statusMessage}");
    printLog("medicineHistory data :===> ${response.data}");
    appointmentModel = AppointmentModel.fromJson(response.data);
    return appointmentModel;
  }

  // getTimeSlotByDoctorId API
  Future<WorkingTimeSlotModel> timeSlotByDoctorId(
    doctorId,
  ) async {
    printLog("doctorId :==> $doctorId");

    WorkingTimeSlotModel timeSlotModel;
    String timeSlotByDoctor = "get_timeslote_by_doctor";
    printLog("timeSlotByDoctorId API :==> $baseUrl$timeSlotByDoctor");
    Response response = await dio.post(
      '$baseUrl$timeSlotByDoctor',
      data: {
        'doctor_id': doctorId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("timeSlotByDoctorId statuscode :===> ${response.statusCode}");
    printLog("timeSlotByDoctorId Message :===> ${response.statusMessage}");
    printLog("timeSlotByDoctorId data :===> ${response.data}");
    timeSlotModel = WorkingTimeSlotModel.fromJson(response.data);
    return timeSlotModel;
  }

  // get_medicine_list API
  Future<GetMedicineListModel> medicineList() async {
    printLog("patientID :==> ${Constant.userID}");

    GetMedicineListModel getMedicineListModel;
    String medicineList = "suggestion_for_medicine";
    printLog("medicineHistory API :==> $baseUrl$medicineList");
    Response response = await dio.post(
      '$baseUrl$medicineList',
      data: {
        // 'patient_id': patentID,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("medicineHistory statuscode :===> ${response.statusCode}");
    printLog("medicineHistory Message :===> ${response.statusMessage}");
    printLog("medicineHistory data :===> ${response.data}");
    getMedicineListModel = GetMedicineListModel.fromJson(response.data);
    return getMedicineListModel;
  }

  // review_list API
  Future<GetReviewListModel> reviewList(doctorID, pageNo) async {
    GetReviewListModel getReviewListModel;
    // String reviewList = "get_review_list";
    String reviewList = "get_doctor_review";
    printLog("getReviewListModel API :==> $baseUrl$reviewList");
    Response response = await dio.post(
      '$baseUrl$reviewList',
      data: {'doctor_id': doctorID, 'page_no': pageNo},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("getReviewListModel statuscode :===> ${response.statusCode}");
    printLog("getReviewListModel Message :===> ${response.statusMessage}");
    printLog("getReviewListModel data :===> ${response.data}");
    getReviewListModel = GetReviewListModel.fromJson(response.data);
    return getReviewListModel;
  }

  // adreview
  Future<SuccessModel> addreview(
      type, patientid, doctorid, review, commentID) async {
    SuccessModel addreviewmodel;
    String addreview = "add_review";
    Response response = await dio.post(
      '$baseUrl$addreview',
      data: {
        "type": type,
        "patient_id": patientid,
        "doctor_id": doctorid,
        "comment_id": commentID,
        "review": review,
        // "rating": rating,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    printLog("addreviewmodel statuscode :===> ${response.statusCode}");
    printLog("addreviewmodel Message :===> ${response.statusMessage}");
    printLog("addreviewmodel data :===> ${response.data}");
    addreviewmodel = SuccessModel.fromJson(response.data);
    return addreviewmodel;
  }

  // get_reply_comment API
  Future<GetReviewListModel> replycomment(commentId) async {
    GetReviewListModel getRplyCommentModel;
    String replyComments = "get_reply_comment";
    printLog("getRplyCommentModel API :==> $baseUrl$replyComments");
    printLog("getRplyCommentModel commentId :==> $commentId");
    Response response = await dio.post(
      '$baseUrl$replyComments',
      data: {
        'comment_id': commentId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("getRplyCommentModel statuscode :===> ${response.statusCode}");
    printLog("getRplyCommentModel Message :===> ${response.statusMessage}");
    printLog("getRplyCommentModel data :===> ${response.data}");
    getRplyCommentModel = GetReviewListModel.fromJson(response.data);
    return getRplyCommentModel;
  }

  // getPrescription API
  Future<PrescriptionModel> fetchPrescription(appointmentId) async {
    PrescriptionModel prescriptionModel;
    String prescription = "get_prescription";
    printLog("getPrescription API :==> $baseUrl$prescription");
    Response response = await dio.post(
      '$baseUrl$prescription',
      data: {
        'appointment_id': appointmentId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    prescriptionModel = PrescriptionModel.fromJson(response.data);
    return prescriptionModel;
  }

  // delete_prescription API
  Future<SuccessModel> deletePrescription(prescriotionId) async {
    SuccessModel successModel;
    String deletePrescription = "delete_prescription";
    printLog("deletePrescription API :==> $baseUrl$deletePrescription");
    Response response = await dio.post(
      '$baseUrl$deletePrescription',
      data: {
        'prescription_id': prescriotionId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // add_prescription API
  Future<AddPrescriptionModel> addNewPrescriptionDiagnosis(
      appointmentID,
      symptoms,
      diagnosis,
      laboratoryTest,
      pillname,
      howMany,
      timePeriod,
      whenToTake,
      note) async {
    AddPrescriptionModel addPrescriptionModel;
    String addPrescription = "write_prescription";
    printLog("addNewPrescription API :==> $baseUrl$addPrescription");
    Response response = await dio.post(
      '$baseUrl$addPrescription',
      data: {
        'appointment_id': appointmentID,
        'symptoms': symptoms,
        'diagnosis': diagnosis,
        "laboratory_test": laboratoryTest,
        'pill_name': pillname,
        'how_many': howMany,
        // 'how_may': totalMedicine,
        'how_long': timePeriod,
        'when_to_take': whenToTake,
        'note': note,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    addPrescriptionModel = AddPrescriptionModel.fromJson(response.data);
    return addPrescriptionModel;
  }

  // searchMedicine API
  Future<SearchMedicineModel> searchMedicine(medicineName) async {
    SearchMedicineModel medicineModel;
    String searchMedicine = "searchMedicine";
    printLog("searchMedicine API :==> $baseUrl$searchMedicine");
    Response response = await dio.post(
      '$baseUrl$searchMedicine',
      data: {
        'name': medicineName,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    medicineModel = SearchMedicineModel.fromJson(response.data);
    return medicineModel;
  }

  // get_doctor_appoinment API
  Future<NotificationModel> getDoctorNotification(pageNo) async {
    printLog("doctorID :==> ${Constant.userID}");

    NotificationModel notificationModel;
    // String yourappnameoinments = "get_notification_by_doctor";
    String yourappnameoinments = "get_notification";
    printLog("Notification API :==> $baseUrl$yourappnameoinments");
    Response response = await dio.post(
      '$baseUrl$yourappnameoinments',
      data: {'doctor_id': Constant.userID, 'page_no': pageNo, 'type': 1},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    notificationModel = NotificationModel.fromJson(response.data);
    return notificationModel;
  }

  // updateNotificationStatus API
  Future<SuccessModel> updateNotificationStatus(itemID, status) async {
    printLog("itemID :==> $itemID");
    printLog("status :==> $status");

    SuccessModel successModel;
    String updateNotificationStatus = "updateNotificationStatus";
    printLog(
        "updateNotificationStatus API :==> $baseUrl$updateNotificationStatus");
    Response response = await dio.post(
      '$baseUrl$updateNotificationStatus',
      data: {
        'id': itemID,
        'status': status,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_appointment_type_by_patient API
  Future<AppointmentModel> appintmentByType(patientID, type, pageNo) async {
    AppointmentModel appintmentByTypeModel;
    // String getAppintmentByType = "get_appointment_type_by_doctor";
    String getAppintmentByType = "get_appointment_by_doctor";
    // "type": ,
    printLog(
        "get_appointment_type_by_patient API :==> $baseUrl$getAppintmentByType");
    Response response = await dio.post(
      '$baseUrl$getAppintmentByType',
      data: {"doctor_id": patientID, 'page_no': pageNo, "status": type},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("appintment by doctor statuscode :===> ${response.statusCode}");
    printLog("appintment by doctor Message :===> ${response.statusMessage}");
    printLog("appintment by doctor data :===> ${response.data}");
    appintmentByTypeModel = AppointmentModel.fromJson(response.data);
    return appintmentByTypeModel;
  }

  // geget_appointment_statust_specialities API
  Future<AppointmentStatusModel> appointmnetStatus() async {
    AppointmentStatusModel appointmnetStatusModel;
    String getAppointStatus = "get_appointment_status";
    printLog("Speciality API :==> $baseUrl$getAppointStatus");
    Response response = await dio.post(
      '$baseUrl$getAppointStatus',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    printLog("appointment status statuscode :===> ${response.statusCode}");
    printLog("appointment status Message :===> ${response.statusMessage}");
    printLog("appointment status data :===> ${response.data}");
    appointmnetStatusModel = AppointmentStatusModel.fromJson(response.data);
    return appointmnetStatusModel;
  }

  // get_specialities API
  Future<SpecialityModel> getDoctorSpecialities() async {
    SpecialityModel specialityModel;
    String getSpecialities = "get_speciality";
    Response response = await dio.post(
      '$baseUrl$getSpecialities',
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    specialityModel = SpecialityModel.fromJson(response.data);
    return specialityModel;
  }

  // doctor_updateprofile API
  Future<SuccessModel> updateDoctorProfile(
      String userId,
      String email,
      String password,
      String fullName,
      countryCode,
      countryName,
      String mobileNumber,
      String instaURL,
      String twitterURL,
      String fbURL,
      String services,
      String aboutUs,
      String workingTime,
      String healthCare,
      String address,
      String latitude,
      String longitude,
      String specialityId,
      String firebaseId,
      practicingTenure,
      File? docProfileImg,
      String certificate,
      String caseStudies) async {
    SuccessModel successModel;
    String doctorUpdateProfile = "update_profile";
    Response response = await dio.post(
      '$baseUrl$doctorUpdateProfile',
      data: FormData.fromMap({
        'login_type': "1",
        // 'user_id': userId,
        'type_id': userId,
        'doctor_id': userId,
        'email': email,
        'password': password,
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'instagram_url': instaURL,
        'twitter_url': twitterURL,
        'country_code': countryCode,
        'country_name': countryName,
        'facebook_url': fbURL,
        'services': services,
        'practicing_tenure': practicingTenure,
        'about_us': aboutUs,
        'working_time': workingTime,
        'health_care': healthCare,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'specialties_id': specialityId,
        'firebase_id': firebaseId,
        "certificate": certificate,
        "case_studies": caseStudies,
        if (docProfileImg != null)
          "image": (docProfileImg.path.isNotEmpty
              ? (await MultipartFile.fromFile(
                  docProfileImg.path,
                  filename: docProfileImg.path.split('/').last,
                ))
              : ""),
        // if (certificate != null)
        //   "certificate": (certificate.isNotEmpty)
        //       ? (await MultipartFile.fromFile(
        //           certificate,
        //         ))
        //       : "",
        // "case_studies": (caseStudies.isNotEmpty)
        //     ? (await MultipartFile.fromFile(
        //         caseStudies,
        //       ))
        //     : ""
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // doctor_updateprofile API
  Future<SuccessModel> fullUpdateDoctorProfile(
      String userId,
      String email,
      String password,
      String fullName,
      countryCode,
      countryName,
      String mobileNumber,
      String address,
      latitude,
      longitude,
      area,
      city,
      state,
      country,
      File? docProfileImg) async {
    SuccessModel successModel;
    String doctorUpdateProfile = "update_profile";
    Response response = await dio.post(
      '$baseUrl$doctorUpdateProfile',
      data: FormData.fromMap({
        'login_type': "1",
        // 'user_id': userId,
        'type_id': userId,
        'doctor_id': userId,
        'email': email,
        'password': password,
        'full_name': fullName,
        'mobile_number': mobileNumber,
        'country_code': countryCode,
        'country_name': countryName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'area': area,
        'city': city,
        'state': state,
        'country': country,
        if (docProfileImg != null)
          "image": (docProfileImg.path.isNotEmpty
              ? (await MultipartFile.fromFile(
                  docProfileImg.path,
                  filename: docProfileImg.path.split('/').last,
                ))
              : ""),
      }),
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // get_selected_timeslote API
  Future<WorkingTimeSlotModel> workingTimeSlots(doctorId, date) async {
    WorkingTimeSlotModel workingTimeSlotModel;
    String prescription = "get_selected_timeslote";
    Response response = await dio.post(
      '$baseUrl$prescription',
      data: {'doctor_id': doctorId, 'date': date},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    workingTimeSlotModel = WorkingTimeSlotModel.fromJson(response.data);
    return workingTimeSlotModel;
  }

  // get_selected_timeslote API
  Future<TimeSlotModel> workingTimeSlotsResudule(doctorId, weekDay) async {
    TimeSlotModel workingTimeSlotModel;
    String prescription = "get_selected_timeslote";
    Response response = await dio.post(
      '$baseUrl$prescription',
      data: {'doctor_id': doctorId, 'week_day': weekDay},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    workingTimeSlotModel = TimeSlotModel.fromJson(response.data);
    return workingTimeSlotModel;
  }

  // update_doctor_timeslots API
  Future<SuccessModel> addDoctorTimeSlot(doctorSchedule) async {
    SuccessModel successModel;
    String addTimeSlotAPI = "update_doctor_timeslots";
    Response response = await dio.post(
      '$baseUrl$addTimeSlotAPI',
      data: {'schedule': doctorSchedule, 'doctor_id': Constant.userID},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

  // delete_doctor_time_slots API
  Future<SuccessModel> removeDoctorTimeSlot(slotId) async {
    SuccessModel successModel;
    String removeTimeSlotAPI = "delete_doctor_timeslots";
    Response response = await dio.post(
      '$baseUrl$removeTimeSlotAPI',
      data: {
        'id': slotId,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    successModel = SuccessModel.fromJson(response.data);
    return successModel;
  }

/* Send FCM PushNotification API */
  Future sendFCMPushNoti(ChatUserModel? currentUserData, currentuserfirebasid,
      touserfirebaseid, ChatUserModel? toUserData, String? msgContent) async {
    printLog("push token == ${toUserData?.pushToken}");
    var params = {
      "message": {
        "token": toUserData?.pushToken ?? "",
        "notification": {
          "title": "New Message from ${currentUserData?.name}:",
          "body": msgContent ?? ""
        },
        "data": {
          "type": "chat",
          "fromFId": currentuserfirebasid,
          "toFId": touserfirebaseid,
          "username": currentUserData?.name,
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
        },
        "android": {
          "priority": "high",
        },
        "apns": {
          "payload": {
            "aps": {"category": Constant.appName}
          }
        },
        "webpush": {
          "fcm_options": {"link": "https://dummypage.com"}
        }
      }
    };
    var url =
        'https://fcm.googleapis.com/v1/projects/dtapps-f3442/messages:send';
    var response = await http.post(Uri.parse(url),
        headers: {
          /* Use Authorization key = Your Firebase Server key from Project Setting */
          "Authorization": "Bearer ${Constant.accessToken}",
          "Content-Type": "application/json;charset=UTF-8",
          "Charset": "utf-8"
        },
        body: json.encode(params));

    if (response.statusCode == 200) {
      printLog("Send Notification");
      Map<String, dynamic> map = json.decode(response.body);
      printLog("fcm.google map :=====> $map");
    } else {
      Map<String, dynamic> error = jsonDecode(response.body);
      printLog("fcm.google error :=====> $error");
    }
  }

  Future<AttachmentUploadModel> uploadImage(File uploadFile) async {
    String imageUpload = "image_upload";

    try {
      FormData formData = FormData.fromMap({
        'type': 2,
        'upload': await MultipartFile.fromFile(
          uploadFile.path,
          filename: 'uploaded_image.jpg',
        ),
      });

      final response = await dio.post(
        "$baseUrl$imageUpload",
        data: formData,
        options: Options(
          validateStatus: (status) {
            return true;
          },
        ),
      );

      printLog("image_upload statuscode :===> ${response.statusCode}");
      printLog("image_upload Message :===> ${response.statusMessage}");
      printLog("image_upload data :===> ${response.data}");

      AttachmentUploadModel model =
          AttachmentUploadModel.fromJson(jsonDecode(jsonEncode(response.data)));
      return model;
    } on DioException catch (e) {
      if (e.response != null) {
        AttachmentUploadModel model =
            AttachmentUploadModel.fromJson(jsonDecode(e.response?.data));
        return model;
      } else if (e.type == DioExceptionType.connectionError) {
        AttachmentUploadModel model = AttachmentUploadModel()
          ..message = AppString.noInternetConnection;
        return model;
      } else {
        AttachmentUploadModel model = AttachmentUploadModel()
          ..message = AppString.somethingWentWrong;
        return model;
      }
    }
  }
}
