// import 'package:yourappname/pages/auth/registration/provider/doctor_registration_provider.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl_phone_field/intl_phone_field.dart';

// import '../../../../../model/specialitymodel.dart';
// import '../../../../../utils/colors.dart';
// import '../../../../../utils/dimens.dart';
// import '../../../../../utils/strings.dart';
// import '../../../../../utils/utils.dart';
// import '../../../../../widgets/customtextformfield.dart';
// import '../../../../../widgets/mytext.dart';

// class CreateAccountWidget extends StatelessWidget {
//   const CreateAccountWidget({
//     super.key,
//     required this.nameController,
//     required this.emailController,
//     required this.contactController,
//     required this.addressController,
//     required this.practisingTenureController,
//     required this.dobController,
//     required this.doctorRegProvider,
//     required this.passwordController,
//     required this.consultationFeesController,
//     required this.specialityList,
//     required this.refreshSpecialityField,
//   });
//   final TextEditingController nameController;
//   final TextEditingController emailController;
//   final TextEditingController contactController;
//   final TextEditingController addressController;
//   final TextEditingController practisingTenureController;
//   final TextEditingController dobController;
//   final TextEditingController consultationFeesController;
//   final TextEditingController passwordController;
//   final DoctorRegistrationProvider doctorRegProvider;

//   final List<Speciality> specialityList;
//   final ValueNotifier<bool> refreshSpecialityField;
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         MyText(
//           text: "create_account",
//           multilanguage: true,
//           fontsize: Dimens.text24Size,
//           fontweight: FontWeight.w600,
//           color: colorPrimaryDark,
//         ),
//         const SizedBox(height: 20),
//         CustomTextFormField(
//           readOnly: false,
//           controller: nameController,
//           labelText: fullNameReq,
//           keyboardType: TextInputType.text,
//           textInputAction: TextInputAction.next,
//         ),
//         const SizedBox(height: 20),
//         CustomTextFormField(
//           readOnly: false,
//           controller: emailController,
//           labelText: emailAddressReq,
//           keyboardType: TextInputType.emailAddress,
//           textInputAction: TextInputAction.next,
//         ),
//         const SizedBox(height: 20),
//         SizedBox(
//           height: 55,
//           child: IntlPhoneField(
//             disableLengthCheck: true,
//             textAlignVertical: TextAlignVertical.center,
//             autovalidateMode: AutovalidateMode.disabled,
//             controller: contactController,
//             style: Utils.googleFontStyle(
//                 1, 16, FontStyle.normal, black, FontWeight.w500),
//             showCountryFlag: false,
//             showDropdownIcon: false,
//             initialCountryCode: "IN",
//             dropdownTextStyle: Utils.googleFontStyle(
//                 1, 16, FontStyle.normal, black, FontWeight.w500),
//             keyboardType: TextInputType.number,
//             textInputAction: TextInputAction.done,
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: white,
//               border: InputBorder.none,
//               labelStyle: Utils.googleFontStyle(
//                 1,
//                 14,
//                 FontStyle.normal,
//                 black,
//                 FontWeight.w500,
//               ),
//               hintText: "enteryourmobilenumber",
//               enabledBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                 borderSide: BorderSide(color: grayDark, width: 1),
//               ),
//               focusedBorder: const OutlineInputBorder(
//                 borderRadius: BorderRadius.all(Radius.circular(4.0)),
//                 borderSide: BorderSide(color: grayDark, width: 1),
//               ),
//             ),
//             onChanged: (phone) {
//               printLog('phone===> ${phone.completeNumber}');
//               printLog('number===> ${contactController.text}');
//             },
//             onCountryChanged: (country) {
//               doctorRegProvider.countryCode = "+${country.dialCode.toString()}";
//               doctorRegProvider.countryName = country.name.toString();
//             },
//           ),
//         ),
//         const SizedBox(height: 20),
//         Row(
//           children: [
//             Expanded(
//               child: CustomTextFormField(
//                 readOnly: false,
//                 controller: addressController,
//                 labelText: address,
//                 keyboardType: TextInputType.emailAddress,
//                 textInputAction: TextInputAction.next,
//               ),
//             ),
//             const SizedBox(
//               width: 10,
//             ),
//             InkWell(
//               onTap: () {
//                 Utils.getCurrentLocation((Map<String, dynamic> address) {
//                   if (address != null && address is Map<String, dynamic>) {
//                     addressController.text = address['address'];
//                     doctorRegProvider.latitude = address['latitude'].toString();
//                     doctorRegProvider.longitude =
//                         address['longitude'].toString();
//                     doctorRegProvider.city = address['city'];
//                     doctorRegProvider.state = address['state'];
//                     doctorRegProvider.country = address['country'];
//                     doctorRegProvider.area = address['area'];
//                   }
//                 });
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     color: colorPrimaryDark),
//                 padding: const EdgeInsets.fromLTRB(10, 13, 10, 13),
//                 child: MyText(
//                   text: "current_location",
//                   multilanguage: true,
//                   fontsize: Dimens.text13Size,
//                   fontweight: FontWeight.w400,
//                   color: white,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 15),
//         specialityList.isEmpty
//             ? const SizedBox.shrink()
//             : DropdownButtonFormField2(
//                 isExpanded: true,
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(4),
//                     borderSide: const BorderSide(color: black, width: 0.5),
//                   ),
//                 ),
//                 value: specialityList.first.id,
//                 onChanged: (newValue) {
//                   doctorRegProvider.specialityId = newValue.toString();
//                 },
//                 hint: MyText(
//                   text: "speciality",
//                   multilanguage: true,
//                   fontsize: Dimens.text16Size,
//                   fontweight: FontWeight.normal,
//                   fontstyle: FontStyle.normal,
//                   textalign: TextAlign.start,
//                   color: black,
//                 ),
//                 items: specialityList
//                     .toSet()
//                     .map<DropdownMenuItem<int>>((Speciality value) {
//                   return DropdownMenuItem<int>(
//                     value: value.id,
//                     child: MyText(
//                       text: value.name ?? "",
//                       fontsize: Dimens.text15Size,
//                       fontweight: FontWeight.normal,
//                       fontstyle: FontStyle.normal,
//                       textalign: TextAlign.start,
//                       color: black,
//                     ),
//                   );
//                 }).toList(),
//               ),
//         const SizedBox(height: 20),
//         CustomTextFormField(
//           readOnly: false,
//           controller: practisingTenureController,
//           labelText: practisingTenure,
//           keyboardType: TextInputType.phone,
//           textInputAction: TextInputAction.next,
//         ),
//         const SizedBox(height: 20),
//         TextFormField(
//           onTap: () async {
//             String selectedDate = await Utils.openDatePicker(context);
//             dobController.text = selectedDate;
//           },
//           controller: dobController,
//           keyboardType: TextInputType.text,
//           textInputAction: TextInputAction.done,
//           obscureText: false,
//           maxLines: 1,
//           readOnly: true,
//           decoration: InputDecoration(
//             suffix: IconButton(
//               onPressed: () {},
//               icon: const Icon(
//                 Icons.calendar_month,
//                 size: 25,
//                 color: gray,
//               ),
//             ),
//             labelText: "Birth Date",
//             contentPadding: const EdgeInsets.only(left: 10),
//             labelStyle: GoogleFonts.roboto(
//               fontSize: 16,
//               color: black,
//               fontWeight: FontWeight.w400,
//               fontStyle: FontStyle.normal,
//             ),
//             border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(4),
//                 borderSide: const BorderSide(color: black, width: 0.5)),
//           ),
//           style: GoogleFonts.roboto(
//             textStyle: const TextStyle(
//               fontSize: 18,
//               color: black,
//               fontWeight: FontWeight.w400,
//               fontStyle: FontStyle.normal,
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//         CustomTextFormField(
//           readOnly: false,
//           controller: consultationFeesController,
//           labelText: feesReq,
//           keyboardType: TextInputType.number,
//           textInputAction: TextInputAction.next,
//         ),
//       ],
//     );
//   }
// }
