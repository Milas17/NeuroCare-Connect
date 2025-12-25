import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widgets/myimage.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';

class NoData extends StatelessWidget {
  final String text;
  const NoData({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: transparent,
        borderRadius: BorderRadius.circular(12),
        shape: BoxShape.rectangle,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MyImage(
            height: 150,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.contain,
            imagePath: "nodata.png",
          ),
          if (text.isNotEmpty) const SizedBox(height: 10),
          if (text.isNotEmpty)
            MyText(
              color: grayDark,
              text: text,
              textalign: TextAlign.center,
              fontsize: Dimens.text14Size,
              multilanguage: true,
              maxline: 1,
              fontweight: FontWeight.w500,
              overflow: TextOverflow.ellipsis,
              fontstyle: FontStyle.normal,
            ),
        ],
      ),
    );
  }
}
