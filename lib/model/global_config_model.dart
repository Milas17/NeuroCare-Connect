class ModuleConfig {
  String? name;
  String? label;
  String? status;

  ModuleConfig({this.name, this.label, this.status});

  factory ModuleConfig.fromJson(Map<String, dynamic> json) {
    return ModuleConfig(
      name: json['name'],
      label: json['label'],
      status: json['status'],
    );
  }
}

class EncounterModule {
  String? name;
  String? label;
  String? status;

  EncounterModule({this.name, this.label, this.status});

  factory EncounterModule.fromJson(Map<String, dynamic> json) {
    return EncounterModule(
      name: json['name'],
      label: json['label'],
      status: json['status'],
    );
  }
}

class PrescriptionModule {
  String? name;
  String? label;
  String? status;

  PrescriptionModule({this.name, this.label, this.status});

  factory PrescriptionModule.fromJson(Map<String, dynamic> json) {
    return PrescriptionModule(
      name: json['name'],
      label: json['label'],
      status: json['status'],
    );
  }
}

class PaymentMethods {
  String? paymentOffline;
  String? paymentWoocommerce;
  String? paymentRazorpay;

  String? paymentStripePay;

  PaymentMethods({
    this.paymentOffline,
    this.paymentRazorpay,
    this.paymentWoocommerce,
    this.paymentStripePay,
  });

  PaymentMethods.fromJson(dynamic json) {
    paymentOffline = json['paymentOffline'];
    paymentWoocommerce = json['paymentWoocommerce'];
    paymentRazorpay = json['paymentRazorpay'];
    paymentStripePay = json['paymentStripepay'];
  }
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['paymentOffline'] = this.paymentOffline;
    json['paymentWoocommerce'] = this.paymentWoocommerce;
    json['paymentRazorpay'] = this.paymentRazorpay;
    json['paymentStripePay'] = this.paymentStripePay;
    return json;
  }
}

class GetConfigurationModel {
  String? globalDateFormat;
  String? wcCurrencyPrefix;
  String? wcCurrencyPostfix;
  String? defaultCountryCode;
  bool? enableEncounterEditAfterCloseStatus;
  List<EncounterModule>? encounterModules;
  List<PrescriptionModule>? prescriptionModule;
  List<ModuleConfig>? moduleConfig;
  String? utc;
  String? isUploadFileAppointment;
  bool? isTeleMedActive;
  bool? isKiviCareProOnName;
  bool? isKiviCareGoogleMeetActive;
  String? telemedType;
  PaymentMethods? paymentMethod;

  GetConfigurationModel({
    this.globalDateFormat,
    this.wcCurrencyPrefix,
    this.wcCurrencyPostfix,
    this.defaultCountryCode,
    this.enableEncounterEditAfterCloseStatus,
    this.encounterModules,
    this.prescriptionModule,
    this.moduleConfig,
    this.utc,
    this.isUploadFileAppointment,
    this.isTeleMedActive,
    this.isKiviCareProOnName,
    this.isKiviCareGoogleMeetActive,
    this.telemedType,
    this.paymentMethod,
  });

  factory GetConfigurationModel.fromJson(Map<String, dynamic> json) {
    return GetConfigurationModel(
      globalDateFormat: json['globel_date_format'],
      wcCurrencyPrefix: json['wc_currency_prefix'],
      wcCurrencyPostfix: json['wc_currency_postfix'],
      defaultCountryCode: json['default_country_code'],
      enableEncounterEditAfterCloseStatus: json['enable_encounter_edit_after_close_status'],
      encounterModules: ((json['enocunter_modules'] ?? json['encounter_modules']) as List?)?.map((e) => EncounterModule.fromJson(e)).toList(),
      prescriptionModule: (json['prescription_module'] as List?)?.map((e) => PrescriptionModule.fromJson(e)).toList(),
      moduleConfig: (json['module_config'] as List?)?.map((e) => ModuleConfig.fromJson(e)).toList(),
      paymentMethod: json['payment_methods'] != null ? PaymentMethods.fromJson(json['payment_methods']) : null,
      utc: json['utc'],
      isUploadFileAppointment: json['is_uploadfile_appointment'],
      isTeleMedActive: json['isTeleMedActive'],
      isKiviCareProOnName: json['isKiviCareProOnName'],
      isKiviCareGoogleMeetActive: json['isKiviCareGooglemeetActive'],
      telemedType: json['telemed_type'],
    );
  }
}
