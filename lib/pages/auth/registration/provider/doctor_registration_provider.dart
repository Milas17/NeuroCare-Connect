// import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:email_validator/email_validator.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';

// import '../../../../model/specialitymodel.dart';
// import '../../../../provider/generalprovider.dart';
// import '../../../../utils/constant.dart';
// import '../../../../utils/firebaseconstant.dart';
// import '../../../../utils/sharedpre.dart';
// import '../../../../utils/strings.dart';
// import '../../../../utils/utils.dart';

// class DoctorRegistrationProvider with ChangeNotifier {
//   String? latitude,
//       longitude,
//       area,
//       city,
//       state,
//       country,
//       strDeviceToken,
//       strDeviceType,
//       specialityId,
//       imagePath;

//   String countryCode = "+91";
//   String countryName = "India";
//   bool isPasswordVisible = false;
//   String firebasedid = "";
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   SharedPre sharePref = SharedPre();
  

//   bool success = false;

//   getDeviceToken() async {
//     try {
//       if (Platform.isAndroid) {
//         strDeviceToken = await FirebaseMessaging.instance.getToken();
//         strDeviceType = "1";
//       } else {
//         strDeviceToken = OneSignal.User.pushSubscription.token;
//         strDeviceType = "2";
//       }
//       printLog("strDeviceToken ===> $strDeviceToken");
//       printLog("strDeviceType ====> $strDeviceType");
//     } catch (e) {}
//   }

//   Future<User?> createUserWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       UserCredential userCredential =
//           await _auth.createUserWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//       return userCredential.user;
//     } on FirebaseAuthException catch (e) {
//       printLog('createUserWithEmailAndPassword Error 1 :===> $e');
//       if (e.code == 'email-already-in-use') {
//         printLog('The account already exists for that email.');
//         try {
//           UserCredential userCredential =
//               await _auth.signInWithEmailAndPassword(
//             email: email,
//             password: password,
//           );
//           return userCredential.user;
//         } on FirebaseAuthException catch (e) {
//           printLog('createUserWithEmailAndPassword Error 2 :===> $e');
//           if (e.code == 'email-already-in-use') {
//             printLog('The account already exists for that email.');
//             Utils.showToast(e.message.toString());
//             success = false;
//           }
//         }
//       }
//       return null;
//     }
//   }

//   firebaseRegister(
//       {required String email,
//       required String password,
//       required String mobile,
//       required String fullName,
//       required String fees,
//       required String practiceTenure,
//       required String dob,
//       required GeneralProvider generalProvider}) async {
//     printLog("firebaseRegister email ========> $email");
//     printLog("firebaseRegister password =====> $password");
//     User? user = await createUserWithEmailAndPassword(email, password);

//     if (user != null) {
//       try {
//         assert(await user.getIdToken() != null);
//         printLog("User Name: ${user.displayName}");
//         printLog("User Email ${user.email}");
//         printLog("User photoUrl ${user.photoURL}");
//         printLog("uid ===> ${user.uid}");
//         firebasedid = user.uid;
//         printLog('firebasedid :===> $firebasedid');

//         // Check is already sign up
//         final QuerySnapshot result = await FirebaseFirestore.instance
//             .collection(FirestoreConstants.pathUserCollection)
//             .where(FirestoreConstants.userid, isEqualTo: firebasedid)
//             .get();

//         final List<DocumentSnapshot> documents = result.docs;

//         if (documents.isEmpty) {
//           // Writing data to server because here is a new user
//           FirebaseFirestore.instance
//               .collection(FirestoreConstants.pathUserCollection)
//               .doc(firebasedid)
//               .set({
//             FirestoreConstants.email: email,
//             FirestoreConstants.name: fullName,
//             FirestoreConstants.profileurl: Constant.userPlaceholder,
//             FirestoreConstants.userid: firebasedid,
//             FirestoreConstants.createdAt:
//                 DateTime.now().millisecondsSinceEpoch.toString(),
//             FirestoreConstants.bioData: "",
//             FirestoreConstants.username: "",
//             FirestoreConstants.mobileNumber: mobile,
//             FirestoreConstants.chattingWith: null,
//             FirestoreConstants.pushToken: strDeviceToken
//           });
//         } else {
//           printLog('strDeviceToken ....==>> $strDeviceToken');
//           printLog('firebasedid ....==>> $firebasedid');
//           // Update data to Firestore
//           FirebaseFirestore.instance
//               .collection(FirestoreConstants.pathUserCollection)
//               .doc(firebasedid)
//               .update({
//                 FirestoreConstants.email: email,
//                 FirestoreConstants.name: fullName,
//                 FirestoreConstants.profileurl: Constant.userPlaceholder,
//                 FirestoreConstants.userid: firebasedid,
//                 FirestoreConstants.createdAt:
//                     DateTime.now().millisecondsSinceEpoch.toString(),
//                 FirestoreConstants.bioData: "",
//                 FirestoreConstants.username: "",
//                 FirestoreConstants.mobileNumber: mobile,
//                 FirestoreConstants.chattingWith: null,
//                 FirestoreConstants.pushToken: strDeviceToken
//               })
//               .then((value) => printLog("User Updated"))
//               .onError((error, stackTrace) {
//                 printLog("updateDataFirestore error ===> ${error.toString()}");
//                 printLog(
//                     "updateDataFirestore stackTrace ===> ${stackTrace.toString()}");
//                 success = false;
//               });
//         }
//         //MITESH CODE HERE
//         await normalRegister(
//             fullName: fullName,
//             fees: fees,
//             dob: dob,
//             generalProvider: generalProvider,
//             mobile: mobile,
//             practiceTenure: practiceTenure,
//             userEmail: email);
//       } on FirebaseAuthException catch (e) {
//         if (e.code == 'weak-password') {
//           printLog('The password provided is too weak.');
//           success = false;
//         } else if (e.code == 'email-already-in-use') {
//           Utils.showToast(e.message);
//           printLog('The account already exists for that email.');
//           success = false;
//         }
//       } finally {}
//     }
//   }

//   normalRegister(
//       {required String fullName,
//       required String userEmail,
//       required String mobile,
//       required String fees,
//       required String practiceTenure,
//       required String dob,
//       required GeneralProvider generalProvider}) async {
//     printLog('firebasedid :===> $firebasedid');
//     await generalProvider.registerDoctor(
//         fullName,
//         userEmail,
//         password,
//         mobile,
//         fees,
//         firebasedid,
//         strDeviceToken,
//         strDeviceType,
//         address,
//         specialityId,
//         practiceTenure,
//         dob,
//         latitude,
//         longitude,
//         area,
//         city,
//         state,
//         country,
//         countryCode,
//         countryName,
//         File(imagePath ?? ""));
//     await storeDataToPref(generalProvider);
//   }

//   Future<void> storeDataToPref(GeneralProvider generalProvider) async {
//     printLog('firebasedid :===> $firebasedid');
//     printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');
//     if (!generalProvider.loading) {
//       if (generalProvider.loginRegisterModel.status == 200 &&
//           generalProvider.loginRegisterModel.result != null) {
//         printLog(
//             'loginRegisterModel ==>> ${generalProvider.loginRegisterModel.toString()}');
//         printLog('Registration Successfull!');
//         await Utils.saveUserCreds(
//           userID: generalProvider.loginRegisterModel.result?[0].id.toString(),
//           userName:
//               generalProvider.loginRegisterModel.result?[0].fullName.toString(),
//           userEmail:
//               generalProvider.loginRegisterModel.result?[0].email.toString(),
//           userMobile: generalProvider.loginRegisterModel.result?[0].mobileNumber
//               .toString(),
//           userImage: generalProvider.loginRegisterModel.result?[0].profileImg
//               .toString(),
//           userPremium: '',
//           userType:
//               generalProvider.loginRegisterModel.result?[0].type.toString(),
//           userFirebaseId: generalProvider
//               .loginRegisterModel.result?[0].firebaseId
//               .toString(),
//         );

//         // Set UserID for Next
//         Constant.userID =
//             generalProvider.loginRegisterModel.result?[0].id.toString() ?? "";

//         await sharePref.save("isEdit", "1");
//         printLog('Constant userID ==>> ${Constant.userID}');
//         success = true;
//       } else {
//         success = false;
//       }
//     }
//   }

//   clear() {
//     latitude = null;
//     longitude = null;
//     area = null;
//     city = null;
//     state = null;
//     country = null;
//     strDeviceToken = null;
//     strDeviceType = null;
//     specialityId = null;
//     countryCode = "+91";
//     countryName = "India";
//     isPasswordVisible = false;
//   }

//   fieldValidation(
//       {required String name,
//       required String email,
//       required String contact,
//       required String address,
//       required String pracTenure,
//       required String dob,
//       required String fees,
//       required VoidCallback onSucess}) {
//     if (name.isEmpty) {
//       Utils.showToast(enterFirstname);
//     } else if (email.isEmpty) {
//       Utils.showToast(enterEmail);
//     } else if (contact.isEmpty) {
//       Utils.showToast(enterMobilenumber);
//     } else if (fees.isEmpty) {
//       Utils.showToast(enterFees);
//     } else if (!EmailValidator.validate(email)) {
//       Utils.showToast(enterValidEmail);
//     } else {
//       onSucess();
//     }
//   }
// }
