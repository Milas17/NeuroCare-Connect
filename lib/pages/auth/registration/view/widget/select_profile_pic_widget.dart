// import 'dart:io';

// import 'package:yourappname/utils/utils.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:flutter/material.dart';

// import '../../../../../utils/app_image.dart';
// import '../../../../../utils/colors.dart';
// import '../../../../../utils/dimens.dart';
// import '../../../../../widgets/mytext.dart';

// class SelectProfilePicWidget extends StatelessWidget {
//   const SelectProfilePicWidget(
//       {super.key, required this.onImageSelect, required this.imagePath});
//   final Function onImageSelect;
//   final String imagePath;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         const SizedBox(height: 60,),
//         MyText(
//           text: "upload_picture",
//           multilanguage: true,
//           fontsize: Dimens.text24Size,
//           fontweight: FontWeight.w600,
//           color: colorPrimaryDark,
//         ),
//         const SizedBox(height: 20),
//         DottedBorder(
//           color: colorPrimaryDark,
//           borderType: BorderType.RRect,
//           radius: const Radius.circular(10),
//           dashPattern: const [2, 2],
//           strokeWidth: 2,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 margin: const EdgeInsets.all(8),
//                 height: 350,
//                 width: MediaQuery.of(context).size.width,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 clipBehavior: Clip.antiAlias,
//                 child: (imagePath != null && imagePath != "")
//                     ? Image.file(
//                         File(imagePath ?? ""),
//                         fit: BoxFit.cover,
//                         height: 350,
//                         width: MediaQuery.of(context).size.width,
//                       )
//                     : Image.asset(
//                         AppImage.profilePicBg,
//                         fit: BoxFit.cover,
//                       ),
//               ),
//               const SizedBox(height: 5),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           MyText(
//                             text: "upload_profile_picture",
//                             multilanguage: true,
//                             fontsize: Dimens.text16Size,
//                             fontweight: FontWeight.w500,
//                             color: textTitleColor,
//                           ),
//                           const SizedBox(height: 10),
//                           MyText(
//                             text: "13MB min - 20MB max",
//                             multilanguage: false,
//                             fontsize: Dimens.text14Size,
//                             fontweight: FontWeight.w500,
//                             color: grayDark,
//                           ),
//                         ],
//                       ),
//                     ),
//                     InkWell(
//                       onTap: () {
//                         Utils.imagePickDialog(context,
//                             (File selectedImage) async {
//                           int size = await selectedImage.length();
                
//                           if ((size / (1024 * 1024)) < 20) {
//                             onImageSelect(selectedImage);
//                           } else {
//                             Utils.showToast("Please select pic less than 20 MB");
//                           }
//                         });
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 16, horizontal: 19),
//                         decoration: BoxDecoration(
//                             color: colorPrimaryDark,
//                             borderRadius: BorderRadius.circular(8)),
//                         child: const Icon(
//                           Icons.add_rounded,
//                           color: white,
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(
//                 height: 5,
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
