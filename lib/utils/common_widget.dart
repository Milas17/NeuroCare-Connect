import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:flutter/widgets.dart';

import '../widgets/mytext.dart';

class AppBottomCommonButton extends StatelessWidget {
  const AppBottomCommonButton(
      {super.key,
      required this.btnTitle,
      required this.onBtnTap,
      this.multilanguage = true,
      this.padding,
      this.fontSize = 15,
      this.fontWeight = FontWeight.w500,
      this.border,
      this.textColor = white,
      this.bgColor = colorPrimaryDark,
      this.borderRadius = 8,
      this.isPrefixImage = false,
      this.prefixPath,
      this.width,
      this.height,
      this.type,
      this.margin});

  final String btnTitle;
  final VoidCallback onBtnTap;
  final bool multilanguage;
  final Color textColor;
  final FontWeight fontWeight;
  final double fontSize;
  final Color bgColor;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxBorder? border;
  final bool isPrefixImage;
  final String? prefixPath;
  final double? width;
  final double? height;
  final int? type;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onBtnTap.call();
      },
      child: Container(
        margin: margin,
        height: height ?? Dimens.buttonHeight,
        alignment: Alignment.center,
        width: width ?? MediaQuery.of(context).size.width,
        padding: padding ?? const EdgeInsets.fromLTRB(0, 10, 0, 10),
        decoration: BoxDecoration(
            border: border,
            color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius)),
        child: isPrefixImage
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    prefixPath ?? '',
                    height: fontSize + 5,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  MyText(
                    text: btnTitle,
                    fontsize: fontSize,
                    multilanguage: multilanguage,
                    color: textColor,
                    fontweight: fontWeight,
                    type: type,
                  )
                ],
              )
            : MyText(
                text: btnTitle,
                fontsize: fontSize,
                multilanguage: multilanguage,
                color: textColor,
                fontweight: fontWeight,
                type: type,
              ),
      ),
    );
  }
}
