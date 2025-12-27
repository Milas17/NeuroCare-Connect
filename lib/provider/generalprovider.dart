import 'dart:io';

import 'package:yourappname/model/generalsettingmodel.dart';
import 'package:yourappname/model/loginregistermodel.dart';
import 'package:yourappname/model/onboardingmodel.dart';
import 'package:yourappname/model/sociallinkmodel.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/pagesmodel.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class GeneralProvider extends ChangeNotifier {
  GeneralSettingModel generalSettingModel = GeneralSettingModel();
  LoginRegisterModel loginRegisterModel = LoginRegisterModel();
  SuccessModel kycSuccessModel = SuccessModel();
  PagesModel pagesModel = PagesModel();
  SocialLinkModel socialLinkModel = SocialLinkModel();
  var loadingPercentage = 0;
  SpecialityModel specialityModel = SpecialityModel();
  bool loading = false;
  File? pickedImageFile, licFrontFile, licBackFile, degreeDocuments, bankIDfile;

  SharedPre sharePref = SharedPre();

  OnboardingModel onboardingModel = OnboardingModel();
  bool loadingIntro = false;

  Future<void> getOnboardingScreen() async {
    loadingIntro = true;
    try {
      onboardingModel = await ApiService().onBoardingScreen();
      printLog("onboardingModel status :==> ${onboardingModel.status}");
      printLog("onboardingModel message :==> ${onboardingModel.message}");
    } catch (e) {
      printLog("Error in getOnboardingScreen: $e");
    } finally {
      loadingIntro = false;
      notifyListeners();
    }
  }

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

  // Future<void> getGeneralsetting(context) async {
  //   loading = true;
  //   generalSettingModel = await ApiService().genaralSetting();
  //   printLog("genaral_setting status :==> ${generalSettingModel.status}");
  //   loading = false;
  //   notifyListeners();
  // }

  Future<void> getGeneralsetting(context) async {
    loading = true;
    try {
      generalSettingModel = await ApiService().genaralSetting();
      if (generalSettingModel.status == 200 &&
          (generalSettingModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (generalSettingModel.result?.length ?? 0); i++) {
          sharePref.save(
            generalSettingModel.result?[i].key.toString() ?? "",
            generalSettingModel.result?[i].value.toString() ?? "",
          );
        }
        // Constant.versionCode = await sharedPred.read('app_version');
        // Constant.userId = await sharedPred.read('userid');
        // Constant.type = await sharedPred.read('type');
        Constant.oneSignalAppId =
            await sharePref.read(Constant.oneSignalAppIdKey);
        // debugPrint("versionCode==> ${Constant.versionCode}");
        // debugPrint("userId==> ${Constant.userId}");
        // debugPrint("type==> ${Constant.type}");
        debugPrint("oneSignalAppId==> ${Constant.oneSignalAppId}");
      }
      printLog("genaral_setting status :==> ${generalSettingModel.status}");
    } catch (e) {
      printLog("Error in getGeneralsetting: $e");
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> getPages() async {
    loading = true;
    pagesModel = await ApiService().getPages();
    loading = false;
    printLog("getPages status :==> ${pagesModel.status}");
    notifyListeners();
  }

  Future<void> getSocialLink() async {
    loading = true;
    socialLinkModel = await ApiService().getSocialLinks();
    loading = false;
    printLog("getPages status :==> ${pagesModel.status}");
    notifyListeners();
  }

  Future<void> registerDoctor(
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
    printLog("registerDoctor fullName :=====> $fullName");
    printLog("registerDoctor email :========> $email");
    printLog("registerDoctor password :=====> $password");
    printLog("registerDoctor mobile :=======> $mobile");
    printLog("registerDoctor deviceToken :==> $deviceToken");
    printLog("registerDoctor deviceType :===> $deviceType");

    loading = true;
    loginRegisterModel = await ApiService().doctorRegistration(
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
        docProfileImg);
    printLog("doctor_registration status :==> ${loginRegisterModel.status}");
    printLog("doctor_registration message :==> ${loginRegisterModel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> doctorKYC(
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
    loading = true;
    printLog("kycSuccessModel licFrontImage :==> ${licFrontImage.runtimeType}");
    printLog("kycSuccessModel licBackImage :==> ${licBackImage.runtimeType}");
    kycSuccessModel = await ApiService().doctorKYC(
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
        doctorId);
    printLog("kycSuccessModel status :==> ${kycSuccessModel.status}");
    printLog("kycSuccessModel message :==> ${kycSuccessModel.message}");

    loading = false;
    notifyListeners();
  }

  Future<void> loginDoctor(
      email, password, type, firebaseid, deviceToken) async {
    printLog("loginDoctor email :==> $email");
    printLog("loginDoctor password :==> $password");
    printLog("loginDoctor type :==> $type");
    printLog("loginDoctor deviceToken :==> $deviceToken");

    loading = true;
    loginRegisterModel = await ApiService()
        .doctorLogin(email, password, type, firebaseid, deviceToken);
    printLog("doctor_login status :==> ${loginRegisterModel.status}");
    printLog("doctor_login message :==> ${loginRegisterModel.message}");
    loading = false;
    notifyListeners();
  }

  Future<void> loginOTPDoctor(mobileNumber, countryCode, countryName, type,
      firebaseid, deviceType, deviceToken) async {
    loading = true;
    loginRegisterModel = await ApiService().doctorOTPLogin(mobileNumber,
        countryCode, countryName, type, firebaseid, deviceType, deviceToken);

    loading = false;
    notifyListeners();
  }

  Future<void> loginDoctorSocial(email, type, firebaseid, deviceToken) async {
    printLog("loginDoctor email :==> $email");
    printLog("loginDoctor type :==> $type");
    printLog("loginDoctor deviceToken :==> $deviceToken");

    loading = true;
    loginRegisterModel = await ApiService()
        .doctorLoginSocial(email, type, firebaseid, deviceToken);
    printLog("doctor_login status :==> ${loginRegisterModel.status}");
    printLog("doctor_login message :==> ${loginRegisterModel.message}");
    loading = false;
    notifyListeners();
  }

  notifyListener() {
    notifyListeners();
  }

  clearProvider() {
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
