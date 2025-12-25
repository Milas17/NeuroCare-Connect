import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  SuccessModel successModel = SuccessModel();

  bool loading = false;

  SharedPre sharePref = SharedPre();

  Future<void> getForgotPassword(email) async {
    printLog("getForgotPassword Email :==> $email");
    loading = true;
    successModel = await ApiService().forgotPassword(email);
    printLog("doctor_forgot_password status :==> ${successModel.status}");
    printLog("doctor_forgot_password message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> getChangePassword(
      currentPassword, newpassword, confirmpassword) async {
    printLog("getChangePassword Email :==> $newpassword, $confirmpassword");
    loading = true;
    successModel = await ApiService()
        .changePassword(currentPassword, newpassword, confirmpassword);
    printLog("getChangePassword status :==> ${successModel.status}");
    printLog("getChangePassword message :==> ${successModel.message}");
    loading = false;
    notifyListeners();
  }
}
