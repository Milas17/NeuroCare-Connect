import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/pages/fulleditprofilepage.dart';
import 'package:yourappname/pages/login_verficiation_success_screen.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:pinput/pinput.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class OTP extends StatefulWidget {
  final String? mobilenumber,
      verificationId,
      countrycode,
      countryName,
      mobileNo;
  final int forceResendingToken;
  const OTP({
    super.key,
    required this.mobilenumber,
    required this.mobileNo,
    required this.countryName,
    required this.countrycode,
    required this.verificationId,
    required this.forceResendingToken,
  });

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  SharedPre sharedPre = SharedPre();
  final pinPutController = TextEditingController();
  dynamic strDeviceToken;
  String? platformType;
  late ProgressDialog prDialog;
  int resendToken = 0;
  String? verificationId;
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _showResend = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String resendOtpText = '';
  String resendNow = '';

  @override
  void initState() {
    resendToken = widget.forceResendingToken;
    verificationId = widget.verificationId;
    printLog("mobileNumber == ${widget.mobilenumber}");
    super.initState();
    prDialog = ProgressDialog(context);
    _startTimer();
    if (Constant.isDemo == "1") {
      pinPutController.text = "123456";
    }
    _getDeviceToken();
  }

  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _showResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _showResend = true;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(1, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$minutes:$secs";
  }

  _getDeviceToken() async {
    strDeviceToken = OneSignal.User.pushSubscription.id;
    if (Platform.isAndroid) {
      platformType = "1";
    } else {
      platformType = "2";
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>deviceType $platformType");
  }

  @override
  void dispose() {
    FocusManager.instance.primaryFocus?.unfocus();
    pinPutController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, Constant.appName, false, true),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                color: colorPrimary,
                text: "phone_verifications",
                fontsize: Dimens.text24Size,
                multilanguage: true,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.w600,
              ),
              const SizedBox(height: 10),
              MyText(
                color: black,
                text: "enter_4_digit_code",
                fontsize: Dimens.text14Size,
                multilanguage: true,
                maxline: 2,
                overflow: TextOverflow.ellipsis,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.w400,
              ),
              const SizedBox(height: 33),
              Pinput(
                length: 6,
                keyboardType: TextInputType.number,
                controller: pinPutController,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                defaultPinTheme: PinTheme(
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                          color: grayLight,
                          spreadRadius: 0.1,
                          blurRadius: 10,
                          blurStyle: BlurStyle.normal,
                          offset: Offset(0, 1))
                    ],
                    color: white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: Utils.googleFontStyle(1, 16, FontStyle.normal,
                      colorPrimaryDark, FontWeight.w500),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: _showResend
                    ? InkWell(
                        onTap: () async {
                          Utils.showProgress(context, prDialog);

                          await resendOtp(
                            phoneNumber:
                                "${widget.countrycode}${widget.mobileNo}",
                          );
                        },
                        child: MyText(
                          color: colorPrimaryDark,
                          text: "resend_now",
                          fontsize: Dimens.text18Size,
                          fontweight: FontWeight.w600,
                          multilanguage: true,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          textalign: TextAlign.center,
                          fontstyle: FontStyle.normal,
                        ),
                      )
                    : MyText(
                        color: colorPrimaryDark,
                        text:
                            "${"resend_otp"} in ${_formatTime(_remainingSeconds)}",
                        fontsize: Dimens.text18Size,
                        fontweight: FontWeight.w600,
                        multilanguage: false,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
              ),
              const SizedBox(height: 40),
              InkWell(
                onTap: () {
                  if (pinPutController.text.toString().isEmpty) {
                    Utils.showSnackbar(context, "pleaseenterotp", true);
                  } else {
                    if (widget.verificationId == null ||
                        widget.verificationId == "") {
                      Utils.showSnackbar(context, "otp_not_working", true);
                      return;
                    }
                    Utils.showProgress(context, prDialog);
                    _checkOTPAndLogin();
                  }
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [colorPrimaryDark, colorPrimaryDark],
                      end: Alignment.topRight,
                      begin: Alignment.topLeft,
                    ),
                  ),
                  child: MyText(
                    color: white,
                    text: "continue",
                    fontsize: Dimens.text18Size,
                    fontweight: FontWeight.w600,
                    multilanguage: true,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget backbutton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        // child: Utils.backButton(),
      ),
    );
  }

  _checkOTPAndLogin() async {
    bool error = false;
    UserCredential? userCredential;

    printLog(
        "_checkOTPAndLogin verificationId =====> ${widget.verificationId}");
    printLog("_checkOTPAndLogin smsCode =====> ${pinPutController.text}");
    // Create a PhoneAuthCredential with the code
    PhoneAuthCredential? phoneAuthCredential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId ?? "",
      smsCode: pinPutController.text.toString(),
    );

    printLog(
        "phoneAuthCredential.smsCode        =====> ${phoneAuthCredential.smsCode}");
    printLog(
        "phoneAuthCredential.verificationId =====> ${phoneAuthCredential.verificationId}");
    try {
      userCredential = await auth.signInWithCredential(phoneAuthCredential);
      printLog(
          "_checkOTPAndLogin userCredential =====> ${userCredential.user?.phoneNumber ?? ""}");
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      prDialog.hide();

      printLog("_checkOTPAndLogin error Code =====> ${e.code}");
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpinvalid", true);
        return;
      } else if (e.code == 'session-expired') {
        if (!mounted) return;
        Utils.showSnackbar(context, "otpsessionexpired", true);
        return;
      } else {
        error = true;
      }
    }
    printLog(
        "Firebase Verification Complated & phoneNumber => ${userCredential?.user?.phoneNumber} and isError => $error");
    if (!error && userCredential != null) {
      /* Update in Firebase */
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.userid,
              isEqualTo: userCredential.user?.uid ?? "")
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      printLog("userCredential uid ==========> ${userCredential.user?.uid}");
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(userCredential.user?.uid ?? "")
            .set({
          FirestoreConstants.email: userCredential.user?.email ?? "",
          FirestoreConstants.pushToken: strDeviceToken,
          FirestoreConstants.name:
              (userCredential.user?.displayName ?? "").isEmpty
                  ? (userCredential.user?.phoneNumber ?? "")
                  : (userCredential.user?.displayName ?? ""),
          FirestoreConstants.profileurl:
              userCredential.user?.photoURL ?? Constant.userPlaceholder,
          FirestoreConstants.userid: userCredential.user?.uid ?? "",
          FirestoreConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.bioData:
              "Hey!!! there I'm using ${Constant.appName} app.",
          FirestoreConstants.username: "",
          FirestoreConstants.mobileNumber:
              userCredential.user?.phoneNumber ?? "",
          FirestoreConstants.chattingWith: null,
        });
      } else {
        updateDataInFirestore(firebasedid: userCredential.user?.uid ?? "");
      }
      _login(widget.mobileNo.toString(),
          userCredential.user?.uid.toString() ?? "");
    } else {
      if (!mounted) return;
      // Utils.hideProgress();
      prDialog.hide();
      Utils.showSnackbar(context, "otploginfail", true);
    }
  }

  _login(String mobile, String firebaseId) async {
    printLog("click on Submit mobile =====> $mobile");
    printLog("click on Submit firebaseId => $firebaseId");
    var generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    Utils.showProgress(context, prDialog);
    try {
      await generalProvider.loginOTPDoctor(
        mobile,
        widget.countrycode.toString(),
        widget.countryName.toString(),
        "1",
        firebaseId,
        platformType.toString(),
        strDeviceToken,
      );
    } catch (e) {
      if (!mounted) return;
      prDialog.hide();

      printLog('loginWithOTP Exception ==>> $e');
      Utils.showSnackbar(context, "server_error", true);
    }

    if (!generalProvider.loading) {
      if (!mounted) return;
      await Utils.updateGeneralSettingData(context, generalProvider);
      prDialog.hide();

      if (generalProvider.loginRegisterModel.status == 200) {
        printLog(
            'loginRegisterModel ==>> ${generalProvider.loginRegisterModel.toString()}');
        printLog('Login Successfull!');
        /* Save Users Credentials */
        await sharedPre.save("userid",
            generalProvider.loginRegisterModel.result?[0].id.toString());
        await sharedPre.save(
            "firebaseid",
            generalProvider.loginRegisterModel.result?[0].firebaseId
                    .toString() ??
                "");
        await sharedPre.save(
            "userfullname",
            generalProvider.loginRegisterModel.result?[0].fullName.toString() ??
                "");
        await sharedPre.save(
            "username",
            generalProvider.loginRegisterModel.result?[0].userName.toString() ??
                "");
        await sharedPre.save(
            "userimage",
            generalProvider.loginRegisterModel.result?[0].profileImg
                    .toString() ??
                "");
        await sharedPre.save(
            "useremail",
            generalProvider.loginRegisterModel.result?[0].email.toString() ??
                "");
        await sharedPre.save(
            "usermobile",
            generalProvider.loginRegisterModel.result?[0].mobileNumber
                    .toString() ??
                "");
        await sharedPre.save(
            "usertype",
            generalProvider.loginRegisterModel.result?[0].type.toString() ??
                "");

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginRegisterModel.result?[0].id.toString();
        printLog('Constant userID ==>> ${Constant.userID}');

        if (!mounted) return;
        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(builder: (context) => const FullEditProfile()),
        //     (Route route) => false);
        if ((generalProvider.loginRegisterModel.result?[0].fullName
                        .toString() ??
                    "")
                .isEmpty ||
            (generalProvider.loginRegisterModel.result?[0].mobileNumber
                        .toString() ??
                    "")
                .isEmpty ||
            (generalProvider.loginRegisterModel.result?[0].email.toString() ??
                    "")
                .isEmpty) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const FullEditProfile()),
              (Route route) => false);
        } else {
          await sharedPre.save("isEdit", "1");
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ResgisterSuccessScreen()),
            // (Route<dynamic> route) => false,
          );
        }
      } else {
        if (!mounted) return;
        prDialog.hide();

        Utils.showSnackbar(
            context, "${generalProvider.loginRegisterModel.message}", false);
      }
    }
  }

  updateDataInFirestore({required String firebasedid}) {
    printLog('strDeviceToken ....==>> $strDeviceToken');
    printLog('firebasedid ....==>> $firebasedid');
    // Update data to Firestore
    FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(firebasedid)
        .update({FirestoreConstants.pushToken: strDeviceToken})
        .then((value) => printLog("User Updated"))
        .onError((error, stackTrace) {
          printLog("updateDataFirestore error ===> ${error.toString()}");
          printLog(
              "updateDataFirestore stackTrace ===> ${stackTrace.toString()}");
        });
  }

  Future<void> resendOtp({
    required String phoneNumber,
  }) async {
    printLog("phoneSignIn called with number: $phoneNumber");
    await _auth.verifyPhoneNumber(
      timeout: const Duration(seconds: 60),
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      verificationCompleted: _onVerificationCompleted,
      verificationFailed: _onVerificationFailed,
      codeSent: _onCodeSent,
      codeAutoRetrievalTimeout: _onCodeTimeout,
    );
    printLog("verifyPhoneNumber executed successfully");
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    printLog("verification completed ======> ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    printLog("user phoneNumber =====> ${user?.phoneNumber}");
  }

  _onVerificationFailed(FirebaseAuthException exception) async {
    if (exception.code == 'invalid-phone-number') {
      printLog("The phone number entered is invalid!");
      Utils.showSnackbar(context, "invalidphonenumberotp", true);
      // await prDialog.hide();
    }
  }

  _onCodeSent(String verificationId, int? forceResendingToken) async {
    this.verificationId = verificationId;
    printLog("verificationId =======> $resendToken");
    resendToken = forceResendingToken ?? 0;

    printLog("resendingToken =======> $resendToken");
    printLog("code sent");
    Utils.showSnackbar(context, "coderesendsuccessfully", true);
  }

  _onCodeTimeout(String verificationId) async {
    printLog("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    await prDialog.hide();

    return null;
  }
}
