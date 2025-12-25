import 'dart:io';

import 'package:yourappname/model/workingtimeslotmodel.dart';
import 'package:yourappname/pages/loginselect.dart';
import 'package:yourappname/provider/addworkslotprovider.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:yourappname/utils/colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:location/location.dart' as loc;
import '../provider/generalprovider.dart';
import 'constant.dart';

printLog(String message) {
  if (kDebugMode) {
    return print(message);
  }
}

class Utils {
  static List<String> imageAndDocExtension = [
    "doc",
    "docx",
    "xls",
    "xlsx",
    "ppt",
    "pptx",
    "pdf",
    "rtf",
    "txt",
    "odt",
    "zip",
    "rar",
    "jpg",
    "jpeg",
    "png",
    "heic",
    "heif",
    "webp"
  ];

  static void showToast(var msg) {
    Fluttertoast.showToast(
        msg: "$msg",
        timeInSecForIosWeb: 2,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: white,
        textColor: black,
        fontSize: 16);
  }

  static String formateTimeSetInColumn(String time) {
    String finalTime = "";
    DateFormat hhmmFormatter = DateFormat("HH:mm");
    DateFormat mmFormatter = DateFormat("hh:mm a");

    // printLog('time => $time');
    DateTime inputTime = hhmmFormatter.parse(time);
    // printLog('inputTime => $inputTime');

    finalTime = mmFormatter.format(inputTime);
    finalTime = finalTime.split(" ").join("\n");
    // printLog('finalTime => $finalTime');

    return finalTime;
  }

  static String formateFullDate(String date) {
    String finalDate = "";
    DateFormat inputDate = DateFormat("yyyy-MM-dd HH:mm:ss.SSS");
    DateFormat outputDate = DateFormat("yyyy-MM-dd");

    printLog('date => $date');
    DateTime inputTime = inputDate.parse(date);
    printLog('inputTime => $inputTime');

    finalDate = outputDate.format(inputTime);
    printLog('finalDate => $finalDate');

    return finalDate;
  }

  static TextStyle googleFontStyle(int inter, double fontsize,
      FontStyle fontstyle, Color color, FontWeight fontwaight) {
    if (inter == 1) {
      return GoogleFonts.poppins(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 2) {
      return GoogleFonts.lobster(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else if (inter == 3) {
      return GoogleFonts.rubik(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    } else {
      return GoogleFonts.inter(
          fontSize: fontsize,
          fontStyle: fontstyle,
          color: color,
          fontWeight: fontwaight);
    }
  }

  static void getUserId() async {
    SharedPre sharedPref = SharedPre();
    Constant.userID = await sharedPref.read("userid") ?? "";
    printLog('Constant userID ==> ${Constant.userID}');
  }

  static Future<bool> checkPremiumUser() async {
    SharedPre sharedPre = SharedPre();
    String? isPremiumBuy = await sharedPre.read("userpremium");
    printLog('checkPremiumUser isPremiumBuy ==> $isPremiumBuy');
    if (isPremiumBuy != null && isPremiumBuy == "1") {
      return true;
    } else {
      return false;
    }
  }

  static void updatePremium(String isPremiumBuy) async {
    printLog('updatePremium isPremiumBuy ==> $isPremiumBuy');
    SharedPre sharedPre = SharedPre();
    await sharedPre.save("userpremium", isPremiumBuy);
    String? isPremium = await sharedPre.read("userpremium");
    printLog('updatePremium ===============> $isPremium');
  }

  static saveUserCreds({
    required userID,
    required userName,
    required userEmail,
    required userMobile,
    required userImage,
    required userPremium,
    required userType,
    required userFirebaseId,
  }) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID.toString());
      await sharedPref.save("username", userName.toString());
      await sharedPref.save("useremail", userEmail.toString());
      await sharedPref.save("usermobile", userMobile.toString());
      await sharedPref.save("userimage", userImage.toString());
      await sharedPref.save("userpremium", userPremium.toString());
      await sharedPref.save("usertype", userType.toString());
      await sharedPref.save("firebaseid", userFirebaseId.toString());
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
      await sharedPref.remove("firebaseid");
    }
    Constant.userID = await sharedPref.read("userid");
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static setFirstTime() async {
    SharedPre sharedPref = SharedPre();
    await sharedPref.save("seen", "1");
    String seenValue = await sharedPref.read("seen");
    printLog('setFirstTime seen ==> $seenValue');
  }

  static Widget pageLoader() {
    return const Align(
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }

  static checkLoginUser(BuildContext context) {
    if (Constant.userID != "") {
      return true;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const Loginselect();
        },
      ),
    );
    return false;
  }

  static setUserId(userID) async {
    SharedPre sharedPref = SharedPre();
    if (userID != null) {
      await sharedPref.save("userid", userID);
    } else {
      await sharedPref.remove("userid");
      await sharedPref.remove("username");
      await sharedPref.remove("userimage");
      await sharedPref.remove("useremail");
      await sharedPref.remove("usermobile");
      await sharedPref.remove("userpremium");
      await sharedPref.remove("usertype");
      await sharedPref.remove("firebaseid");
    }
    Constant.userID = await sharedPref.read("userid") ?? "";
    printLog('setUserId userID ==> ${Constant.userID}');
  }

  static BoxDecoration setBGWithBorder(
      Color colorBg, Color colorBorder, double radius, double borderWidth) {
    return BoxDecoration(
      color: colorBg,
      border: Border.all(
        color: colorBorder,
        width: borderWidth,
      ),
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static void showProgress(
      BuildContext context, ProgressDialog? prDialog) async {
    prDialog ??= ProgressDialog(context);
    //For normal dialog
    prDialog = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: false, showLogs: false);

    prDialog.style(
      message: pleaseWait,
      borderRadius: 5,
      progressWidget: Container(
        padding: const EdgeInsets.all(8),
        child: const CircularProgressIndicator(),
      ),
      maxProgress: 100,
      progressTextStyle: const TextStyle(
        color: black,
        fontSize: 13,
        fontWeight: FontWeight.w400,
      ),
      backgroundColor: white,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
        color: black,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
    );

    await prDialog.show();
  }

  static void showSnackbar(
      BuildContext context, String message, bool multilanguage) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      backgroundColor: transparent,
      width: kIsWeb
          ? ((MediaQuery.of(context).size.width > 1000)
              ? (MediaQuery.of(context).size.width * 0.3)
              : (MediaQuery.of(context).size.width))
          : (MediaQuery.of(context).size.width),
      content: Container(
        constraints: const BoxConstraints(minHeight: kIsWeb ? 60 : 50),
        alignment: Alignment.center,
        decoration: setBackground(colorPrimary, 5),
        padding: const EdgeInsets.all(kIsWeb ? 15 : 10),
        child: MyText(
          text: message,
          multilanguage: multilanguage,
          fontstyle: FontStyle.normal,
          fontsize: Dimens.text14Size,
          maxline: 5,
          overflow: TextOverflow.ellipsis,
          fontweight: FontWeight.w500,
          color: white,
          textalign: TextAlign.center,
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  myappbar(String image, String title, var onTap) {
    return AppBar(
      centerTitle: false,
      automaticallyImplyLeading: false,
      elevation: 0,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: colorPrimaryDark,
      ),
      backgroundColor: colorPrimaryDark,
      title: Row(
        children: [
          InkWell(
            onTap: onTap,
            child: Container(
                padding: const EdgeInsets.all(7),
                child: MyImage(width: 20, height: 20, imagePath: image)),
          ),
          const SizedBox(width: 10),
          MyText(
            color: white,
            text: title,
            fontsize: Dimens.text16Size,
            multilanguage: true,
            fontweight: FontWeight.w600,
            maxline: 1,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.center,
            fontstyle: FontStyle.normal,
          ),
        ],
      ),
    );
  }

  static AppBar myAppBar(BuildContext context, String appBarTitle) {
    return AppBar(
      elevation: 0,
      backgroundColor: transparent,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: toolbarGradientBG(),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: colorAccent.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 25,
            color: black,
          ),
        ),
      ),
      title: MyText(
        text: appBarTitle,
        fontsize: Dimens.text22Size,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.w600,
        textalign: TextAlign.center,
        color: colorPrimaryDark,
      ),
    );
  }

  static AppBar myAppBarWithBack(BuildContext context, String appBarTitle,
      bool titleIsMultilang, bool isBack) {
    return AppBar(
      elevation: 0,
      backgroundColor: transparent,
      automaticallyImplyLeading: false,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: toolbarGradientBG(),
      ),
      leading: isBack == true
          ? IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: colorAccent.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  size: 25,
                  color: black,
                ),
              ),
            )
          : const SizedBox.shrink(),
      title: MyText(
        text: appBarTitle,
        multilanguage: titleIsMultilang,
        fontsize: Dimens.text24Size,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.w600,
        textalign: TextAlign.center,
        color: colorPrimaryDark,
      ),
    );
  }

  static AppBar myAppBarSimple(BuildContext context, String appBarTitle) {
    return AppBar(
      elevation: 0,
      backgroundColor: transparent,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: colorAccent.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 25,
            color: black,
          ),
        ),
      ),
      title: MyText(
        text: appBarTitle,
        fontsize: Dimens.text20Size,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.normal,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  Widget seeallBtn() {
    return MyText(
      text: "see_all",
      multilanguage: true,
      fontsize: Dimens.text14Size,
      fontweight: FontWeight.w500,
      overflow: TextOverflow.ellipsis,
      textalign: TextAlign.end,
      color: grayDark,
    );
  }

  static AppBar myAppBarWithGradient(
    BuildContext context,
    String appBarTitle,
    bool titleIsMultilang,
  ) {
    return AppBar(
      elevation: 0,
      backgroundColor: transparent,
      centerTitle: true,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              colorPrimary,
              colorPrimary,
            ],
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
              color: colorAccent.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8)),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 25,
            color: black,
          ),
        ),
      ),
      title: MyText(
        text: appBarTitle,
        multilanguage: titleIsMultilang,
        fontsize: Dimens.text20Size,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.normal,
        textalign: TextAlign.center,
        color: white,
      ),
    );
  }

  static BoxDecoration textFieldBGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: otherLightColor,
        width: .2,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration textFieldRegistraionBGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: black,
        width: .7,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration textFieldBGWithBorderMedicine() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: black,
        width: .7,
      ),
      borderRadius: BorderRadius.circular(4),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration setBackground(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r4BGWithBorder() {
    return BoxDecoration(
      color: colorAccent,
      border: Border.all(
        color: colorAccent,
        width: .5,
      ),
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r4DarkBGWithBorder() {
    return BoxDecoration(
      color: colorPrimary,
      border: Border.all(
        color: colorPrimary,
        width: .5,
      ),
      borderRadius: BorderRadius.circular(10),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration r10BGWithBorder() {
    return BoxDecoration(
      color: white,
      border: Border.all(
        color: black,
        width: .7,
      ),
      borderRadius: BorderRadius.circular(5),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration primaryDarkButton() {
    return BoxDecoration(
      color: colorPrimaryDark,
      borderRadius: BorderRadius.circular(5),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration topRoundBG() {
    return const BoxDecoration(
      color: white,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
      shape: BoxShape.rectangle,
    );
  }

  static BoxDecoration toolbarGradientBG() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          // gradStartColor,
          // gradEndColor,
          white, white
        ],
      ),
      // borderRadius: BorderRadius.only(
      //   bottomLeft: Radius.circular(30),
      //   bottomRight: Radius.circular(30),
      // ),
      shape: BoxShape.rectangle,
    );
  }

  static Future<void> launchPhoneDialer(String contactNumber) async {
    final Uri phoneUri = Uri(scheme: "tel", path: contactNumber);
    try {
      if (await canLaunchUrl(Uri.parse(phoneUri.toString()))) {
        await launchUrl(Uri.parse(phoneUri.toString()));
      }
    } catch (error) {
      throw ("Cannot dial");
    }
  }

  static String formateDate(String date) {
    String finalDate = "";
    DateFormat inputDate = DateFormat("yyyy-MM-dd");
    DateFormat outputDate = DateFormat("MMM dd, yyyy");

    printLog('date => $date');
    DateTime inputTime = inputDate.parse(date);
    printLog('inputTime => $inputTime');

    finalDate = outputDate.format(inputTime);
    printLog('finalDate => $finalDate');

    return finalDate;
  }

  static String formatDates(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }

  static String formateTimes(String time) {
    // your existing implementation
    return time;
  }

  static String formateInMMMMDD(String date) {
    String finalDate = "";
    DateFormat inputDate = DateFormat("yyyy-MM-dd");
    DateFormat outputDate = DateFormat("MMMM dd");

    printLog('date => $date');
    DateTime inputTime = inputDate.parse(date);
    printLog('inputTime => $inputTime');

    finalDate = outputDate.format(inputTime);
    printLog('finalDate => $finalDate');

    return finalDate;
  }

  static String formateTime(String time) {
    String finalTime = "";
    DateFormat hhmmFormatter = DateFormat("HH:mm");
    DateFormat mmFormatter = DateFormat("hh:mm a");

    printLog('time => $time');
    DateTime inputTime = hhmmFormatter.parse(time);
    printLog('inputTime => $inputTime');

    finalTime = mmFormatter.format(inputTime);
    printLog('finalTime => $finalTime');

    return finalTime;
  }

  static String getNumberSuffix(int input) {
    printLog("input --> $input");
    int lastDigit = 0;
    try {
      lastDigit = input % 10;
      int lastTwoDigit = input % 100;
      if (lastTwoDigit >= 10 && lastTwoDigit <= 20) {
        return "$input th";
      }
    } catch (e) {
      printLog("getNumberSuffix Exception ==> $e");
    }

    switch (lastDigit) {
      case 1:
        return "$input st";
      case 2:
        return "$input nd";
      case 3:
        return "$input rd";

      default:
        return "$input th";
    }
  }

  static String covertTimeToText(String dataDate) {
    String convTime = "";
    String suffix = "ago";

    try {
      DateTime pasTime =
          DateTime.parse(dataDate).toLocal(); // Convert to local timezone
      DateTime nowTime = DateTime.now();

      Duration difference = nowTime.difference(pasTime);

      int days = difference.inDays;
      int hours = difference.inHours;
      int minutes = difference.inMinutes;

      if (minutes < 60) {
        // Show minutes if time difference is less than 1 hour
        convTime =
            minutes == 1 ? "$minutes min $suffix" : "$minutes mins $suffix";
      } else if (hours < 24) {
        // Show hours if time difference is less than 24 hours
        convTime = hours == 1 ? "$hours hr $suffix" : "$hours hrs $suffix";
      } else if (days < 7) {
        // Show days if time difference is less than 7 days
        convTime = days == 1 ? "$days day $suffix" : "$days days $suffix";
      } else if (days >= 7) {
        // Show weeks, months, or years for larger differences
        if (days > 360) {
          convTime = "${(days / 360).toStringAsPrecision(1)} yrs $suffix";
        } else if (days > 30) {
          convTime = "${(days / 30).toStringAsPrecision(1)} months $suffix";
        } else {
          convTime = "${(days / 7).toStringAsPrecision(1)} weeks $suffix";
        }
      }
    } catch (e) {
      printLog("ConvTimeE Exception ==> $e");
    }

    return convTime;
  }

  Future<void> getTimeFromSlot(BuildContext context, int tsPosition,
      String slotID, String duration, String startTime, String endTime) async {
    DateFormat hhmmFormatter = DateFormat("HH:mm");
    DateFormat mmFormatter = DateFormat("hh:mm");

    AddWorkSlotProvider addWorkSlotProvider =
        Provider.of<AddWorkSlotProvider>(context, listen: false);

    printLog('tsPosition =============> $tsPosition');
    printLog('slotID =============> $slotID');
    printLog('duration =============> $duration');
    printLog('startTime => $startTime');
    printLog('endTime => $endTime');
    DateTime start = hhmmFormatter.parse(startTime);
    DateTime end = hhmmFormatter.parse(endTime);
    Duration durationGap = Duration(minutes: int.parse(duration));

    Duration difference = end.difference(start);

    if (difference.isNegative) {
      DateTime dateMax = hhmmFormatter.parse("24:00");
      DateTime dateMin = hhmmFormatter.parse("00:00");
      difference = ((dateMax.difference(start)) + (end.difference(dateMin)));
    }

    double hours = difference.inHours % 24;
    double minutes = difference.inMinutes % 60;
    double parts = 0;
    double totalMinutes = 0;

    if (hours > 0 && hours < 24) {
      totalMinutes = hours * 60;
      parts = (totalMinutes / double.parse(duration));
      printLog('parts : if ==> $parts');
    } else if (minutes > 0 && minutes < 60) {
      totalMinutes = totalMinutes + minutes;
      parts = (totalMinutes / double.parse(duration));
      printLog('parts : else if ==> $parts');
    }

    if (parts > 0) {
      List<TimeSchedul> tempTimeScheduleList = <TimeSchedul>[];
      for (int i = 0; i < parts; i++) {
        TimeSchedul scheduleModel = TimeSchedul();
        printLog('oldTime :==> ${mmFormatter.format(start).toString()}');
        scheduleModel.tsPosition = tsPosition;
        scheduleModel.appointmentSlotsId = slotID;
        scheduleModel.startTime = mmFormatter.format(start).toString();
        tempTimeScheduleList.add(scheduleModel);
        DateTime dateTime = start.add(durationGap);
        start = dateTime;
        printLog('newTime :==> ${mmFormatter.format(start)}');
      }
      printLog('parts tempTimeScheduleList ==> ${tempTimeScheduleList.length}');
      printLog('parts slotList ==> ${addWorkSlotProvider.slotList.length}');
      if (addWorkSlotProvider.slotList.isNotEmpty) {
        printLog('tsPosition =====> $tsPosition');
        for (int i = 0; i < addWorkSlotProvider.slotList.length; i++) {
          if (tsPosition == i) {
            TimeSlote timeSlots = TimeSlote();
            timeSlots.id = addWorkSlotProvider.slotList[tsPosition].id;
            timeSlots.doctorId = int.parse(Constant.userID ?? "");
            timeSlots.startTime =
                addWorkSlotProvider.slotList[tsPosition].startTime;
            timeSlots.weekDay =
                addWorkSlotProvider.slotList[tsPosition].weekDay;
            timeSlots.endTime =
                addWorkSlotProvider.slotList[tsPosition].endTime;
            timeSlots.timeDuration = duration;
            if (addWorkSlotProvider.slotList.isNotEmpty) {
              timeSlots.tslPosition = addWorkSlotProvider.slotList.length;
            } else {
              timeSlots.tslPosition = 0;
            }
            timeSlots.timeSchedul = tempTimeScheduleList;

            addWorkSlotProvider.slotList.removeAt(tsPosition);
            addWorkSlotProvider.slotList.insert(tsPosition, timeSlots);
          }
        }
      }
    }
  }

  static Html htmlTexts(var strText) {
    return Html(
      data: strText,
      style: {
        "body": Style(
          color: otherColor,
          fontSize: FontSize(14),
          fontWeight: FontWeight.w500,
        ),
        "link": Style(
          color: colorPrimary,
          fontSize: FontSize(14),
          fontWeight: FontWeight.w500,
        ),
      },
      onLinkTap: (url, _, ___) async {
        printLog("htmlTexts url =========> $url");
        if (await canLaunchUrl(Uri.parse(url ?? ""))) {
          await launchUrl(
            Uri.parse(url ?? ""),
            mode: LaunchMode.platformDefault,
          );
        } else {
          throw 'Could not launch $url';
        }
      },
      shrinkWrap: false,
    );
  }

  static Future<String> getPrivacyTandCText(
      {required String privacyUrl, required String termsConditionUrl}) async {
    printLog('privacyUrl ==> $privacyUrl');
    printLog('T&C Url =====> $termsConditionUrl');

    String strPrivacyAndTNC =
        "<p> By continuing , I understand and agree with <a href=$privacyUrl>Privacy Policy</a> and"
        " <a href=$termsConditionUrl>Terms and Conditions</a> of ${Constant.appName}.</p>";

    printLog('strPrivacyAndTNC =====> $strPrivacyAndTNC');
    return strPrivacyAndTNC;
  }

  static Future<String> getTandCText(
      {required String termsConditionUrl}) async {
    printLog('T&C Url =====> $termsConditionUrl');

    String strTnC =
        "<p> I hereby read all the <a href=$termsConditionUrl>Terms and Conditions</a> above.</p>";

    printLog('strTnC =====> $strTnC');
    return strTnC;
  }

  static Future<String> openDatePicker(BuildContext context) async {
    try {
      DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime(2100));

      if (pickedDate != null) {
        printLog('$pickedDate');
        String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
        printLog(formattedDate);

        return formattedDate;
      } else {
        String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
        return formattedDate;
      }
    } catch (e) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return formattedDate;
    }
  }

  static Future<void> getCurrentLocation(Function onPickAddress) async {
    try {
      // Check if service is enabled
      String? area, city, state, country;
      double latitude = 0.0, longitude = 0.0;
      loc.Location location = loc.Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      // Check permissions
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw Exception('Location permissions are denied.');
        }
      }

      // Get current location
      loc.LocationData locData = await location.getLocation();

      // Convert latitude/longitude to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locData.latitude ?? 00,
        locData.longitude ?? 0.0,
      );

      if (placemarks.isNotEmpty) {
        // Placemark place = placemarks.first;

        // String address = [
        //   place.name,
        //   place.subLocality,
        //   place.locality,
        //   place.administrativeArea,
        //   place.country,
        //   place.postalCode,
        // ].where((e) => e != null && e.isNotEmpty).join(', ');
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;

          String address = [
            place.name, // Society/Flat name

            place.subLocality, // Area
            place.locality, // City
            place.administrativeArea, // State
            place.country, // Country
            place.postalCode // Pincode
          ]
              .where((element) => element != null && element.isNotEmpty)
              .join(', ');

          if (place.subLocality != null && place.subLocality != "") {
            area = place.subLocality;
          } else {
            area = place.locality;
          }

          city = place.locality;
          latitude = locData.latitude ?? 0.0;
          longitude = locData.longitude ?? 0.0;
          state = place.administrativeArea;
          country = place.country;
          Map<String, dynamic> addressMap = {
            'address': address,
            'latitude': latitude,
            'longitude': longitude,
            'city': city,
            'state': state,
            'country': country,
            'area': area
          };
          onPickAddress(addressMap);
        }
      } else {
        throw Exception('Failed to get address from coordinates.');
      }
    } catch (e) {
      Utils.showToast(e.toString());
    }
    // String? area, city, state, country;
    // double latitude = 0.0, longitude = 0.0;
    // try {
    //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //   if (!serviceEnabled) {
    //     await Geolocator.openLocationSettings();
    //     return;
    //   }

    //   LocationPermission permission = await Geolocator.checkPermission();
    //   if (permission == LocationPermission.denied) {
    //     permission = await Geolocator.requestPermission();
    //     if (permission == LocationPermission.denied) {
    //       throw Exception('Location permissions are denied.');
    //     }
    //   }

    //   if (permission == LocationPermission.deniedForever) {
    //     throw Exception('Location permissions are permanently denied.');
    //   }

    //   Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high,
    //   );

    //   List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude,
    //     position.longitude,
    //   );

    //   if (placemarks.isNotEmpty) {
    //     Placemark place = placemarks.first;

    //     String address = [
    //       place.name, // Society/Flat name

    //       place.subLocality, // Area
    //       place.locality, // City
    //       place.administrativeArea, // State
    //       place.country, // Country
    //       place.postalCode // Pincode
    //     ].where((element) => element != null && element.isNotEmpty).join(', ');

    //     if (place.subLocality != null && place.subLocality != "") {
    //       area = place.subLocality;
    //     } else {
    //       area = place.locality;
    //     }

    //     city = place.locality;
    //     latitude = position.latitude;
    //     longitude = position.longitude;
    //     state = place.administrativeArea;
    //     country = place.country;
    //     Map<String, dynamic> addressMap = {
    //       'address': address,
    //       'latitude': latitude,
    //       'longitude': longitude,
    //       'city': city,
    //       'state': state,
    //       'country': country,
    //       'area': area
    //     };
    //     onPickAddress(addressMap);
    //   } else {
    //     throw Exception('Failed to get address from coordinates.');
    //   }
    // } catch (e) {
    //   Utils.showToast(e.toString());
    // }
  }

  static Future<void> imagePickDialog(
      BuildContext context, Function onSelectImage) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                MyText(
                  text: "pick_image_note",
                  multilanguage: true,
                  color: black,
                  fontsize: Dimens.text18Size,
                  fontweight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: MyText(
                text: "pick_from_gallery",
                multilanguage: true,
                color: colorPrimaryDark,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.bold,
                textalign: TextAlign.center,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                File pickedImage = await getImageFromPhone(ImageSource.gallery);
                onSelectImage(pickedImage);
              },
            ),
            TextButton(
              child: MyText(
                text: "capture_by_camera",
                multilanguage: true,
                color: colorPrimaryDark,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.bold,
                textalign: TextAlign.center,
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                File pickedImage = await getImageFromPhone(ImageSource.camera);
                onSelectImage(pickedImage);
              },
            ),
            TextButton(
              child: MyText(
                text: "cancel",
                multilanguage: true,
                color: black,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.normal,
                textalign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Future<File> getImageFromPhone(ImageSource source) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? pickedFile = await imagePicker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        return File(pickedFile.path);
      } else {
        return File("");
      }
    } catch (e) {
      return File("");
    }
  }

  static bool isImageFromHttp(String imagePath) {
    return imagePath.startsWith('http') || imagePath.startsWith('https');
  }

  Future<bool> requestPermissions(
      BuildContext context, List<Permission> permissions) async {
    final Map<Permission, PermissionStatus> statuses =
        await permissions.request();

    bool allGranted = true;
    for (final permission in permissions) {
      if (statuses[permission]!.isPermanentlyDenied) {
        allGranted = false;

        if (context.mounted) {
          _showSettingsDialog(context, permission);
        }
        return false;
      } else if (!statuses[permission]!.isGranted) {
        allGranted = false;
      }
    }

    if (allGranted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<void> updateGeneralSettingData(
      BuildContext context, GeneralProvider generalsettingData) async {
    printLog(
        'Is generalsettingData loading...? ==> ${generalsettingData.loading}');
    if (!generalsettingData.loading) {
      printLog(
          'generalSettingData status ==> ${generalsettingData.generalSettingModel.status}');
      for (var i = 0;
          i < (generalsettingData.generalSettingModel.result?.length ?? 0);
          i++) {
        await SharedPre().save(
          generalsettingData.generalSettingModel.result?[i].key.toString() ??
              "",
          generalsettingData.generalSettingModel.result?[i].value.toString() ??
              "",
        );

        printLog(
            '${generalsettingData.generalSettingModel.result?[i].key.toString()} ==> ${generalsettingData.generalSettingModel.result?[i].value.toString()}');
      }
    }
  }

  void _showSettingsDialog(BuildContext context, Permission permission) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Required'),
          content: Text(
            'This app needs ${permission.toString().split('.').last} permission to function properly. '
            'Please go to the app settings and grant the permission manually.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Open Settings'),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
