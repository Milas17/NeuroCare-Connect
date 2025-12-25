// import 'dart:io';

// import 'package:yourappname/model/specialitymodel.dart';
// import 'package:yourappname/pages/auth/registration/view/page/resgister_success_screen.dart';
// import 'package:yourappname/utils/dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_locales/flutter_locales.dart';
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
// import 'package:progress_stepper/progress_stepper.dart';
// import 'package:provider/provider.dart';

// import '../../../../../provider/generalprovider.dart';
// import '../../../../../utils/colors.dart';
// import '../../../../../utils/common_widget.dart';
// import '../../../../../utils/navigation_manager.dart';
// import '../../../../../utils/utils.dart';
// import '../../provider/doctor_registration_provider.dart';
// import '../widget/create_account_widget.dart';
// import '../widget/create_password_widget.dart';
// import '../widget/select_profile_pic_widget.dart';

// class DoctorRegistrationScreen extends StatefulWidget {
//   const DoctorRegistrationScreen({super.key});

//   @override
//   State<DoctorRegistrationScreen> createState() =>
//       _DoctorRegistrationScreenState();
// }

// class _DoctorRegistrationScreenState extends State<DoctorRegistrationScreen> {
//   //password field

//   //Page Count
//   ValueNotifier<int> pageCount = ValueNotifier(1);
//   ValueNotifier<bool> refreshSpecialityField = ValueNotifier(false);
//   ValueNotifier<bool> refreshProfileWidget = ValueNotifier(false);
//   List<Speciality> specialityList = [];

  
//   //textField controller
//   TextEditingController nameController = TextEditingController(text: "fadas");
//   TextEditingController emailController =
//       TextEditingController(text: "mit@yopmail.com");
//   TextEditingController contactController =
//       TextEditingController(text: "342343434");
//   TextEditingController addressController =
//       TextEditingController(text: "fadas");
//   TextEditingController practisingTenureController =
//       TextEditingController(text: "fadas");
//   TextEditingController dobController = TextEditingController(text: "2001-09-02");
//   TextEditingController passwordController =
//       TextEditingController(text: "fadas");
//   TextEditingController consultationFeesController =
//       TextEditingController(text: "150");

//   TextEditingController reTypePassController = TextEditingController();

//   //Screen loader
//   late ProgressDialog prDialog;
//   //Provider
//   late GeneralProvider generalProvider;
//   late DoctorRegistrationProvider doctorRegistrationProvider;
//   @override
//   void initState() {
//     generalProvider = Provider.of<GeneralProvider>(context, listen: false);
//     doctorRegistrationProvider =
//         Provider.of<DoctorRegistrationProvider>(context, listen: false);

//     prDialog = ProgressDialog(context);
//     init();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     contactController.dispose();
//     addressController.dispose();
//     practisingTenureController.dispose();
//     dobController.dispose();
//     consultationFeesController.dispose();
//     reTypePassController.dispose();
//     doctorRegistrationProvider.clear();
//     passwordController.dispose();
//     super.dispose();
//   }

//   init() async {
//     // specialityList = await generalProvider.getSpecialities();

//     doctorRegistrationProvider.specialityId = specialityList.first.id.toString() ?? "0";
//     refreshSpecialityField.value = !refreshSpecialityField.value;
//     await doctorRegistrationProvider.getDeviceToken();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: Utils.myAppBarWithBack(context, "signup", true, true),
//       body: Padding(
//         padding: EdgeInsets.all(Dimens.appCommonPadding),
//         child: ValueListenableBuilder(
//             valueListenable: pageCount,
//             builder: (context, value, child) => AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 250),
//                   transitionBuilder: (child, animation) {
//                     return ScaleTransition(scale: animation, child: child);
//                   },
//                   child: mainBody(),
//                 )),
//       ),
//       bottomNavigationBar: Padding(
//         padding: EdgeInsets.all(Dimens.appCommonPadding),
//         child: ValueListenableBuilder(
//             valueListenable: pageCount,
//             builder: (context, currentStep, child) => Column(
//                   spacing: 10,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     buildBottomNavButton(),
//                     ProgressStepper(
//                       bluntTail: false,
//                       bluntHead: false,
//                       builder: (context, index, width) {
//                         return Container(
//                           margin: const EdgeInsets.only(right: 20),
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(25),
//                               color: index < currentStep
//                                   ? colorPrimary
//                                   : colorAccent),
//                         );
//                       },
//                       height: 10,
//                       borderColor: transparent,
//                       width: MediaQuery.of(context).size.width,
//                       currentStep: currentStep,
//                       padding: 0,
//                       stepCount: 3,
//                     )
//                   ],
//                 )),
//       ),
//     );
//   }

//   Widget mainBody() {
//     return buildRegistrationPages();
//   }

//   Widget buildRegistrationPages() {
//     if (pageCount.value == 1) {
//       return ValueListenableBuilder(
//         valueListenable: refreshSpecialityField,
//         builder: (context, value, child) => CreateAccountWidget(
//           addressController: addressController,
//           consultationFeesController: consultationFeesController,
//           contactController: contactController,
//           dobController: dobController,
//           doctorRegProvider: doctorRegistrationProvider,
//           emailController: emailController,
//           nameController: nameController,
//           passwordController: passwordController,
//           practisingTenureController: practisingTenureController,
//           specialityList: specialityList,
//           refreshSpecialityField: refreshSpecialityField,
//         ),
//       );
//     } else if (pageCount.value == 2) {
//       return ValueListenableBuilder(
//         valueListenable: refreshProfileWidget,
//         builder: (context, value, child) => SelectProfilePicWidget(
//           onImageSelect: (File selectedFile) {
//             doctorRegistrationProvider.imagePath = selectedFile.path;
//             refreshProfileWidget.value = !refreshProfileWidget.value;
//           },
//           imagePath: doctorRegistrationProvider.imagePath ?? "",
//         ),
//       );
//     } else {
//       return CreatePasswordWidget(
//         passwordController: passwordController,
//         reTypePassController: reTypePassController,
//       );
//     }
//   }

//   Widget buildBottomNavButton() {
//     if (pageCount.value == 1) {
//       return AppBottomCommonButton(
//         btnTitle: 'create_account',
//         onBtnTap: () {
//           doctorRegistrationProvider.fieldValidation(
//             address: addressController.text.trim(),
//             contact: contactController.text.trim(),
//             dob: dobController.text.trim(),
//             email: emailController.text.trim(),
//             fees: consultationFeesController.text.trim(),
//             name: nameController.text.trim(),
//             pracTenure: practisingTenureController.text.trim(),
//             onSucess: () {
//               pageCount.value++;
//             },
//           );
//         },
//       );
//     } else {
//       return Row(
//         spacing: 10,
//         children: [
//           Expanded(flex: 2, child: backBtnWidget()),
//           pageCount.value == 2
//               ? ValueListenableBuilder(
//                   valueListenable: refreshProfileWidget,
//                   builder: (context, value, child) => Expanded(
//                     flex: 8,
//                     child: AppBottomCommonButton(
//                       bgColor: (doctorRegistrationProvider.imagePath == null ||
//                               doctorRegistrationProvider.imagePath == "")
//                           ? grayLight
//                           : colorPrimaryDark,
//                       btnTitle: 'save_picture',
//                       textColor:
//                           (doctorRegistrationProvider.imagePath == null ||
//                                   doctorRegistrationProvider.imagePath == "")
//                               ? grayDark
//                               : white,
//                       onBtnTap: () {
//                         if ((doctorRegistrationProvider.imagePath != null &&
//                             doctorRegistrationProvider.imagePath != "")) {
//                           pageCount.value++;
//                         } else {
//                           Utils.showToast(
//                               "Please select  your profile picture.");
//                         }
//                       },
//                     ),
//                   ),
//                 )
//               : Expanded(
//                   flex: 8,
//                   child: AppBottomCommonButton(
//                     btnTitle: 'set_password',
//                     onBtnTap: () async {
//                       if (passwordController.text.trim().isNotEmpty &&
//                           reTypePassController.text.trim().isNotEmpty) {
//                         if (passwordController.text.trim() !=
//                             reTypePassController.text.trim()) {
//                           String msg =
//                               Locales.string(context, 'password_not_match');
//                           Utils.showToast(msg);
//                         } else {
//                           //Start User Registration Process
//                           await prDialog.show();
//                           await doctorRegistrationProvider.firebaseRegister(
//                               email: emailController.text.trim(),
//                               password: passwordController.text.trim(),
//                               mobile: contactController.text.trim(),
//                               fullName: nameController.text.trim(),
//                               fees: consultationFeesController.text.trim(),
//                               practiceTenure:
//                                   practisingTenureController.text.trim(),
//                               dob: dobController.text.trim(),
//                               generalProvider: generalProvider);
//                           await prDialog.hide();
//                           if (doctorRegistrationProvider.success) {
//                             _navigateToKYCDetails();
//                           }
//                         }
//                       } else {
//                         Utils.showToast("Please fill all fields");
//                       }
//                     },
//                   ),
//                 )
//         ],
//       );
//     }
//   }

//   Widget backBtnWidget() {
//     return GestureDetector(
//       onTap: () {
//         pageCount.value--;
//       },
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         height: Dimens.buttonHeight,
//         decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: colorPrimaryDark, width: 1)),
//         child: const Icon(
//           Icons.arrow_back_rounded,
//           size: 25,
//           color: colorPrimaryDark,
//         ),
//       ),
//     );
//   }

//   _navigateToKYCDetails() async {
//     await navigateToPage(context: context, route: ResgisterSuccessScreen());
//   }
// }
