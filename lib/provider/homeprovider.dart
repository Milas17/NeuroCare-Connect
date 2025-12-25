import 'package:yourappname/model/blogmodel.dart';
import 'package:yourappname/model/patientlistgraphmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/appointmentmodel.dart';
import 'package:yourappname/model/doctorprofilemodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  DoctorProfileModel doctorProfileModel = DoctorProfileModel();
  AppointmentModel appointmentModel = AppointmentModel();
  AppointmentModel pendingAppointmentModel = AppointmentModel();
  SuccessModel successModel = SuccessModel();
  AppointmentModel todayAppointmentModel = AppointmentModel();
  PatientListGraphModel patientListGraphModel = PatientListGraphModel();
  BlogModel blogModel = BlogModel();

  bool loading = false,
      pendingLoading = false,
      blogLoading = false,
      graphLoading = false,
      todayLoading = false,
      loadingUpdate = false;
  SharedPre sharePref = SharedPre();

  Future<void> getDoctorDetails() async {
    loading = true;
    printLog("getDoctorDetails userId :==> ${Constant.userID}");
    doctorProfileModel = await ApiService().doctorDetails(Constant.userID);
    printLog("doctor_detail status :==> ${doctorProfileModel.status}");
    printLog("doctor_detail message :==> ${doctorProfileModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getPatientList() async {
    graphLoading = true;
    printLog("patientListGraphModel userId :==> ${Constant.userID}");
    patientListGraphModel = await ApiService().getPatientList();
    printLog(
        "patientListGraphModel status :==> ${patientListGraphModel.status}");
    printLog(
        "patientListGraphModel message :==> ${patientListGraphModel.message}");
    graphLoading = false;
    notifyListeners();
  }

  Future<void> getTodayAppointment(pageNo) async {
    todayLoading = true;
    printLog("getTodayAppointment userId :==> ${Constant.userID}");
    todayAppointmentModel =
        await ApiService().todayappointment(Constant.userID, pageNo);
    printLog("getTodayAppointment status :==> ${todayAppointmentModel.status}");
    printLog(
        "getTodayAppointment message :==> ${todayAppointmentModel.message}");
    todayLoading = false;
    notifyListeners();
  }

  Future<void> getBlog() async {
    blogLoading = true;
    blogModel = await ApiService().getBlog();
    printLog("blogModel status :==> ${blogModel.status}");
    printLog("blogModel message :==> ${blogModel.message}");
    blogLoading = false;
    notifyListeners();
  }

  Future<void> getPendingAppointment(pageNo) async {
    pendingLoading = true;
    printLog("getPendingAppointment userId :==> ${Constant.userID}");
    pendingAppointmentModel =
        await ApiService().pendingappointment(Constant.userID, pageNo);
    printLog(
        "getPendingAppointment status :==> ${pendingAppointmentModel.status}");
    printLog(
        "getPendingAppointment message :==> ${pendingAppointmentModel.message}");
    pendingLoading = false;
    notifyListeners();
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :=========> $status");
    loadingUpdate = true;
    successModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog("updateAppoinmentStatus status :===> ${successModel.status}");
    printLog("updateAppoinmentStatus message :==> ${successModel.message}");
    loadingUpdate = false;
    notifyListeners();
  }
}
