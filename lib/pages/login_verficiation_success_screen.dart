import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/utils/app_image.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/navigation_manager.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';

import '../../../../../utils/dimens.dart';

class ResgisterSuccessScreen extends StatefulWidget {
  const ResgisterSuccessScreen({super.key});

  @override
  State<ResgisterSuccessScreen> createState() => _ResgisterSuccessScreenState();
}

class _ResgisterSuccessScreenState extends State<ResgisterSuccessScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3), () async {
      if (!mounted) return;
      await navigateToPageRemoveAllPage(
          context: context, route: const BottomBar());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mainBody(),
    );
  }

  Widget mainBody() {
    return Padding(
      padding: EdgeInsets.all(Dimens.appCommonPadding),
      child: Center(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              AppImage.successTickImage,
              width: 120,
              height: 120,
            ),
            MyText(
              text: 'phone_number_verified',
              fontsize: Dimens.text24Size,
              fontweight: FontWeight.w600,
              color: colorPrimaryDark,
              multilanguage: true,
              textalign: TextAlign.center,
            ),
            MyText(
              text: 'redirect_main_page',
              fontsize: Dimens.text16Size,
              fontweight: FontWeight.w400,
              color: grayDark,
              multilanguage: true,
              textalign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
