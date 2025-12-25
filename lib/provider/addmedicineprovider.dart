import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/addprescriptionmodel.dart';
import 'package:yourappname/model/searchmedicinemodel.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';

class AddMedicineProvider extends ChangeNotifier {
  AddPrescriptionModel addPrescriptionModel = AddPrescriptionModel();
  SearchMedicineModel searchMedicineModel = SearchMedicineModel();

  bool loading = false;
  SharedPre sharePref = SharedPre();

  Future<void> getSearchedMedicine(medicineName) async {
    loading = true;
    printLog("getSearchedMedicine medicineName :==> $medicineName");
    searchMedicineModel = await ApiService().searchMedicine(medicineName);
    printLog("searchMedicine status :==> ${searchMedicineModel.status}");
    printLog("searchMedicine message :==> ${searchMedicineModel.message}");
    loading = false;
    notifyListeners();
  }
}
