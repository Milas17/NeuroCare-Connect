// import 'package:flutter/material.dart';

// import '../../../../../utils/colors.dart';
// import '../../../../../utils/dimens.dart';
// import '../../../../../utils/strings.dart';
// import '../../../../../widgets/customtextformfield.dart';
// import '../../../../../widgets/mytext.dart';

// class CreatePasswordWidget extends StatefulWidget {
//   const CreatePasswordWidget(
//       {super.key,
//       required this.passwordController,
//       required this.reTypePassController});

//   final TextEditingController passwordController;
//   final TextEditingController reTypePassController;
//   @override
//   State<CreatePasswordWidget> createState() => _CreatePasswordWidgetState();
// }

// class _CreatePasswordWidgetState extends State<CreatePasswordWidget> {
//   bool passwordVisible = true;
//   bool reTypePassVisible = true;

//   ValueNotifier<bool> refreshPassword = ValueNotifier(false);
//   ValueNotifier<bool> refreshRetypePassword = ValueNotifier(false);

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const SizedBox(
//           height: 60,
//         ),
//         MyText(
//           text: "create_password",
//           multilanguage: true,
//           fontsize: Dimens.text24Size,
//           fontweight: FontWeight.w600,
//           color: colorPrimaryDark,
//         ),
//         const SizedBox(height: 20),
//         ValueListenableBuilder(
//           valueListenable: refreshPassword,
//           builder: (context, value, child) => CustomTextFormField(
//             readOnly: false,
//             controller: widget.passwordController,
//             labelText: password,
//             keyboardType: TextInputType.visiblePassword,
//             obscureText: passwordVisible,
//             suffixIcon: Icon(
//               passwordVisible ? Icons.visibility : Icons.visibility_off,
//               color: otherColor,
//             ),
//             onSuffixIconPressed: () {
//               passwordVisible = !passwordVisible;
//               refreshPassword.value = !refreshPassword.value;
//             },
//           ),
//         ),
//         const SizedBox(height: 20),
//         ValueListenableBuilder(
//           valueListenable: refreshRetypePassword,
//           builder: (context, value, child) => CustomTextFormField(
//             readOnly: false,
//             controller: widget.reTypePassController,
//             labelText: reTypePassword,
//             keyboardType: TextInputType.visiblePassword,
//             obscureText: reTypePassVisible,
//             suffixIcon: Icon(
//               reTypePassVisible ? Icons.visibility : Icons.visibility_off,
//               color: otherColor,
//             ),
//             onSuffixIconPressed: () {
//               reTypePassVisible = !reTypePassVisible;
//               refreshRetypePassword.value = !refreshRetypePassword.value;
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
