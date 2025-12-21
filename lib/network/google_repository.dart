import 'dart:async';

import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/base_response.dart';
import 'package:kivicare_flutter/model/configuration_model.dart';
import 'package:kivicare_flutter/model/global_config_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

//region configuration

StreamController configurationController = StreamController.broadcast();

Future<void> getConfigurationAPI() async {
  ConfigurationModel value = ConfigurationModel.fromJson(await (handleResponse(await buildHttpResponse(ApiEndPoints.getConfigurationEndPoint))));

  userStore.setTermsAndCondition(value.termsEndCondition.validate());
  appStore.setRestrictAppointmentPost(value.restrictAppointment!.post.validate(value: 365), initialize: true);
  appStore.setRestrictAppointmentPre(value.restrictAppointment!.pre.validate(), initialize: true);
  appStore.setWcNonce(value.nonce.validate());
  appStore.setWcCurrency(value.wcCurrency.validate());
}

//endregion

Future<void> getGlobalConfigurationAPI() async {
  try {
    var res = await buildHttpResponse(ApiEndPoints.globalConfigurationEndPoint);
    GetConfigurationModel value = GetConfigurationModel.fromJson(await handleResponse(res));

    // Example store values
    appStore.setGlobalDateFormat(value.globalDateFormat ?? "yyyy-MM-dd", initialize: true);
    appStore.setWcCurrency(value.wcCurrencyPrefix ?? "");
    appStore.setGlobalUTC(value.utc ?? "+00:00");

    appStore.setTeleMedEnabled(value.isTeleMedActive ?? false);
    appStore.setUserProEnabled(value.isKiviCareProOnName ?? false, initialize: true);
    appStore.setGoogleMeetEnabled(value.isKiviCareGoogleMeetActive ?? false);
    appStore.setEnableEncounterEditAfterCloseStatus(value.enableEncounterEditAfterCloseStatus ?? false);

    // Encounter modules
    if (value.encounterModules != null) {
      for (var element in value.encounterModules!) {
        log("Encounter Module: ${element.name} => Status: ${element.status}");
        if (element.name == 'problem') {
          appStore.setProblem(element.status == "1");
        } else if (element.name == 'observation') {
          appStore.setObservation(element.status == "1");
        } else if (element.name == 'note') {
          appStore.setNote(element.status == "1");
        }
      }
    }

    // Prescription modules
    if (value.prescriptionModule != null) {
      for (var element in value.prescriptionModule!) {
        log("Prescription Module: ${element.name} => Status: ${element.status}");
        if (element.name == 'prescription') {
          appStore.setPrescription(element.status == "1");
        }
      }
    }

    if (value.moduleConfig != null) {
      for (var element in value.moduleConfig!) {
        log("Module Config: ${element.name} => Status: ${element.status}");
        if (element.name == 'receptionist') {
          appStore.setReceptionistEnabled(element.status == "1");
        } else if (element.name == 'billing') {
          appStore.setbilling(element.status == "1");
        }
      }
    }

    if (value.paymentMethod != null) {
      setValue(SharedPreferenceKey.paymentMethodsKey, value.paymentMethod!.toJson());
      paymentMethodList.clear();
      paymentMethodImages.clear();
      paymentModeList.clear();

      if (value.paymentMethod!.paymentRazorpay.validate().isNotEmpty) {
        appStore.setRazorPay(true);
        appStore.setRazorPayMethod(value.paymentMethod!.paymentRazorpay.validate());
        paymentMethodList.add(appStore.paymentRazorpay);
        paymentMethodImages.add(ic_razorpay);
        paymentModeList.add(PAYMENT_RAZORPAY);
      }
      if (value.paymentMethod!.paymentStripePay.validate().isNotEmpty) {
        appStore.setStripePay(true);
        appStore.setStripePayMethod(value.paymentMethod!.paymentStripePay.validate());
        paymentMethodList.add(appStore.paymentStripe);
        paymentMethodImages.add(ic_stripePay);
        paymentModeList.add(PAYMENT_STRIPE);
      }
      if (value.paymentMethod!.paymentWoocommerce.validate().isNotEmpty) {
        appStore.setWoocommerce(true);
        appStore.setWoocommerceMethod(value.paymentMethod!.paymentWoocommerce.validate());
        paymentMethodList.add(appStore.paymentWoocommerce);
        paymentMethodImages.add(ic_wooCommerce);
        paymentModeList.add(PAYMENT_WOOCOMMERCE);
      }
      if (value.paymentMethod!.paymentOffline.validate().isNotEmpty) {
        appStore.setOffLinePayment(true);
        appStore.setOffLinePaymentMethod(value.paymentMethod!.paymentOffline.validate());
        paymentMethodList.add(appStore.paymentOffline);
        paymentMethodImages.add(ic_payOffline);
        paymentModeList.add(PAYMENT_OFFLINE);
      }
    }

    configurationController.add(value);
  } catch (e) {
    log("Error in getGlobalConfigurationAPI: $e");
    configurationController.addError(e);
  }
}

//region configuration

Future<ApiResponses> saveLanguageApi({required String languageCode}) async {
  Map<String, dynamic> request = {"locale": languageCode};

  ApiResponses responses = ApiResponses.fromJson(await (handleResponse(await buildHttpResponse(
    "${ApiEndPoints.userEndpoint}/${EndPointKeys.switchLanguageKey}",
    request: request,
    method: HttpMethod.POST,
  ))));
  return responses;
}
//endregion
