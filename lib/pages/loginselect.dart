import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:yourappname/pages/fulleditprofilepage.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/otp.dart';
import 'package:yourappname/pages/registration.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Loginselect extends StatefulWidget {
  const Loginselect({super.key});

  @override
  State<Loginselect> createState() => _LoginselectState();
}

class _LoginselectState extends State<Loginselect> {
  late ProgressDialog prDialog;
  SharedPre sharePref = SharedPre();

  String mobilenumber = "";
  String mobileNo = "";
  final numberController = TextEditingController();
  String countryCode = "+91";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String countryName = "India";
  int? forceResendingToken;
  String? strDeviceToken, platformType;
  late GeneralProvider generalProvider;
  String? verificationId;
  dynamic userEmail, password, type;
  String? firebasedid;

  ValueNotifier<bool> senOtp = ValueNotifier(false);

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    prDialog = ProgressDialog(context);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getDeviceToken();
    });
    if (Constant.isDemo == "1") {
      // numberController.text = "9898989898";
      // mobilenumber = "${countryCode}9898989898";
      // mobileNo = "9898989898";
      numberController.text = "9898989898";
      mobilenumber = "${countryCode}9898989898";
      mobileNo = "9898989898";
    }
  }

  _getDeviceToken() async {
    await pushNotification();

    strDeviceToken = OneSignal.User.pushSubscription.id;
    if (Platform.isAndroid) {
      platformType = "1";
    } else {
      platformType = "2";
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>deviceType $platformType");
  }

  Future<void> pushNotification() async {
    /* Notification Code */
    /*  Push Notification Method OneSignal Start */
    if (!kIsWeb) {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      // Initialize OneSignal
      OneSignal.initialize(Constant.oneSignalAppId ?? "");
      await OneSignal.Notifications.requestPermission(true);
      OneSignal.Notifications.addPermissionObserver((state) {
        debugPrint("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        debugPrint(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.preventDefault();

        /// notification.display() to display after preventing default
        event.notification.display();
      });
    }
    /*  Push Notification Method OneSignal End */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          MyImage(
            imagePath: "login_bgprofile.png",
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: IntrinsicHeight(
              child: Container(
                // height: 590,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: colorAccent.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30))),
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  decoration: BoxDecoration(
                      color: white, borderRadius: BorderRadius.circular(30)),
                  child: Column(
                    children: [
                      MyText(
                        text: Constant.appName,
                        fontsize: Dimens.text28Size,
                        color: black,
                        fontweight: FontWeight.w700,
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      MyText(
                        textalign: TextAlign.center,
                        text: "dtcare_health_message",
                        fontsize: Dimens.text13Size,
                        color: black,
                        fontweight: FontWeight.w600,
                        multilanguage: true,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      normallogin(),
                      const SizedBox(
                        height: 20,
                      ),
                      ValueListenableBuilder(
                        valueListenable: senOtp,
                        builder: (context, showLoader, child) => InkWell(
                          onTap: () {
                            if (showLoader) {
                              return;
                            }
                            if (numberController.text.toString().isEmpty) {
                              Utils.showSnackbar(
                                  context, "entermobilenumber", true);
                              return;
                            }

                            codeSend();
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            padding: showLoader
                                ? const EdgeInsets.fromLTRB(30, 8, 30, 8)
                                : const EdgeInsets.fromLTRB(30, 15, 30, 15),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: colorPrimaryDark,
                                borderRadius: BorderRadius.circular(8)),
                            child: showLoader
                                ? const CircularProgressIndicator(
                                    color: white,
                                  )
                                : MyText(
                                    text: "send_otp",
                                    fontsize: Dimens.text15Size,
                                    multilanguage: true,
                                    color: white,
                                    fontweight: FontWeight.w600,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 2,
                              color: gray.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          MyText(
                            text: "or",
                            multilanguage: true,
                            fontsize: Dimens.text14Size,
                            fontweight: FontWeight.w500,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: gray.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => const Registration()));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
                          decoration: BoxDecoration(
                              color: colorPrimaryDark,
                              borderRadius: BorderRadius.circular(8)),
                          child: MyText(
                            text: "create_account",
                            fontsize: Dimens.text15Size,
                            multilanguage: true,
                            color: white,
                            fontweight: FontWeight.w600,
                          ),
                        ),
                      ),
                      // const SizedBox(height: 20),
                      // socialLogin(),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText(
                            text: "already_have_account",
                            fontsize: Dimens.text15Size,
                            multilanguage: true,
                            color: black.withValues(alpha: 0.6),
                            fontweight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const Login();
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
                              color: transparent,
                              child: MyText(
                                text: "signin",
                                fontsize: Dimens.text15Size,
                                multilanguage: true,
                                color: colorPrimaryDark,
                                fontweight: FontWeight.w500,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Widget socialLogin() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: InkWell(
  //           onTap: () {
  //             _gmailLogin();
  //           },
  //           child: Container(
  //             padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
  //             decoration: BoxDecoration(
  //                 borderRadius: BorderRadius.circular(8),
  //                 border: Border.all(
  //                     color: black.withValues(alpha: 0.2), width: 0.5)),
  //             child: MyImage(
  //               imagePath: "ic_google.png",
  //               height: 25,
  //               width: 25,
  //             ),
  //           ),
  //         ),
  //       ),
  //       Platform.isIOS ? const SizedBox(width: 20) : const SizedBox.shrink(),
  //       Platform.isIOS
  //           ? Expanded(
  //               child: InkWell(
  //                 onTap: () {
  //                   signInWithApple();
  //                 },
  //                 child: Container(
  //                     padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
  //                     decoration: BoxDecoration(
  //                         borderRadius: BorderRadius.circular(8),
  //                         border: Border.all(
  //                             color: black.withValues(alpha: 0.2), width: 0.5)),
  //                     child: const Icon(
  //                       Icons.apple,
  //                       color: black,
  //                       size: 35,
  //                     )),
  //               ),
  //             )
  //           : const SizedBox.shrink(),
  //     ],
  //   );
  // }

  codeSend() async {
    senOtp.value = true;
    printLog("mobilenumber ==$mobilenumber");
    // Utils.showProgress(context, prDialog);
    await phoneSignIn(phoneNumber: mobilenumber);
    // if (!mounted) return;
    // await prDialog.hide();
  }

  Future<void> phoneSignIn({required String phoneNumber}) async {
    printLog("phoneSignIn called with number: $phoneNumber");
    try {
      forceResendingToken = null;
      await _auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: phoneNumber,
        forceResendingToken: forceResendingToken,
        verificationCompleted: (PhoneAuthCredential authCredential) {
          printLog("Verification completed: ${authCredential.smsCode}");
          _onVerificationCompleted(authCredential);
        },
        verificationFailed: (FirebaseAuthException exception) {
          printLog(
              "Verification failed: ${exception.code} - ${exception.message}");
          _onVerificationFailed(exception);
          senOtp.value = false;
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          printLog("Code sent: verificationId=$verificationId");
          _onCodeSent(verificationId, forceResendingToken);
          senOtp.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          printLog("Auto retrieval timeout: $verificationId");
          _onCodeTimeout(verificationId);
          senOtp.value = false;
        },
      );
      printLog("verifyPhoneNumber executed successfully");
    } catch (e) {
      printLog("Error in phoneSignIn: $e");
      senOtp.value = false;
    }
  }

  _onVerificationCompleted(PhoneAuthCredential authCredential) async {
    printLog("verification completed ======> ${authCredential.smsCode}");
    User? user = FirebaseAuth.instance.currentUser;
    printLog("user phoneNumber =====> ${user?.phoneNumber}");
  }

  _onVerificationFailed(FirebaseAuthException exception) {
    if (!mounted) return;
    if (exception.code == 'invalid-phone-number') {
      printLog("The phone number entered is invalid!");
      Utils.showSnackbar(context, "invalidphonenumberotp", true);
    }
    // prDialog.hide();
  }

  _onCodeSent(String verificationId, int? forceResendingToken) {
    this.verificationId = verificationId;
    this.forceResendingToken = forceResendingToken;
    printLog("verificationId =======> $verificationId");
    printLog("resendingToken =======> ${forceResendingToken.toString()}");
    printLog("code sent");
    Utils.showSnackbar(context, "codesuccessfullysent", true);

    // await prDialog.hide();
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OTP(
          mobileNo: mobileNo,
          verificationId: verificationId,
          mobilenumber: mobilenumber,
          countrycode: countryCode.toString(),
          countryName: countryName.toString(),
          forceResendingToken: forceResendingToken ?? 0,
        ),
      ),
    );
  }

  _onCodeTimeout(String verificationId) {
    printLog("_onCodeTimeout verificationId =======> $verificationId");
    this.verificationId = verificationId;
    prDialog.hide();

    return null;
  }

  Widget normallogin() {
    return SizedBox(
      height: 55,
      child: IntlPhoneField(
        disableLengthCheck: true,
        textAlignVertical: TextAlignVertical.center,
        autovalidateMode: AutovalidateMode.disabled,
        controller: numberController,
        style: Utils.googleFontStyle(
            1, 16, FontStyle.normal, black, FontWeight.w500),
        showCountryFlag: false,
        showDropdownIcon: false,
        initialCountryCode: "IN",
        dropdownTextStyle: Utils.googleFontStyle(
            1, 16, FontStyle.normal, black, FontWeight.w500),
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          filled: true,
          fillColor: white,
          border: InputBorder.none,
          labelStyle: Utils.googleFontStyle(
            1,
            14,
            FontStyle.normal,
            black,
            FontWeight.w500,
          ),
          labelText: Locales.string(context, "enteryourmobilenumber"),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(color: black, width: 1),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(7.0)),
            borderSide: BorderSide(color: black, width: 1),
          ),
        ),
        onChanged: (phone) {
          printLog('phone===> ${phone.completeNumber}');
          printLog('number===> ${numberController.text}');
          mobilenumber = phone.completeNumber;
          mobileNo = phone.number;
          printLog('mobile number===>mobileNumber $mobilenumber');
        },
        onCountryChanged: (country) {
          countryCode = "+${country.dialCode.toString()}";
          countryName = country.name.toString();
          printLog('countrycode===> $countryCode');
        },
      ),
    );
  }

  /* Google(Gmail) Login */
  // Future<void> _gmailLogin() async {
  //   await GoogleSignIn.instance.initialize(
  //       serverClientId:
  //           "997133946428-0hnk7iqrfhn6ko2lpcv1edgkeqfg5n8k.apps.googleusercontent.com");
  //   final googleUser = await GoogleSignIn.instance.authenticate();

  //   GoogleSignInAccount user = googleUser;

  //   printLog('GoogleSignIn ===> id : ${user.id}');
  //   printLog('GoogleSignIn ===> displayName : ${user.displayName}');
  //   printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');

  //   userEmail = user.email.toString();
  //   printLog('GoogleSignIn ===> email : $userEmail');

  //   if (!mounted) return;
  //   Utils.showProgress(context, prDialog);

  //   UserCredential userCredential;
  //   try {
  //     GoogleSignInAuthentication googleSignInAuthentication =
  //         user.authentication;
  //     AuthCredential credential = GoogleAuthProvider.credential(
  //       // accessToken: googleSignInAuthentication.,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     userCredential = await _auth.signInWithCredential(credential);
  //     assert(await userCredential.user?.getIdToken() != null);
  //     printLog("User Name: ${user.displayName}");
  //     printLog("User Email ${user.email}");
  //     printLog("User photoUrl ${user.photoUrl}");
  //     printLog("uid ===> ${userCredential.user?.uid}");
  //     String firebasedid = userCredential.user?.uid ?? "";
  //     printLog('firebasedid :===> $firebasedid');

  //     /* Update in Firebase */
  //     // Check is already sign up
  //     final QuerySnapshot result = await FirebaseFirestore.instance
  //         .collection(FirestoreConstants.pathUserCollection)
  //         .where(FirestoreConstants.userid,
  //             isEqualTo: userCredential.user?.uid ?? "")
  //         .get();
  //     final List<DocumentSnapshot> documents = result.docs;
  //     if (documents.isEmpty) {
  //       // Writing data to server because here is a new user
  //       FirebaseFirestore.instance
  //           .collection(FirestoreConstants.pathUserCollection)
  //           .doc(userCredential.user?.uid ?? "")
  //           .set({
  //         FirestoreConstants.email: userEmail,
  //         FirestoreConstants.name: user.displayName,
  //         FirestoreConstants.profileurl: user.photoUrl,
  //         FirestoreConstants.userid: userCredential.user?.uid ?? "",
  //         FirestoreConstants.createdAt:
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //         FirestoreConstants.bioData:
  //             "Hey! there I'm using ${Constant.appName} app.",
  //         FirestoreConstants.username: user.displayName,
  //         FirestoreConstants.mobileNumber:
  //             userCredential.user?.phoneNumber ?? "",
  //         FirestoreConstants.chattingWith: null,
  //         FirestoreConstants.pushToken: strDeviceToken
  //       });
  //     } else {
  //       updateDataInFirestore(firebasedid: firebasedid);
  //     }

  //     // login API call
  //     if (!mounted) return;
  //     Utils.showProgress(context, prDialog);

  //     try {
  //       await generalProvider.loginDoctorSocial(
  //           userEmail, "2", firebasedid, strDeviceToken);
  //     } on Exception catch (e) {
  //       prDialog.hide();
  //       printLog("loginPatient Exception =====> $e");
  //     }

  //     checkAndNavigate("2");
  //   } on FirebaseAuthException catch (e) {
  //     printLog('FirebaseAuthException ===CODE====> ${e.code.toString()}');
  //     printLog('FirebaseAuthException ==MESSAGE==> ${e.message.toString()}');
  //     // Hide Progress Dialog
  //     prDialog.hide();
  //   }
  // }

  /* Apple Login */
  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    try {
      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      printLog(appleCredential.authorizationCode);

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      if (!mounted) return;
      Utils.showProgress(context, prDialog);

      // Sign in the user with Firebase. If the nonce we generated earlier does
      // not match the nonce in `appleCredential.identityToken`, sign in will fail.
      final authResult = await _auth.signInWithCredential(oauthCredential);

      /* *********************************** */
      String? displayName;

      final firebaseUser = authResult.user;

      // dynamic firebasedId;
      if (appleCredential.givenName != null) {
        displayName =
            '${appleCredential.givenName} ${appleCredential.familyName}';
        userEmail = authResult.user?.email.toString() ?? "";

        await firebaseUser?.updateDisplayName(displayName);
        // await firebaseUser?.updateEmail(userEmail);

        printLog("===>userEmail $userEmail");
        printLog("===>displayName $displayName");
      } else {
        userEmail = firebaseUser?.email.toString() ?? "";
        firebasedid = firebaseUser?.uid.toString();
        displayName = firebaseUser?.displayName.toString();

        printLog("===>userEmail-else $userEmail");
        printLog("===>displayName-else $displayName");
      }
      printLog("userEmail =====FINAL==> $userEmail");
      printLog("firebasedId ===FINAL==> $firebasedid");
      printLog("displayName ===FINAL==> $displayName");
      /*  ************************************/

      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.userid, isEqualTo: firebasedid)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebasedid)
            .set({
          FirestoreConstants.email: firebaseUser?.email ?? "",
          FirestoreConstants.name: displayName ?? "",
          FirestoreConstants.profileurl:
              firebaseUser?.photoURL ?? Constant.userPlaceholder,
          FirestoreConstants.userid: firebasedid,
          FirestoreConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.bioData:
              "Hey! there I'm using ${Constant.appName} app.",
          FirestoreConstants.username: "",
          FirestoreConstants.mobileNumber: firebaseUser?.phoneNumber ?? "",
          FirestoreConstants.chattingWith: null,
          FirestoreConstants.pushToken: strDeviceToken
        });
      } else {
        updateDataInFirestore(firebasedid: firebasedid ?? "");
      }

      // login API call
      if (!mounted) return;
      Utils.showProgress(context, prDialog);

      try {
        await generalProvider.loginDoctorSocial(
            userEmail, "3", firebasedid, strDeviceToken);
      } on Exception catch (e) {
        prDialog.hide();
        printLog("loginPatient Exception =====> $e");
      }

      checkAndNavigate("3");
    } catch (exception) {
      printLog("Apple Login exception =====> $exception");
    }
  }

  Future<User?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      printLog('signInWithEmailAndPassword Error: $e');
      return null;
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

  checkAndNavigate(type) async {
    printLog('firebasedid :===> $firebasedid');
    printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');
    if (!generalProvider.loading) {
      // Hide Progress Dialog
      prDialog.hide();

      if (generalProvider.loginRegisterModel.status == 200) {
        printLog(
            'loginRegisterModel ==>> ${generalProvider.loginRegisterModel.toString()}');
        printLog('Login Successfull!');
        await Utils.saveUserCreds(
          userID: generalProvider.loginRegisterModel.result?[0].id.toString(),
          userName:
              generalProvider.loginRegisterModel.result?[0].fullName.toString(),
          userEmail:
              generalProvider.loginRegisterModel.result?[0].email.toString(),
          userMobile: generalProvider.loginRegisterModel.result?[0].mobileNumber
              .toString(),
          userImage: generalProvider.loginRegisterModel.result?[0].profileImg
              .toString(),
          userType:
              generalProvider.loginRegisterModel.result?[0].type.toString(),
          userFirebaseId: generalProvider
              .loginRegisterModel.result?[0].firebaseId
              .toString(),
          userPremium: "",
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginRegisterModel.result?[0].id.toString();

        printLog('Constant userID ==>> ${Constant.userID}');
        printLog(
            'deviceToken ==>> ${generalProvider.loginRegisterModel.result?[0].deviceToken}');
        printLog(
            'firebaseId ==>> ${generalProvider.loginRegisterModel.result?[0].firebaseId}');

        if (!mounted) return;
        if (type == "4") {
          await sharePref.save("isEdit", "1");
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const BottomBar()),
            (Route<dynamic> route) => false,
          );
        } else {
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
                MaterialPageRoute(
                    builder: (context) => const FullEditProfile()),
                (Route route) => false);
          } else {
            await sharePref.save("isEdit", "1");
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const BottomBar()),
              (Route<dynamic> route) => false,
            );
          }
        }
        // }
      } else {
        Utils.showToast("${generalProvider.loginRegisterModel.message}");
      }
    }
  }
}
