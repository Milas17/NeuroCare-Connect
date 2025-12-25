import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/addprescriptionmodel.dart';
import 'package:yourappname/model/prescriptionmodel.dart';
import 'package:yourappname/model/searchmedicinemodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

import '../model/appointmentmodel.dart';
import '../model/getmedicinelistmodel.dart';
import '../utils/constant.dart';

class WritePrescriptionProvider extends ChangeNotifier {
  // PrescriptionDetailModel prescriptionDetailModel = PrescriptionDetailModel();
  PrescriptionModel prescriptionModel = PrescriptionModel();
  SuccessModel successModel = SuccessModel();
  SuccessModel statussuccessModel = SuccessModel();

  AddPrescriptionModel addPrescriptionModel = AddPrescriptionModel();
  SearchMedicineModel searchMedicineModel = SearchMedicineModel();
  AppointmentModel todayAppointmentModel = AppointmentModel();
  GetMedicineListModel getMedicineListModel = GetMedicineListModel();

  bool loading = false, todayLoading = false;
  SharedPre sharePref = SharedPre();

  Future<void> getTodayAppointment() async {
    todayLoading = true;
    printLog("getTodayAppointment userId :==> ${Constant.userID}");
    printLog("getTodayAppointment status :==> ${todayAppointmentModel.status}");
    printLog(
        "getTodayAppointment message :==> ${todayAppointmentModel.message}");
    todayLoading = false;
    notifyListeners();
  }

  Future<void> getPrescription(appointmentID) async {
    loading = true;
    printLog("getPrescription appointmentID :==> $appointmentID");
    prescriptionModel = await ApiService().fetchPrescription(appointmentID);
    printLog("getPrescription status :==> ${prescriptionModel.status}");
    printLog("getPrescription message :==> ${prescriptionModel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> updateAppoinmentStatus(appointmentID, status) async {
    printLog("updateAppoinmentStatus appointmentID :==> $appointmentID");
    printLog("updateAppoinmentStatus status :==> $status");
    loading = true;
    statussuccessModel =
        await ApiService().appoinmentStatusUpdate(appointmentID, status);
    printLog(
        "appoinment_status_update status :==> ${statussuccessModel.status}");
    printLog(
        "appoinment_status_update message :==> ${statussuccessModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> updateNewAppoinment(
      appointmentID, doctorSymptoms, doctorDiagnosis) async {
    printLog("updateNewAppoinment appointmentID :==> $appointmentID");
    printLog("updateNewAppoinment doctorSymptoms :==> $doctorSymptoms");
    printLog("updateNewAppoinment doctorDiagnosis :==> $doctorDiagnosis");
    loading = true;
    successModel = await ApiService()
        .updateAppoinment(appointmentID, doctorSymptoms, doctorDiagnosis);
    printLog("update_appoinment status :==> ${successModel.status}");
    printLog("update_appoinment message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> deletePrescriptionNow(prescriptionID) async {
    printLog("deletePrescriptionNow prescriptionID :==> $prescriptionID");
    loading = true;
    successModel = await ApiService().deletePrescription(prescriptionID);
    printLog("delete_prescription status :==> ${successModel.status}");
    printLog("delete_prescription message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getMedicinesList() async {
    loading = true;
    getMedicineListModel = await ApiService().medicineList();
    printLog("getMedicineListModel status :==> ${getMedicineListModel.status}");
    printLog(
        "getMedicineListModel message :==> ${getMedicineListModel.message}");
    printLog("getMedicineListModel Model :==> ${getMedicineListModel.result}");
    loading = false;
    notifyListeners();
  }

  Future<void> addPrescription(appointmentID, symptoms, diagnosis,
      laboratoryTest, pillname, howMany, timePeriod, whenToTake, note) async {
    loading = true;
    addPrescriptionModel = await ApiService().addNewPrescriptionDiagnosis(
        appointmentID,
        symptoms,
        diagnosis,
        laboratoryTest,
        pillname,
        howMany,
        timePeriod,
        whenToTake,
        note);
    printLog("add new prescription :- ${addPrescriptionModel.toJson()}");
    prescriptionModel = await ApiService().fetchPrescription(appointmentID);
    printLog("prescription model :- ${prescriptionModel.toJson()}");
    loading = false;
    notifyListeners();
  }

  notifyListener() {
    notifyListeners();
  }

  Future<void> getSearchedMedicine(medicineName) async {
    loading = true;
    searchMedicineModel = await ApiService().searchMedicine(medicineName);
    loading = false;
    notifyListeners();
  }
}
