import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/firebaseconstant.dart';

class ChatUserModel {
  String biodata;
  String mobileNumber;
  String chattingWith;
  String pushToken;
  String createdAt;
  String email;
  String name;
  String photoUrl;
  String userid;
  String userName;

  ChatUserModel(
      {required this.biodata,
      required this.chattingWith,
      required this.mobileNumber,
      required this.pushToken,
      required this.createdAt,
      required this.email,
      required this.name,
      required this.photoUrl,
      required this.userid,
      required this.userName});

  Map<String, String> toJson() {
    return {
      FirestoreConstants.bioData: biodata,
      FirestoreConstants.chattingWith: chattingWith,
      FirestoreConstants.mobileNumber: mobileNumber,
      FirestoreConstants.pushToken: pushToken,
      FirestoreConstants.createdAt: createdAt,
      FirestoreConstants.email: email,
      FirestoreConstants.name: name,
      FirestoreConstants.profileurl: photoUrl,
      FirestoreConstants.userid: userid,
      FirestoreConstants.username: userName,
    };
  }

  factory ChatUserModel.fromDocument(DocumentSnapshot doc) {
    String biodata = "";
    String chattingWith = "";
    String pushToken = "";
    String mobileNumber = "";
    String createdAt = "";
    String email = "";
    String name = "";
    String photoUrl = "";
    String userid = "";
    String userName = "";
    printLog("doc ====> ${doc.id}");
    try {
      biodata = doc[FirestoreConstants.bioData] ?? "";
    } catch (e) {
      printLog("biodata Exception ====> $e");
      biodata = "";
    }
    try {
      chattingWith = doc[FirestoreConstants.chattingWith] ?? "";
    } catch (e) {
      printLog("chattingWith Exception ====> $e");
      chattingWith = "";
    }
    try {
      mobileNumber = doc[FirestoreConstants.mobileNumber] ?? "";
    } catch (e) {
      printLog("mobileNumber Exception ====> $e");
      mobileNumber = "";
    }
    try {
      pushToken = doc[FirestoreConstants.pushToken] ?? "";
    } catch (e) {
      printLog("pushToken Exception ====> $e");
      pushToken = "";
    }
    try {
      createdAt = doc[FirestoreConstants.createdAt] ?? "";
    } catch (e) {
      printLog("createdAt Exception ====> $e");
      createdAt = "";
    }
    try {
      email = doc[FirestoreConstants.email] ?? "";
    } catch (e) {
      printLog("email Exception ====> $e");
      email = "";
    }
    try {
      name = doc[FirestoreConstants.name] ?? "";
    } catch (e) {
      printLog("name Exception ====> $e");
      name = "";
    }
    try {
      photoUrl = doc[FirestoreConstants.profileurl] ?? "";
    } catch (e) {
      printLog("photoUrl Exception ====> $e");
      photoUrl = Constant.userPlaceholder;
    }
    try {
      userid = doc[FirestoreConstants.userid] ?? "";
    } catch (e) {
      printLog("userid Exception ====> $e");
      userid = "";
    }
    try {
      userName = doc[FirestoreConstants.username] ?? "";
    } catch (e) {
      printLog("userName Exception ====> $e");
      userName = "";
    }
    return ChatUserModel(
      biodata: biodata,
      mobileNumber: mobileNumber,
      chattingWith: chattingWith,
      pushToken: pushToken,
      createdAt: createdAt,
      email: email,
      name: name,
      photoUrl: photoUrl,
      userid: userid,
      userName: userName,
    );
  }
}
