import 'package:yourappname/model/appointmentdetailsmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class AppointmentDetailProvider extends ChangeNotifier {
  AppointmentDetailsModel appointmentModel = AppointmentDetailsModel();
  SuccessModel successModel = SuccessModel();

  bool loading = false;
  SharedPre sharePref = SharedPre();

  Future<void> getAppointmentDetails(appointmentID) async {
    loading = true;
    printLog("getAppointmentDetails appointmentID :==> $appointmentID");
    appointmentModel = await ApiService().appoinmentDetails(appointmentID);
    printLog("appoinment_detail status :==> ${appointmentModel.status}");
    printLog("appoinment_detail message :==> ${appointmentModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :==> $status");
    loading = true;
    successModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog("appoinment_status_update status :==> ${successModel.status}");
    printLog("appoinment_status_update message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }
}
