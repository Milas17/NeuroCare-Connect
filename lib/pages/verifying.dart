import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';

class Verifying extends StatefulWidget {
  const Verifying({super.key});

  @override
  State<Verifying> createState() => _VerifyingState();
}

class _VerifyingState extends State<Verifying> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: MyImage(
                width: 70,
                height: 70,
                imagePath: "verifying.png",
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            MyText(
              text: "we_are_verifying",
              multilanguage: true,
              color: colorPrimaryDark,
              textalign: TextAlign.center,
              fontsize: Dimens.text24Size,
              fontweight: FontWeight.w600,
            ),
            const SizedBox(
              height: 20,
            ),
            MyText(
              text:
                  "varifysubtitle",
              multilanguage: true,
              color: grayDark,
              maxline: 5,
              textalign: TextAlign.center,
              fontsize: Dimens.text17Size,
              fontweight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
