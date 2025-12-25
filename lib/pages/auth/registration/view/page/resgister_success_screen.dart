// import 'package:yourappname/utils/app_image.dart';
// import 'package:yourappname/utils/colors.dart';
// import 'package:yourappname/utils/common_widget.dart';
// import 'package:yourappname/widgets/mytext.dart';
// import 'package:flutter/material.dart';

// import '../../../../../utils/dimens.dart';

// class ResgisterSuccessScreen extends StatelessWidget {
//   const ResgisterSuccessScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: mainBody(),
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.all(Dimens.appCommonPadding),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             AppBottomCommonButton(btnTitle: 'continue_to_kyc', onBtnTap: () {}),
//             const SizedBox(
//               height: 24,
//             ),
//             Row(
//               spacing: 4,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 MyText(
//                   text: 'continue_to_kyc',
//                   fontsize: Dimens.text14Size,
//                   fontweight: FontWeight.w400,
//                   color: grayDark,
//                   multilanguage: true,
//                 ),
//                 MyText(
//                   text: 'learn_more',
//                   fontsize: Dimens.text14Size,
//                   fontweight: FontWeight.w400,
//                   color: colorPrimary,
//                   multilanguage: true,
//                 ),
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   Widget mainBody() {
//     return Padding(
//       padding: EdgeInsets.all(Dimens.appCommonPadding),
//       child: Column(
//         spacing: 16,
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Image.asset(
//             AppImage.resgisterSuccessImg,
//             width: 60,
//             height: 60,
//           ),
//           MyText(
//             text: 'great',
//             fontsize: Dimens.text24Size,
//             fontweight: FontWeight.w600,
//             color: colorPrimaryDark,
//             multilanguage: true,
//           ),
//           MyText(
//             text: 'complete_kyc_msg',
//             fontsize: Dimens.text16Size,
//             fontweight: FontWeight.w400,
//             color: grayDark,
//             multilanguage: true,
//             textalign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }
