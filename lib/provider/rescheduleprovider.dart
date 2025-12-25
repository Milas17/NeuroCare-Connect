import 'dart:convert';

import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/timeslotmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class Rescheduleprovider extends ChangeNotifier {
  TimeSlotModel timeSlotModel = TimeSlotModel();
  SuccessModel successModel = SuccessModel();
  bool loading = false;
  int? availableTimePos, appointmentTimePos, pickTimePos;
  bool isDateSelected = false;

  Future<void> getUpdateRescudule(
      appointmentId, date, startTime, endTime) async {
    loading = true;
    printLog("getSpecialities userId :===> ${Constant.userID}");
    successModel = await ApiService()
        .updateShedule(appointmentId, date, startTime, endTime);
    printLog("getSpecialities status :===> ${successModel.status}");
    printLog("getSpecialities message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  getClickAappointmentTime(clickedPos) {
    loading = true;
    printLog("clickedPos ===> $clickedPos");
    appointmentTimePos = clickedPos;
    loading = false;
    notifyListeners();
  }

  getClickPickTime(clickedPos) {
    loading = true;
    printLog("clickedPos ===> $clickedPos");
    pickTimePos = clickedPos;
    loading = false;
    notifyListeners();
  }

  getClickAvailableTime(clickedPos) {
    loading = true;
    printLog("clickedPos ===> $clickedPos");
    availableTimePos = clickedPos;
    loading = false;
    notifyListeners();
  }

  getClickedDate(isClicked) {
    loading = true;
    printLog("isClicked ===> $isClicked");
    isDateSelected = isClicked;
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    loading = false;
    successModel = SuccessModel();
    appointmentTimePos = -1;
    availableTimePos = -1;
  }

  notifyListener() {
    notifyListeners();
  }

  Future<void> getTimeSlotByDoctorId(doctorId, weekDay) async {
    printLog("getTimeSlotByDoctorId doctorId :==> $doctorId");
    loading = true;
    timeSlotModel =
        await ApiService().workingTimeSlotsResudule(doctorId, weekDay);
    printLog("getTimeSlotByDoctorId status :==> ${timeSlotModel.status}");
    printLog("getTimeSlotByDoctorId message :==> ${timeSlotModel.message}");
    printLog("getTimeSlotByDoctorId Data :==> ${jsonEncode(timeSlotModel)}");
    printLog(
        "getTimeSlotByDoctorId length :==> ${timeSlotModel.result?.length}");

    loading = false;
    notifyListeners();
  }
}
