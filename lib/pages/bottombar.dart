import 'dart:developer';

import 'package:yourappname/pages/allappointmentf.dart';
import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/homef.dart';
import 'package:yourappname/pages/inbox.dart';
import 'package:yourappname/pages/menu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/entypo.dart';
import 'package:iconify_flutter/icons/heroicons_solid.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

import '../utils/dimens.dart';
import '../widgets/mytext.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  DateTime? currentBackPressTime;
  int currentIndex = 0;
  final widgetOptions = [
    const HomeF(),
    const AllAppointmentF(),
    const Inbox(),
    const Menu()
  ];
  @override
  void initState() {
    super.initState();

    if (!kIsWeb) {
      OneSignal.Notifications.requestPermission(true);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
    }
    OneSignal.Notifications.addClickListener(_handleNotificationOpened);
  }

  _handleNotificationOpened(OSNotificationClickEvent result) async {
    log("* ======== Notification opened at home ======== *");
    log("Notification Raw Payload =========> ${result.notification.rawPayload}");

    // Extract data
    String alert = result.notification.rawPayload?['alert'] ?? "";
    String title = result.notification.rawPayload?['title'] ?? "";

    log("Notification Messagge =========> $alert");

    // 🔍 Extract Room ID (for video calls)
    final roomIdMatch = RegExp(r'ROOM\d+').firstMatch(alert);
    final roomId = roomIdMatch?.group(0) ?? "0";

    // 🔍 Extract Appointment ID (for prescription or appointment updates)
    final appointmentIdMatch = RegExp(
      r'appointment\s*id\s*[:\-]?\s*(\d+)',
      caseSensitive: false,
    ).firstMatch(alert);

    final appointmentId = appointmentIdMatch?.group(1) ?? "0";

    // 🔍 Extract Type from title (if available)
    String type = "";
    final typeMatch = RegExp(r'\(Type\s*:\s*([^)]+)\)').firstMatch(title);
    if (typeMatch != null) {
      type = typeMatch.group(1)?.trim() ?? "";
    }

    log("Notification Title =========> $title");
    log("Notification Type =========> $type");
    log("Notification Room Id =========> $roomId");
    log("Notification Appointment Id =========> $appointmentId");

    if (!mounted) return;

    // 📄 Handle Appointment or Prescription Notification
    if (type == "profile-update") {
      printLog("Profile Notification =================");
      if (!mounted) return;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BottomBar(
              // currentIndex: 3,
              ),
        ),
      );

      // 🚫 Fallback (no IDs found)
    } else if (appointmentId.isNotEmpty && appointmentId != "0") {
      printLog("Appointment Notification =================");
      if (!mounted) return;
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppointmentDetails(
            appointmentId,
          ),
        ),
      );

      // 🚫 Fallback (no IDs found)
    } else {
      Utils.showToast("Unable to identify notification details");
    }
  }

  // _handleNotificationOpened(OSNotificationClickEvent result) async {
  //   //  Wait 5 seconds before handling notification
  //   // await Future.delayed(const Duration(seconds: 5));
  //   // generalProvider.notifyListener();

  //   printLog("* ======== Notification opened at home ======== *");
  //   printLog(
  //       "Notification Raw Payload =========> ${result.notification.rawPayload}");

  //   // Extract Room ID or any identifier needed for navigation
  //   String alert = result.notification.rawPayload?['alert'] ?? "";
  //   final roomIdMatch = RegExp(r'ROOM\d+').firstMatch(alert);
  //   final roomId = roomIdMatch?.group(0) ?? "0";

  //   printLog("Notification Room Id =========> $roomId");

  //   // Check for necessary permissions (camera & microphone)
  //   // if (!mounted) return;

  //   // bool isPermissionGranted = await Utils().requestPermissions(
  //   //     context, [Permission.camera, Permission.microphone]);

  //     printLog("Appointment Notification =================");
  //     if (!mounted) return;
  //     return Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => const AppointmentDetails(
  //           "148", // Appointment ID
  //         ),
  //       ),
  //     );

  //   // if (roomId.isNotEmpty && roomId != "0") {
  //   //   printLog("VideoCall Notification =================");
  //   //   printLog("is Permission Granted ? ===> $isPermissionGranted");
  //   //   if (isPermissionGranted) {
  //   //     if (!mounted) return;
  //   //     return Navigator.push(
  //   //       context,
  //   //       MaterialPageRoute(
  //   //         builder: (context) => VideoCallScreen(
  //   //           roomId: roomId,
  //   //           userId: "patient_14${Constant.userID}",
  //   //         ),
  //   //       ),
  //   //     );
  //   //   } else {
  //   //     Utils.showToast("Please grant the necessary permissions");
  //   //   }
  //   // } else {
  //   //   // await Future.delayed(const Duration(seconds: 5));

  //   //   printLog("Appointment Notification =================");
  //   //   if (!mounted) return;
  //   //   return Navigator.push(
  //   //     context,
  //   //     MaterialPageRoute(
  //   //       builder: (context) => const AppointmentDetails(
  //   //         "148", // Appointment ID
  //   //       ),
  //   //     ),
  //   //   );
  //   //   // Utils.showToast("Room ID not found in notification");
  //   // }
  // }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        onBackPressed(didPop);
      },
      child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Center(
            child: widgetOptions[currentIndex],
          ),
          bottomNavigationBar: SafeArea(child: bottomNavBar())
          // Container(
          //   color: white,
          //   padding:
          //       const EdgeInsets.only(left: 10.0, right: 10, top: 20, bottom: 20),
          //   child: ClipRRect(
          //     borderRadius: BorderRadius.circular(20),
          //     child: BubbleNavigationBar(
          //       labelStyle:
          //           const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          //       backgroundColor: colorPrimary,
          //       selectedItemColor: white,
          //       unselectedItemColor: white,
          //       currentIndex: currentIndex,
          //       onIndexChanged: (value) {
          //         printLog('$value');
          //         _onItemTapped(value);
          //       },
          //       items: const [
          //         BubbleNavItem(
          //           icon: Iconify(
          //             Ph.squares_four,
          //             color: white,
          //           ),
          //           label: 'Dashboard',
          //         ),
          //         BubbleNavItem(
          //           icon: Iconify(color: white, HeroiconsSolid.rectangle_stack),
          //           label: 'Appointments',
          //         ),
          //         BubbleNavItem(
          //           icon: Iconify(
          //             Ph.chat_circle_text_bold,
          //             color: white,
          //           ),
          //           label: 'chat',
          //         ),
          //         BubbleNavItem(
          //           icon: Iconify(
          //             Entypo.menu,
          //             color: white,
          //           ),
          //           label: 'Menu',
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          ),
    );
  }

  Widget bottomNavBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Container(
        color: transparent,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: StylishBottomBar(
                notchStyle: NotchStyle.square,
                option: BubbleBarOptions(
                    barStyle: BubbleBarStyle.horizontal,
                    iconSize: 24,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    borderRadius: BorderRadius.circular(12)),
                items: [
                  BottomBarItem(
                      icon: const Iconify(
                        Ph.squares_four,
                        color: white,
                      ),
                      title: MyText(
                        text: 'dashboard',
                        fontsize: Dimens.text14Size,
                        fontweight: FontWeight.w600,
                        multilanguage: true,
                        color: white,
                      ),
                      backgroundColor: navBarLight,
                      selectedColor: white, // Selected icon color
                      unSelectedColor: white),
                  // The 'Appointments' button
                  BottomBarItem(
                    icon: const Iconify(
                      HeroiconsSolid.rectangle_stack,
                      color: white,
                    ),
                    title: MyText(
                      text: 'appointments',
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.w600,
                      multilanguage: true,
                      color: white,
                    ),
                    backgroundColor: navBarLight,
                    selectedColor: white, // Selected icon color
                    unSelectedColor: white,
                  ),
                  // The chat icon
                  BottomBarItem(
                      icon: const Iconify(
                        Ph.chat_circle_text_bold,
                        color: white,
                      ),
                      title: MyText(
                        text: 'chatlower',
                        fontsize: Dimens.text14Size,
                        fontweight: FontWeight.w600,
                        multilanguage: true,
                        color: white,
                        textalign: TextAlign.left,
                      ),
                      backgroundColor: navBarLight,
                      selectedColor: white, // Selected icon color
                      unSelectedColor: white),
                  // The menu icon on the right
                  BottomBarItem(
                      icon: const Iconify(
                        Entypo.menu,
                        color: white,
                      ),
                      title: MyText(
                        text: 'menu',
                        fontsize: Dimens.text14Size,
                        fontweight: FontWeight.w600,
                        multilanguage: true,
                        color: white,
                        textalign: TextAlign.left,
                      ),
                      backgroundColor: navBarLight,
                      selectedColor: white, // Selected icon color
                      unSelectedColor: white),
                ],
                currentIndex: currentIndex,
                onTap: (index) {
                  _onItemTapped(index);
                },
                hasNotch: true,
                backgroundColor: colorPrimary)),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  Future<void> onBackPressed(didPop) async {
    if (didPop) return;
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Utils.showSnackbar(context, "pressbackagaintoexit", true);
      return;
    }
    SystemNavigator.pop();
  }
}
