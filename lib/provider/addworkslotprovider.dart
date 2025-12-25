import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/workingtimeslotmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/date_format.dart';

class AddWorkSlotProvider extends ChangeNotifier {
  SuccessModel successUpdateModel = SuccessModel();
  SuccessModel successModel = SuccessModel();
  WorkingTimeSlotModel workingTimeSlotModel = WorkingTimeSlotModel();
  List<TimeSlote> slotList = <TimeSlote>[];

  bool loading = false, loadingUpdate = false;
  SharedPre sharePref = SharedPre();

  Future<void> getWorkingSlots(date) async {
    loading = true;
    String formattedDate = DateFormatter().dateConverter(date,DateFormat("yyyy-MM-dd"));
    printLog("getWorkingSlots userId :==> ${Constant.userID}");
    workingTimeSlotModel =
        await ApiService().workingTimeSlots(Constant.userID, formattedDate);
    printLog(
        "get_selected_timeslote status :==> ${workingTimeSlotModel.status}");
    printLog(
        "get_selected_timeslote message :==> ${workingTimeSlotModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> updateDoctorTimeSlot(doctorSchedule) async {
    loadingUpdate = true;
    printLog("updateDoctorTimeSlot doctorSchedule :==> $doctorSchedule");
    successUpdateModel = await ApiService().addDoctorTimeSlot(doctorSchedule);
    printLog("updateDoctorTimeSlot status :===> ${successUpdateModel.status}");
    printLog("updateDoctorTimeSlot message :==> ${successUpdateModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }

  Future<void> deleteDoctorTimeSlot(slotId) async {
    loading = true;
    printLog("deleteDoctorTimeSlot slotId :==> $slotId");
    successModel = await ApiService().removeDoctorTimeSlot(slotId);
    printLog("delete_doctor_time_slots status :==> ${successModel.status}");
    printLog("delete_doctor_time_slots message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> addEmptySlot(weekDay) async {
    loading = true;
    TimeSlote timeSlots = TimeSlote();
    timeSlots.id = 0;
    timeSlots.doctorId = int.parse(Constant.userID ?? "");
    timeSlots.startTime = "00:00";
    timeSlots.weekDay = weekDay;
    timeSlots.endTime = "00:00";
    timeSlots.timeDuration = "00";
    if (slotList.isNotEmpty) {
      timeSlots.tslPosition = slotList.length;
    } else {
      timeSlots.tslPosition = 0;
    }
    timeSlots.timeSchedul = <TimeSchedul>[];

    slotList.add(timeSlots);
    printLog('slotList size ==NEW==>> ${slotList.length}');
    loading = false;
    notifyListeners();
  }

  Future<void> updateTime(type, selectedTime, position) async {
    printLog("type ==> $type");
    printLog("selectedTime ==> $selectedTime");
    printLog("position ==> $position");
    loading = true;
    if (type == "Start") {
      slotList[position].startTime = "$selectedTime";
    } else if (type == "End") {
      slotList[position].endTime = "$selectedTime";
    }
    printLog("slotList length => ${slotList.length}");

    loading = false;
    notifyListeners();
  }

  Future<void> deleteSlot(slotID, position) async {
    printLog("deleteSlot slotID ==> $slotID");
    printLog("deleteSlot position ==> $position");
    loading = true;
    if (slotID != "0") {
      await deleteDoctorTimeSlot(slotID);
    }
    slotList.removeAt(position);
    printLog("slotList length => ${slotList.length}");
    loading = false;
    notifyListeners();
  }

  Future<void> createWorkTiming(BuildContext context, position) async {
    printLog("position ==> $position");
    loading = true;
    printLog('createWorkTiming position ====> $position');
    await Utils().getTimeFromSlot(
        context,
        position,
        slotList[position].id.toString(),
        slotList[position].timeDuration.toString(),
        slotList[position].startTime.toString(),
        slotList[position].endTime.toString());
    printLog(
        'createWorkTiming timeSchedul ====> ${slotList[position].timeSchedul!.length}');
    loading = false;
    notifyListeners();
  }

  clearWrokSlotProvider() {
    printLog("<================ clearWrokSlotProvider ================>");
    loading = false;
    loadingUpdate = false;
    workingTimeSlotModel = WorkingTimeSlotModel();
    successModel = SuccessModel();
    successUpdateModel = SuccessModel();
    slotList = <TimeSlote>[];
  }
}
