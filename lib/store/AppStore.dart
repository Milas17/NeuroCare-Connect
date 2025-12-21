import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/locale/app_localizations.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/dashboard_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/app_constants.dart';
import 'package:mobx/mobx.dart';
import 'package:nb_utils/nb_utils.dart';

part 'AppStore.g.dart';

class AppStore = AppStoreBase with _$AppStore;

abstract class AppStoreBase with Store {
  @observable
  String appVersion = '';

  @observable
  String password = '';

  @observable
  bool isReceptionistEnabled = true;

  @observable
  bool isDarkModeOn = false;

  @observable
  bool isLoading = false;

  @observable
  bool isConnectedToInternet = false;

  @observable
  bool isTester = false;

  @observable
  bool isLoggedIn = false;

  @observable
  bool isNotificationsOn = false;

  @observable
  String playerId = '';

  @observable
  bool isBookedFromDashboard = false;

  @observable
  String mStatus = "All";

  @observable
  int? restrictAppointmentPost;

  @observable
  int? restrictAppointmentPre;

  @observable
  String? currency;

  @observable
  String currencySymbol = '';

  @observable
  String currencyCode = '';

  @observable
  String wcCurrency = '';

  @observable
  bool isRazorPayEnable = false;

  @observable
  bool isStripePayEnable = false;

  @observable
  bool isWoocommerceEnable = false;

  @observable
  bool isPayOffline = false;

  @observable
  String paymentRazorpay = '';

  @observable
  String paymentStripe = '';

  @observable
  String paymentWoocommerce = '';

  @observable
  String paymentOffline = '';

  @observable
  String paymentMode = '';

  @observable
  String? currencyPrefix;

  @observable
  String? currencyPostfix;

  @observable
  String? tempBaseUrl;

  @observable
  bool? userProEnabled;

  @observable
  bool isGoogleMeetActive = false;

  @observable
  String? globalDateFormat;

  @observable
  String? globalUTC;

  @observable
  String selectedLanguageCode = DEFAULT_LANGUAGE;

  @observable
  String? demoDoctor;

  @observable
  String? demoReceptionist;

  @observable
  String? demoPatient;

  @observable
  String selectedLanguage = DEFAULT_LANGUAGE;

  @observable
  List<dynamic> demoEmails = [];

  @observable
  DashboardModel cachedDashboardData = DashboardModel();

  @observable
  int? clinicId;

  @observable
  String wcNonce = '';

  @observable
  String apiNonce = '';

  @observable
  bool? isLocationEnabled;
  @observable
  int isFromUpcoming = -1;

  @observable
  bool teleMedEnabled = false;

  @observable
  bool enableEncounterEditAfterCloseStatus = false;

  @observable
  bool isProblem = false;

  @observable
  bool isobservation = false;

  @observable
  bool isNotes = false;

  @observable
  bool isPrescription = false;

  @observable
  bool isBilling = false;

  @action
  Future<void> setbilling(bool val) async {
    isBilling = val;
    await setValue('isBilling', val);
  }

  @action
  Future<void> setProblem(bool val) async {
    isProblem = val;
    await setValue('isproblem', val);
  }

  @action
  Future<void> setObservation(bool val) async {
    isobservation = val;
    await setValue('isobservation', val);
  }

  @action
  Future<void> setNote(bool val) async {
    isNotes = val;
    await setValue('isnotes', val);
  }

  @action
  Future<void> setPrescription(bool val) async {
    isPrescription = val;
    await setValue('isprescription', val);
  }

  @action
  Future<void> setTeleMedEnabled(bool val) async {
    teleMedEnabled = val;
  }

  @action
  Future<void> setEnableEncounterEditAfterCloseStatus(bool value) async {
    enableEncounterEditAfterCloseStatus = value;
    await setValue('isEnableEncounterEditAfterCloseStatus', value);
  }

  @action
  Future<void> setReceptionistEnabled(bool value) async {
    isReceptionistEnabled = value;
    await setValue('isReceptionistEnabled', value); // optional: persist
  }

  @action
  void setUpcoming(int status) {
    isFromUpcoming = status;
  }

  @action
  void setAppVersion(String version) {
    appVersion = version;
    setValue(AppKeys.appVersionKey, appVersion);
  }

  void setApiNonce(String nonce) {
    apiNonce = nonce;
    setValue(ApiHeaders.apiNonce, apiNonce, print: true);
  }

  void setPassword(String pwd, {bool initialize = false}) {
    password = pwd;
    if (initialize) setValue(AppKeys.passwordKey, password);
  }

  @action
  void setDemoEmails() {
    String temp = FirebaseRemoteConfig.instance.getString(DEMO_EMAILS);

    if (temp.isNotEmpty && temp.isJson()) {
      demoEmails = jsonDecode(temp) as List<dynamic>;
    } else {
      log('');
    }
  }

  @action
  void setGoogleMeetEnabled(bool googleMeetEnable) {
    isGoogleMeetActive = googleMeetEnable;
  }

  @action
  Future<void> setRazorPay(bool value) async {
    isRazorPayEnable = value;
  }

  @action
  Future<void> setStripePay(bool value) async {
    isStripePayEnable = value;
  }

  @action
  Future<void> setOffLinePayment(bool value) async {
    isPayOffline = value;
  }

  @action
  Future<void> setPaymentMode(String value) async {
    paymentMode = value;
  }

  @action
  Future<void> setWoocommerce(bool value) async {
    isWoocommerceEnable = value;
  }

  @action
  Future<void> setRazorPayMethod(String value) async {
    paymentRazorpay = value;
  }

  @action
  Future<void> setStripePayMethod(String value) async {
    paymentStripe = value;
  }

  @action
  Future<void> setOffLinePaymentMethod(String value) async {
    paymentOffline = value;
  }

  @action
  Future<void> setWoocommerceMethod(String value) async {
    paymentWoocommerce = value;
  }

  @action
  Future<void> setGlobalUTC(String value) async {
    setValue(GLOBAL_UTC, value);
    globalUTC = value;
  }

  @action
  void setInternetStatus(bool val) {
    isConnectedToInternet = val;
  }

  Future<void> setDarkMode(bool aIsDarkMode) async {
    isDarkModeOn = aIsDarkMode;

    if (isDarkModeOn) {
      textPrimaryColorGlobal = textPrimaryDarkColor;
      textSecondaryColorGlobal = textSecondaryWhiteColor;
      defaultLoaderBgColorGlobal = cardSelectedColor;
      selectedColor = selectedColorDarkMode;
    } else {
      textPrimaryColorGlobal = textPrimaryLightColor;
      textSecondaryColorGlobal = textSecondaryLightColor;
      defaultLoaderBgColorGlobal = Colors.white;
      selectedColor = selectedColorLightMode;
    }
  }

  @action
  Future<void> setLoggedIn(bool value) async {
    setValue(IS_LOGGED_IN, value);
    isLoggedIn = value;
  }

  @action
  Future<void> setBookedFromDashboard(bool value) async => isBookedFromDashboard = value;

  @action
  Future<void> setDemoDoctor(String value, {bool initialize = false}) async {
    if (initialize) setValue(DEMO_DOCTOR, value);
    demoDoctor = value;
  }

  @action
  Future<void> setDemoReceptionist(String value, {bool initialize = false}) async {
    if (initialize) setValue(DEMO_RECEPTIONIST, value);
    demoReceptionist = value;
  }

  @action
  Future<void> setDemoPatient(String value, {bool initialize = false}) async {
    if (initialize) setValue(DEMO_PATIENT, value);
    demoPatient = value;
  }

  @action
  Future<void> setRestrictAppointmentPost(int value, {bool initialize = false}) async {
    if (initialize) setValue(RESTRICT_APPOINTMENT_POST, value);
    restrictAppointmentPost = value;
  }

  @action
  Future<void> setRestrictAppointmentPre(int value, {bool initialize = false}) async {
    if (initialize) setValue(RESTRICT_APPOINTMENT_PRE, value);
    restrictAppointmentPre = value;
  }

  @action
  Future<void> setLoading(bool value) async => isLoading = value;

  @action
  Future<void> setCurrency(String value, {bool initialize = false}) async {
    if (initialize) setValue(CURRENCY, value);

    currency = value;
  }

  @action
  Future<void> setCurrencySymbol(String val, {bool isInitializing = false}) async {
    currencySymbol = val;
    if (!isInitializing) await setValue(CURRENCY_SYMBOL, val);
  }

  @action
  Future<void> setCurrencyCode(String val, {bool isInitializing = false}) async {
    currencyCode = val;
    if (!isInitializing) await setValue(CURRENCY_CODE, val);
  }

  @action
  Future<void> setWcCurrency(String val, {bool isInitializing = false}) async {
    wcCurrency = val;
    if (!isInitializing) await setValue(WC_CURRENCY_CODE, val);
  }

  @action
  Future<void> setCurrencyPostfix(String value, {bool initialize = false}) async {
    if (initialize) setValue(CURRENCY_POST_FIX, value);

    currencyPostfix = value;
  }

  @action
  Future<void> setCurrencyPrefix(String value, {bool initialize = false}) async {
    if (initialize) setValue(CURRENCY_PRE_FIX, value);

    currencyPrefix = value;
  }

  @action
  Future<void> setBaseUrl(String value, {bool initialize = false}) async {
    if (initialize) setValue(SAVE_BASE_URL, value);
    log("Current Base Url :  $value");
    tempBaseUrl = value;
  }

  @action
  Future<void> setUserProEnabled(bool value, {bool initialize = false}) async {
    if (initialize) setValue(USER_PRO_ENABLED, value);

    userProEnabled = value;
  }

  Future<void> setGlobalDateFormat(String value, {bool initialize = false}) async {
    if (initialize) setValue(GLOBAL_DATE_FORMAT, value);

    globalDateFormat = value;
  }

  @action
  Future<void> setLanguage(String val, {BuildContext? context}) async {
    selectedLanguageCode = val;
    locale = await AppLocalizations().load(Locale(selectedLanguageCode));
    localeLanguageList = languageList();
    await setValue(SELECTED_LANGUAGE_CODE, selectedLanguageCode);
    selectedLanguageDataModel = getSelectedLanguageModel();
    await setValue(AppKeys.appLanguageCodeKey, selectedLanguageDataModel!.fullLanguageCode);
  }

  @action
  void setStatus(String aStatus) => mStatus = aStatus;

  @action
  Future<void> setPlayerId(String val, {bool isInitializing = false}) async {
    playerId = val;
    if (!isInitializing) await setValue(PLAYER_ID, val);
  }

  Future<void> setWcNonce(String val) async {
    wcNonce = val;
    await setValue(ApiHeaders.wcNonceKey, '$val');
  }

  @action
  void setLocationPermission(bool val) {
    isLocationEnabled = val;
    setValue(AppKeys.hasLocationPermissionKey, isLocationEnabled);
  }
}
