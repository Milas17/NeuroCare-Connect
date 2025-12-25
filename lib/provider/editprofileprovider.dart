import 'dart:convert';

import 'package:yourappname/utils/utils.dart';
import 'dart:io';
import 'package:yourappname/model/doctorprofilemodel.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/workingtimeslotmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/attachmentuploadmodel.dart';

class EditProfileProvider extends ChangeNotifier {
  DoctorProfileModel doctorProfileModel = DoctorProfileModel();
  SpecialityModel specialityModel = SpecialityModel();
  SuccessModel successModel = SuccessModel();
  // WorkingTimeSlotModel workingTimeSlotModel = WorkingTimeSlotModel();
  SuccessModel addReviewModel = SuccessModel();
  WorkingTimeSlotModel timeSlotModel = WorkingTimeSlotModel();

  File? pickedImageFile, licFrontFile, licBackFile, degreeDocuments, bankIDfile;

  clearAvailability() {
    loading = false;
    weekSlots = {
      "Monday": [],
      "Tuesday": [],
      "Wednesday": [],
      "Thursday": [],
      "Friday": [],
      "Saturday": [],
      "Sunday": [],
    };
    weekDates = {
      "Monday": null,
      "Tuesday": null,
      "Wednesday": null,
      "Thursday": null,
      "Friday": null,
      "Saturday": null,
      "Sunday": null,
    };
    timeSlotModel = WorkingTimeSlotModel();
  }

  bool loading = false, loadingAdd = false, editloading = false;
  SharedPre sharePref = SharedPre();

  Map<String, List<TimeSlote>> weekSlots = {
    "Monday": [],
    "Tuesday": [],
    "Wednesday": [],
    "Thursday": [],
    "Friday": [],
    "Saturday": [],
    "Sunday": [],
  };

  Map<String, DateTime?> weekDates = {
    "Monday": null,
    "Tuesday": null,
    "Wednesday": null,
    "Thursday": null,
    "Friday": null,
    "Saturday": null,
    "Sunday": null,
  };

  Future<void> getSpecialities() async {
    loading = true;
    printLog("getSpecialities userId :===> ${Constant.userID}");
    specialityModel = await ApiService().getDoctorSpecialities();
    printLog("getSpecialities status :===> ${specialityModel.status}");
    printLog("getSpecialities message :==> ${specialityModel.message}");
    loading = false;
    notifyListeners();
  }

  setPickedImage(File? pickedImage) {
    pickedImageFile = pickedImage;
    notifyListeners();
  }

  setLICFrontImage(File? pickedImage) {
    licFrontFile = pickedImage;
    notifyListeners();
  }

  setLICBackImage(File? pickedImage) {
    licBackFile = pickedImage;
    notifyListeners();
  }

  setDegreeDocImage(File? pickedImage) {
    degreeDocuments = pickedImage;
    notifyListeners();
  }

  setBankIDImage(File? pickedImage) {
    bankIDfile = pickedImage;
    notifyListeners();
  }

  Future<void> getTimeSlotByDoctorId(
    doctorId,
  ) async {
    printLog("getTimeSlotByDoctorId doctorId :==> $doctorId");
    loading = true;
    timeSlotModel = await ApiService().timeSlotByDoctorId(
      doctorId,
    );
    printLog("getTimeSlotByDoctorId status :==> ${timeSlotModel.status}");
    printLog("getTimeSlotByDoctorId message :==> ${timeSlotModel.message}");
    printLog("getTimeSlotByDoctorId Data :==> ${jsonEncode(timeSlotModel)}");
    printLog(
        "getTimeSlotByDoctorId length :==> ${timeSlotModel.result?.length}");
    await mapSlotsToWeekDays();
    loading = false;
    notifyListeners();
  }

  Future<void> getDoctorDetails() async {
    loading = true;
    printLog("getDoctorDetails userId :===> ${Constant.userID}");
    doctorProfileModel = await ApiService().doctorDetails(Constant.userID);
    printLog("getDoctorDetails status :===> ${doctorProfileModel.status}");
    printLog("getDoctorDetails message :==> ${doctorProfileModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<AttachmentUploadModel> uploadAttachmentApi(String path) async {
    AttachmentUploadModel attachmentUploadModel =
        await ApiService().uploadImage(File(path));
    return attachmentUploadModel;
  }

  setLoading(bool isLoading) {
    loading = isLoading;
  }

  Future<void> getAddreview(
      type, patientid, doctorid, review, commentID) async {
    loadingAdd = true;
    addReviewModel = await ApiService()
        .addreview(type, patientid, doctorid, review, commentID);
    loadingAdd = false;
    notifyListeners();
  }

  Future<void> getDoctorUpdateProfile(
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
    editloading = true;
    printLog("getDoctorUpdateProfile firebaseId :=====> $firebaseId");
    printLog("getDoctorUpdateProfile userId :=========> ${Constant.userID}");
    printLog("getDoctorUpdateProfile docProfileImg :==> $docProfileImg");
    successModel = await ApiService().updateDoctorProfile(
        Constant.userID.toString(),
        email,
        password,
        fullName,
        countryCode,
        countryName,
        mobileNumber,
        instaURL,
        twitterURL,
        fbURL,
        services,
        aboutUs,
        workingTime,
        healthCare,
        address,
        latitude,
        longitude,
        specialityId,
        firebaseId,
        practicingTenure,
        docProfileImg,
        certificate,
        caseStudies);
    printLog("doctor_updateprofile status :==> ${successModel.status}");
    printLog("doctor_updateprofile message :==> ${successModel.message}");
    editloading = false;
    notifyListeners();
  }

  Future<void> getDoctorFullUpdateProfile(
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
    editloading = true;
    printLog("getDoctorUpdateProfile userId :=========> ${Constant.userID}");
    printLog("getDoctorUpdateProfile docProfileImg :==> $docProfileImg");
    successModel = await ApiService().fullUpdateDoctorProfile(
        Constant.userID.toString(),
        email,
        password,
        fullName,
        countryCode,
        countryName,
        mobileNumber,
        address,
        latitude,
        longitude,
        area,
        city,
        state,
        country,
        docProfileImg);
    printLog("doctor_updateprofile status :==> ${successModel.status}");
    printLog("doctor_updateprofile message :==> ${successModel.message}");
    editloading = false;
    notifyListeners();
  }

  Future<void> mapSlotsToWeekDays() async {
    // Clear old data
    weekSlots.updateAll((key, value) => []);
    weekDates.updateAll((key, value) => null);
    Map<String, DateTime> dates = getCurrentWeekDates();
    dates.forEach((day, date) {
      weekDates[day] = date;
    });
    if (timeSlotModel.result != null && timeSlotModel.result!.isNotEmpty) {
      await Future.forEach(timeSlotModel.result!, (item) {
        try {
          if (item.timeSlotes != null && item.timeSlotes!.isNotEmpty) {
            DateTime date = DateTime.parse(item.timeSlotes![0].date ?? "");
            String weekday = DateFormat('EEEE').format(date); // e.g. Thursday
            printLog("Week day :- $weekday   Date :- $date");

            if (weekSlots.containsKey(weekday)) {
              weekSlots[weekday] = item.timeSlotes ?? [];
              // weekDates[weekday] = date;
            }
          }
        } catch (e) {
          printLog("Date parse error: $e");
        }
      });
    }

    notifyListeners();
  }

  Map<String, DateTime> getCurrentWeekDates() {
    DateTime today = DateTime.now();
    int currentWeekday = today.weekday; // Monday=1, Sunday=7

    // Go back to Monday of this week
    DateTime monday = today.subtract(Duration(days: currentWeekday - 1));

    Map<String, DateTime> weekDates = {};
    for (int i = 0; i < 7; i++) {
      DateTime date = monday.add(Duration(days: i));
      String weekday = DateFormat('EEEE').format(date); // e.g. Monday
      weekDates[weekday] = date;
    }

    return weekDates;
  }

  final Map<int, bool> _switchStates = {};

  bool getSwitchState(int weekPos) {
    return _switchStates[weekPos] ?? false;
  }

  void toggleSwitch(int weekPos, bool newState) {
    _switchStates[weekPos] = newState;
    notifyListeners();
  }

  notifyListener() {
    notifyListeners();
  }

  clearProvider() {
    pickedImageFile = File("");
    pickedImageFile = null;
    loading = false;
  }

  allDataclearProvider() {
    pickedImageFile = File("");
    pickedImageFile = null;
    licFrontFile = File("");
    licFrontFile = null;
    licBackFile = File("");
    licBackFile = null;
    degreeDocuments = File("");
    degreeDocuments = null;
    bankIDfile = File("");
    bankIDfile = null;
    loading = false;
  }
}
