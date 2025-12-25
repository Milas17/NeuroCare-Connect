// import 'package:autocomplete_textfield/autocomplete_textfield.dart';
// import 'package:yourappname/utils/dimens.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';

// import 'package:yourappname/model/searchmedicinemodel.dart';
// import 'package:yourappname/provider/addmedicineprovider.dart';
// import 'package:yourappname/utils/colors.dart';
// import 'package:yourappname/utils/constant.dart';
// import 'package:yourappname/utils/strings.dart';
// import 'package:yourappname/utils/utils.dart';
// import 'package:yourappname/widgets/mytext.dart';

// // ignore: must_be_immutable
// class PillName extends StatefulWidget {
//   List<Result>? searchedList = <Result>[];
//   PillName({
//     super.key,
//     this.searchedList,
//   });

//   @override
//   State<PillName> createState() => _PillNameState();
// }

// class _PillNameState extends State<PillName> {
//   Result? selectedMedicine;
//   final GlobalKey<AutoCompleteTextFieldState<Result>> _pillKey =
//       GlobalKey<AutoCompleteTextFieldState<Result>>();
//   final mPillNameController = TextEditingController();
//   String? medicineID;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: Constant.textFieldHeight,
//       padding: const EdgeInsets.only(left: 15, right: 15),
//       decoration: Utils.textFieldBGWithBorder(),
//       alignment: Alignment.centerLeft,
//       child: Consumer<AddMedicineProvider>(
//         builder: (context, medicineProvider, child) {
//           printLog("medicineProvider loading ==> ${medicineProvider.loading}");
//           printLog(
//               "searchMedicineModel status ==> ${medicineProvider.searchMedicineModel.status}");
//           printLog(
//               "searchMedicineModel result length ==> ${medicineProvider.searchMedicineModel.result?.length}");
//           if (selectedMedicine != null) {
//             mPillNameController.text = selectedMedicine?.name ?? "";
//             printLog("PillName ======> ${mPillNameController.text}");
//           }
//           List<Result> searchedList = <Result>[];
//           if (medicineProvider.searchMedicineModel.result != null) {
//             searchedList =
//                 medicineProvider.searchMedicineModel.result ?? <Result>[];
//             printLog("searchedList ====> ${searchedList.length}");
//           }
//           return AutoCompleteTextField<Result>(
//             style: GoogleFonts.roboto(
//               textStyle: const TextStyle(
//                 fontSize: 16,
//                 color: textTitleColor,
//                 fontWeight: FontWeight.normal,
//                 fontStyle: FontStyle.normal,
//               ),
//             ),
//             clearOnSubmit: false,
//             decoration: InputDecoration(
//               hintText: searchMedicineHint,
//               hintStyle: GoogleFonts.roboto(
//                 fontSize: 16,
//                 color: inActiveColor,
//                 fontWeight: FontWeight.normal,
//                 fontStyle: FontStyle.normal,
//               ),
//               border: InputBorder.none,
//             ),
//             unFocusOnItemSubmitted: false,
//             textChanged: (data) async {
//               printLog("textChanged data ======================> $data");
//               if (data.isNotEmpty) {
//                 printLog("data ==>>> $data");
//                 //Utility.showProgress(context, prDialog);
//                 await medicineProvider.getSearchedMedicine(data);
//                 //prDialog?.hide();
//               }
//             },
//             itemSubmitted: (item) {
//               selectedMedicine = item;
//               setState(() {
//                 printLog(
//                     "itemSubmitted medicineID ==> ${selectedMedicine?.id}");
//                 medicineID = selectedMedicine?.id.toString() ?? "";
//               });
//             },
//             key: _pillKey,
//             controller: mPillNameController,
//             keyboardType: TextInputType.text,
//             textInputAction: TextInputAction.next,
//             suggestions: searchedList.isNotEmpty
//                 ? searchedList
//                 : (medicineProvider.searchMedicineModel.result ?? <Result>[]),
//             itemBuilder: (context, suggestion) {
//               return ListTile(
//                 title: MyText(
//                   text: (suggestion.name ?? "").isNotEmpty
//                       ? (suggestion.name ?? "Not Found")
//                       : "Not Found",
//                   fontsize: Dimens.text15Size,
//                   textalign: TextAlign.start,
//                   color: textTitleColor,
//                   fontweight: FontWeight.w600,
//                   fontstyle: FontStyle.normal,
//                 ),
//               );
//             },
//             itemSorter: (a, b) {
//               return a.name == b.name
//                   ? 0
//                   : a.name != b.name
//                       ? -1
//                       : 1;
//             },
//             itemFilter: (suggestion, input) {
//               return (suggestion.name ?? "").toLowerCase().startsWith(
//                     input.toLowerCase(),
//                   );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
