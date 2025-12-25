import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/forgotpassword.dart';
import 'package:yourappname/pages/fulleditprofilepage.dart';
import 'package:yourappname/pages/registration.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/customtextformfield.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/mytextformfield.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late ProgressDialog prDialog;
  SharedPre sharePref = SharedPre();
  final _formKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final mEmailController = TextEditingController();
  final mPasswordController = TextEditingController();
  dynamic userEmail, password, type, deviceToken;
  late GeneralProvider generalProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  UserCredential? userCredential;
  String firebasedid = "";
  bool? check = false;
  String? strDeviceToken, strDeviceType = "", strPrivacyAndTNC;

  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  bool initialized = false;

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _passwordVisible = true;
    prDialog = ProgressDialog(context);
    _getDeviceToken();
    _getData();
    super.initState();
  }

  _getDeviceToken() async {
    strDeviceToken = OneSignal.User.pushSubscription.id;
    if (Platform.isAndroid) {
      strDeviceType = "1";
    } else {
      strDeviceType = "2";
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>deviceType $strDeviceType");
  }

  _getData() async {
    String? privacyUrl, termsConditionUrl;
    await generalProvider.getPages();
    if (!generalProvider.loading) {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null) {
        if ((generalProvider.pagesModel.result?.length ?? 0) > 0) {
          for (var i = 0;
              i < (generalProvider.pagesModel.result?.length ?? 0);
              i++) {
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("privacy")) {
              privacyUrl = generalProvider.pagesModel.result?[i].url;
            }
            if ((generalProvider.pagesModel.result?[i].pageName ?? "")
                .toLowerCase()
                .contains("terms")) {
              termsConditionUrl = generalProvider.pagesModel.result?[i].url;
            }
          }
        }
      }
    }
    printLog('privacyUrl ==> $privacyUrl');
    printLog('termsConditionUrl ==> $termsConditionUrl');

    strPrivacyAndTNC = await Utils.getPrivacyTandCText(
      privacyUrl: privacyUrl ?? "",
      termsConditionUrl: termsConditionUrl ?? "",
    );
    printLog('strPrivacyAndTNC ==> $strPrivacyAndTNC');
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      generalProvider.notifyListener();
    });
  }

  @override
  void dispose() {
    mEmailController.dispose();
    mPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GeneralProvider>(
        builder: (context, generalProvider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        appBar: Utils.myAppBarWithBack(context, "login", true, true),
        body: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(left: 20, top: 15, right: 20),
                  alignment: Alignment.centerLeft,
                  child: MyText(
                    text: "welcome",
                    multilanguage: true,
                    color: textTitleColor,
                    textalign: TextAlign.start,
                    fontweight: FontWeight.w800,
                    fontsize: Dimens.text25Size,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: MyText(
                      text: "put_information",
                      multilanguage: true,
                      color: black.withValues(alpha: 0.8),
                      fontsize: Dimens.text14Size,
                      fontstyle: FontStyle.normal,
                      fontweight: FontWeight.w500,
                      textalign: TextAlign.left,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        MyTextFormField(
                          mHint: emailAddressReq,
                          mController: mEmailController,
                          mObscureText: false,
                          mMaxLine: 1,
                          mHintTextColor: black,
                          mTextColor: black,
                          mkeyboardType: TextInputType.emailAddress,
                          mTextInputAction: TextInputAction.next,
                          mInputBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4)),
                        ),
                        const SizedBox(height: 20),
                        CustomTextFormField(
                          readOnly: false,
                          controller: mPasswordController,
                          labelText: passwordReq,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _passwordVisible,
                          suffixIcon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: otherColor,
                          ),
                          onSuffixIconPressed: () {
                            _passwordVisible = !_passwordVisible;
                            generalProvider.notifyListener();
                          },
                        ),

                        /* Privacy & TermsCondition link */
                        // if (strPrivacyAndTNC != null)
                        Container(
                          margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                          child: Row(
                            children: [
                              Checkbox(
                                activeColor: colorPrimaryDark,
                                value: check,
                                onChanged: (value) {
                                  check = value;
                                  generalProvider.notifyListener();
                                },
                              ),
                              Expanded(
                                child: MyText(
                                  text:
                                      "By continuing, I understand and agree with Privacy Policy and Terms and Conditions of yourappname.",
                                  fontsize: Dimens.text14Size,
                                  color: grayDark,
                                  fontweight: FontWeight.w500,
                                  maxline: 3,
                                ),
                              )
                              // Expanded(
                              //     child: Utils.htmlTexts(strPrivacyAndTNC)),
                            ],
                          ),
                        ),
                        loginButton(),
                        const SizedBox(height: 10),
                        forgotPassClick(),
                        const SizedBox(height: 10),
                        socialLogin(),
                      ],
                    ),
                  ),
                ),
                goToRegistration(),
              ],
            ),
          ),
        ),
      );
    });
  }

  clearTextFormField() {
    mEmailController.clear();
    mPasswordController.clear();
  }

  // Widget loginButton() {
  //   return InkWell(
  //     focusColor: colorPrimary,
  //     onTap: () {
  //       if (check == false) {
  //         Utils.showSnackbar(
  //           context,
  //           "Please agree the conditions", false
  //         );
  //       } else {
  //         validateFormData();
  //       }
  //     },
  //     child: Container(
  //       width: MediaQuery.of(context).size.width * 0.55,
  //       height: Constant.buttonHeight,
  //       decoration: Utils.primaryDarkButton(),
  //       alignment: Alignment.center,
  //       child: MyText(
  //         text: "login",
  //         multilanguage: true,
  //         color: white,
  //         textalign: TextAlign.center,
  //         fontsize: Dimens.text16Size,
  //         fontweight: FontWeight.w600,
  //       ),
  //     ),
  //   );
  // }

  Widget loginButton() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        if (check == false) {
          Utils.showSnackbar(context, "pleasetickthecondition", true);
        } else {
          validateFormData();
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: Dimens.buttonHeight,
        decoration: BoxDecoration(
          color: colorPrimaryDark,
          borderRadius: BorderRadius.circular(8),
          shape: BoxShape.rectangle,
        ),
        alignment: Alignment.center,
        child: MyText(
          text: "login",
          multilanguage: true,
          color: white,
          textalign: TextAlign.center,
          fontsize: Dimens.text16Size,
          fontweight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget forgotPassClick() {
    return InkWell(
      borderRadius: BorderRadius.circular(5),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ForgotPassword("Login"),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: MyText(
          text: "forgotpassword",
          multilanguage: true,
          color: otherLightColor,
          textalign: TextAlign.start,
          fontweight: FontWeight.w500,
          fontsize: Dimens.text16Size,
        ),
      ),
    );
  }

  Widget goToRegistration() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MyText(
          text: "dont_have_account",
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
                  return const Registration();
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 10, 6, 10),
            color: transparent,
            child: MyText(
              text: "signup",
              fontsize: Dimens.text15Size,
              multilanguage: true,
              color: colorPrimaryDark,
              fontweight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  bool validatePassword(String? value) {
    if (value == null || value.isEmpty || (value.length < 5)) {
      return true;
    } else {
      return false;
    }
  }

  Widget socialLogin() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              if (check == false) {
                Utils.showSnackbar(context, "pleasetickthecondition", true);
              } else {
                _gmailLogin();
              }
            },
            child: Container(
              padding: const EdgeInsets.fromLTRB(30, 15, 30, 15),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: black.withValues(alpha: 0.5), width: 0.3)),
              child: MyImage(
                imagePath: "ic_google.png",
                height: 25,
                width: 25,
              ),
            ),
          ),
        ),
        Platform.isIOS ? const SizedBox(width: 20) : const SizedBox.shrink(),
        Platform.isIOS
            ? Expanded(
                child: InkWell(
                  onTap: () {
                    if (check == false) {
                      Utils.showSnackbar(
                          context, "pleasetickthecondition", true);
                    } else {
                      signInWithApple();
                    }
                  },
                  child: Container(
                      padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: black.withValues(alpha: 0.5), width: 0.3)),
                      child: const Icon(
                        Icons.apple,
                        color: black,
                        size: 35,
                      )),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  Future<void> _initGoogleSignIn() async {
    try {
      await googleSignIn.initialize(
        clientId:
            "997133946428-0hnk7iqrfhn6ko2lpcv1edgkeqfg5n8k.apps.googleusercontent.com",
        serverClientId:
            "997133946428-0hnk7iqrfhn6ko2lpcv1edgkeqfg5n8k.apps.googleusercontent.com",
      );
      initialized = true;
    } catch (e) {
      printLog("_initGoogleSignIn GoogleSignIn Error ===> $e");
      initialized = false;
      return;
    }
  }

  Future<void> _gmailLogin() async {
    printLog("initialized =======$initialized");
    if (!initialized) {
      await _initGoogleSignIn();
    }
    GoogleSignInAccount? googleUser =
        await googleSignIn.authenticate(scopeHint: ['email', 'profile']);
    if (googleUser.authentication.idToken == null) return;

    GoogleSignInAccount user = googleUser;

    printLog('GoogleSignIn ===> id : ${user.id}');
    printLog('GoogleSignIn ===> email : ${user.email}');
    printLog('GoogleSignIn ===> displayName : ${user.displayName}');
    printLog('GoogleSignIn ===> photoUrl : ${user.photoUrl}');
    userEmail = user.email.toString();
    printLog('GoogleSignIn ===> email : $userEmail');
    if (!mounted) return;
    Utils.showProgress(context, prDialog);

    UserCredential userCredential;
    try {
      GoogleSignInAuthentication googleSignInAuthentication =
          user.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.idToken,
        idToken: googleSignInAuthentication.idToken,
      );

      userCredential = await _auth.signInWithCredential(credential);
      assert(await userCredential.user?.getIdToken() != null);
      printLog("User Name: ${userCredential.user?.displayName}");
      printLog("User Email ${userCredential.user?.email}");
      printLog("User photoUrl ${userCredential.user?.photoURL}");
      printLog("uid ===> ${userCredential.user?.uid}");
      firebasedid = userCredential.user?.uid ?? "";
      printLog('firebasedid :===> $firebasedid');

      /* Update in Firebase */
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.userid,
              isEqualTo: userCredential.user?.uid ?? "")
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(userCredential.user?.uid ?? "")
            .set({
          FirestoreConstants.email: userCredential.user?.email,
          FirestoreConstants.name: userCredential.user?.displayName,
          FirestoreConstants.profileurl: userCredential.user?.photoURL,
          FirestoreConstants.userid: userCredential.user?.uid ?? "",
          FirestoreConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.bioData:
              "Hey! there I'm using ${Constant.appName} app.",
          FirestoreConstants.username: "",
          FirestoreConstants.mobileNumber:
              userCredential.user?.phoneNumber ?? "",
          FirestoreConstants.chattingWith: null,
          FirestoreConstants.pushToken: strDeviceToken
        });
      } else {
        updateDataInFirestore(firebasedid: firebasedid);
      }

      // login API call
      if (!mounted) return;
      Utils.showProgress(context, prDialog);

      try {
        await generalProvider.loginDoctorSocial(
            userEmail, "2", firebasedid, strDeviceToken);
        if (!mounted) return;
        await Utils.updateGeneralSettingData(context, generalProvider);
      } on Exception catch (e) {
        prDialog.hide();
        printLog("loginDoctor Exception =====> $e");
      }

      checkAndNavigate();
    } on FirebaseAuthException catch (e) {
      printLog('FirebaseAuthException ===CODE====> ${e.code.toString()}');
      printLog('FirebaseAuthException ==MESSAGE==> ${e.message.toString()}');
      // Hide Progress Dialog
      prDialog.hide();
    }
  }

  /* Google Login */
  // Future<void> _gmailLogin() async {
  //   await GoogleSignIn.instance.initialize(
  //       serverClientId:
  //           "997133946428-sn80pru3ardrmdrovg4e8ui7sbskhohn.apps.googleusercontent.com");
  //   final googleUser = await GoogleSignIn.instance.authenticate();

  //   GoogleSignInAccount user = googleUser;

  //   printLog('GoogleSignIn ===> id : ${user.id}');
  //   printLog('GoogleSignIn ===> email : ${user.email}');
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
  //       accessToken: googleSignInAuthentication.idToken,
  //       idToken: googleSignInAuthentication.idToken,
  //     );

  //     userCredential = await _auth.signInWithCredential(credential);
  //     assert(await userCredential.user?.getIdToken() != null);
  //     printLog("User Name: ${userCredential.user?.displayName}");
  //     printLog("User Email ${userCredential.user?.email}");
  //     printLog("User photoUrl ${userCredential.user?.photoURL}");
  //     printLog("uid ===> ${userCredential.user?.uid}");
  //     firebasedid = userCredential.user?.uid ?? "";
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
  //         FirestoreConstants.email: userCredential.user?.email,
  //         FirestoreConstants.name: userCredential.user?.displayName,
  //         FirestoreConstants.profileurl: userCredential.user?.photoURL,
  //         FirestoreConstants.userid: userCredential.user?.uid ?? "",
  //         FirestoreConstants.createdAt:
  //             DateTime.now().millisecondsSinceEpoch.toString(),
  //         FirestoreConstants.bioData:
  //             "Hey! there I'm using ${Constant.appName} app.",
  //         FirestoreConstants.username: "",
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
  //       if (!mounted) return;
  //       await Utils.updateGeneralSettingData(context, generalProvider);
  //     } on Exception catch (e) {
  //       prDialog.hide();
  //       printLog("loginDoctor Exception =====> $e");
  //     }

  //     checkAndNavigate();
  //   } on FirebaseAuthException catch (e) {
  //     printLog('FirebaseAuthException ===CODE====> ${e.code.toString()}');
  //     printLog('FirebaseAuthException ==MESSAGE==> ${e.message.toString()}');
  //     // Hide Progress Dialog
  //     prDialog.hide();
  //   }
  // }

  /* Apple Login */
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

      dynamic firebasedId;
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
        firebasedId = firebaseUser?.uid.toString();
        displayName = firebaseUser?.displayName.toString();

        printLog("===>userEmail-else $userEmail");
        printLog("===>displayName-else $displayName");
      }
      printLog("userEmail =====FINAL==> $userEmail");
      printLog("firebasedId ===FINAL==> $firebasedId");
      printLog("displayName ===FINAL==> $displayName");
      /*  ************************************/

      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(FirestoreConstants.pathUserCollection)
          .where(FirestoreConstants.userid, isEqualTo: firebasedId)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isEmpty) {
        // Writing data to server because here is a new user
        FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .doc(firebasedId)
            .set({
          FirestoreConstants.email: userEmail,
          FirestoreConstants.name: displayName ?? "",
          FirestoreConstants.profileurl: Constant.userPlaceholder,
          FirestoreConstants.userid: firebasedId,
          FirestoreConstants.createdAt:
              DateTime.now().millisecondsSinceEpoch.toString(),
          FirestoreConstants.bioData:
              "Hey! there I'm using ${Constant.appName} app.",
          FirestoreConstants.username: "",
          FirestoreConstants.mobileNumber: "",
          FirestoreConstants.chattingWith: null,
        });
      } else {
        updateDataInFirestore(firebasedid: firebasedId);
      }

      // login API call
      if (!mounted) return;
      Utils.showProgress(context, prDialog);

      try {
        await generalProvider.loginDoctorSocial(
            userEmail, "3", firebasedId, strDeviceToken);
        if (!mounted) return;
        await Utils.updateGeneralSettingData(context, generalProvider);
      } on Exception catch (e) {
        prDialog.hide();
        printLog("loginDoctor Exception =====> $e");
      }

      checkAndNavigate();
    } catch (exception) {
      prDialog.hide();
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

  firebaseLogin(String email, String password) async {
    try {
      // Attempt to sign in the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = userCredential.user;
      prDialog.hide();

      if (user != null) {
        printLog("User UID: ${user.uid}");
        handleUserLoginSuccess(user);
      }
    } on FirebaseAuthException catch (e) {
      prDialog.hide();
      if (e.code == 'user-not-found') {
        Utils.showToast("No user found. Registering new user...");

        try {
          // Register new user if not found
          UserCredential userCredential =
              await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

          User? newUser = userCredential.user;

          if (newUser != null) {
            printLog("New user registered: ${newUser.uid}");
            await saveUserToFirestore(newUser);
            handleUserLoginSuccess(newUser);
          }
        } on FirebaseAuthException catch (regError) {
          Utils.showToast(
              regError.message ?? "Registration failed. Try again.");
          printLog("Registration error: ${regError.code}, ${regError.message}");
        }
      } else if (e.code == 'wrong-password') {
        Utils.showToast("Invalid password. Please try again.");
      } else {
        Utils.showToast(e.message ?? "An error occurred.");
      }
    } catch (e) {
      prDialog.hide();
      Utils.showToast("An unexpected error occurred.");
      printLog("Exception: $e");
    }
  }

  void handleUserLoginSuccess(User user) async {
    String firebasedid = user.uid;

    // Check if the user exists in Firestore
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .where(FirestoreConstants.userid, isEqualTo: firebasedid)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.isEmpty) {
      // Add user data to Firestore if it doesn't exist
      await saveUserToFirestore(user);
    } else {
      updateDataInFirestore(firebasedid: firebasedid);
    }

    // Perform login via API
    await generalProvider.loginDoctor(user.email ?? "",
        mPasswordController.text.toString(), type, firebasedid, strDeviceToken);

    if (!mounted) return;
    await Utils.updateGeneralSettingData(context, generalProvider);

    if (generalProvider.loginRegisterModel.status == 200) {
      checkAndNavigate();
    } else {
      Utils.showToast(
          generalProvider.loginRegisterModel.message ?? "Login failed.");
    }
  }

  Future<void> saveUserToFirestore(User user) async {
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(user.uid)
        .set({
      FirestoreConstants.email: user.email ?? "",
      FirestoreConstants.userid: user.uid,
      FirestoreConstants.createdAt:
          DateTime.now().millisecondsSinceEpoch.toString(),
      FirestoreConstants.pushToken: strDeviceToken,
    });
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

  void validateFormData() async {
    final isValidForm = _formKey.currentState!.validate();
    printLog("isValidForm => $isValidForm");
    // Validate returns true if the form is valid, or false otherwise.
    if (isValidForm) {
      userEmail = mEmailController.text.toString().trim();
      password = mPasswordController.text.toString().trim();
      type = "4";

      if (mEmailController.text.isEmpty) {
        Utils.showToast(enterEmail);
      } else if (mPasswordController.text.isEmpty) {
        Utils.showToast(enterPassword);
      } else if (!EmailValidator.validate(mEmailController.text)) {
        Utils.showToast(enterValidEmail);
      } else {
        // login API call
        if (!mounted) return;
        Utils.showProgress(context, prDialog);
        firebaseLogin(userEmail, password);
      }
    }
  }

  Future<void> checkAndNavigate() async {
    printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');
    if (!generalProvider.loading) {
      // Hide Progress Dialog

      if (generalProvider.loginRegisterModel.status == 200 &&
          generalProvider.loginRegisterModel.result != null) {
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
          userPremium: '',
          userType:
              generalProvider.loginRegisterModel.result?[0].type.toString(),
          userFirebaseId: generalProvider
              .loginRegisterModel.result?[0].firebaseId
              .toString(),
        );
        // onUserLogin(generalProvider.loginRegisterModel.result?[0].id.toString(),
        //     generalProvider.loginRegisterModel.result?[0].fullName.toString());

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginRegisterModel.result?[0].id.toString() ?? "";
        printLog('Constant userID ==>> ${Constant.userID}');

        await clearTextFormField();
        prDialog.hide();
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
        Utils.showSnackbar(
            context, "${generalProvider.loginRegisterModel.message}", false);
      }
    }
  }
}
