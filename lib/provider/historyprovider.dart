import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class HistoryProvider extends ChangeNotifier {
  AppointmentModel appointmentModel = AppointmentModel();

  bool loading = false;

  SharedPre sharePref = SharedPre();

  Future<void> getMedicineHistory(patentID) async {
    printLog("getMedicineHistory patientID :==> ${Constant.userID}");
    loading = true;
    appointmentModel = await ApiService().medicineHistory(patentID);
    printLog("get_medicine_history status :==> ${appointmentModel.status}");
    printLog("get_medicine_history message :==> ${appointmentModel.message}");
    loading = false;
    notifyListeners();
  }
}
