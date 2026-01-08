import 'dart:async';

import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/fulleditprofilepage.dart';
import 'package:yourappname/pages/intro.dart';
import 'package:yourappname/pages/loginselect.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  String? seen;
  late GeneralProvider generalProvider;
  SharedPre sharedPre = SharedPre();
  dynamic userid;
  dynamic firebaseid;
  @override
@override
void initState() {
  super.initState(); // Toujours appeler super.initState() en premier
  generalProvider = Provider.of<GeneralProvider>(context, listen: false);
  
  // 1. On lance le check en arrière-plan sans "await"
  isFirstCheck(); 

  // 2. FORCE : On navigue après 3 secondes quoi qu'il arrive
  Future.delayed(const Duration(seconds: 3), () {
    if (mounted) {
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => const Loginselect()),
       );
    }
  });
}

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: MyImage(
        imagePath: "splash.png",
        fit: BoxFit.fill,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
      ),
    );
  }

  Future<void> isFirstCheck() async {
    await generalProvider.getGeneralsetting(context);
    await generalProvider.getOnboardingScreen();

    printLog(
        'Is generalsettingData loading...? ==> ${generalProvider.loading}');
    if (!generalProvider.loading) {
      printLog(
          'generalSettingData status ==> ${generalProvider.generalSettingModel.status}');
      for (var i = 0;
          i < (generalProvider.generalSettingModel.result?.length ?? 0);
          i++) {
        await sharedPre.save(
          generalProvider.generalSettingModel.result?[i].key.toString() ?? "",
          generalProvider.generalSettingModel.result?[i].value.toString() ?? "",
        );
        printLog(
            '${generalProvider.generalSettingModel.result?[i].key.toString()} ==> ${generalProvider.generalSettingModel.result?[i].value.toString()}');
      }

      seen = await sharedPre.read('seen') ?? "";
      printLog('seen ==> $seen');
      String isEdit = await sharedPre.read("isEdit") ?? "";

      userid = await sharedPre.read('userid') ?? "";

      if (seen == "1") {
        if (Constant.userID != "") {
          if (!mounted) return;
          if (isEdit == "1") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const BottomBar();
                },
              ),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const FullEditProfile();
                },
              ),
            );
          }
        } else {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Loginselect();
              },
            ),
          );
        }
      } else {
        if (!mounted) return;
        if ((generalProvider.onboardingModel.status == 200) &&
            generalProvider.onboardingModel.result != null &&
            (generalProvider.onboardingModel.result?.length ?? 0) > 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return Intro(
                  introList: generalProvider.onboardingModel.result ?? const [],
                );
              },
            ),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return const Loginselect();
              },
            ),
          );
        }
      }
    }
  }
}
