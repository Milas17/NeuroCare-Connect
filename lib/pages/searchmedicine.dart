// import 'package:yourappname/pages/nodata.dart';
// import 'package:yourappname/provider/writeprescriptionprovider.dart';
// import 'package:yourappname/utils/colors.dart';
// import 'package:yourappname/utils/constant.dart';
// import 'package:yourappname/utils/dimens.dart';
// import 'package:yourappname/utils/utils.dart';
// import 'package:yourappname/widgets/mytext.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class SearchMedicine extends StatefulWidget {
//   const SearchMedicine({super.key});

//   @override
//   State<SearchMedicine> createState() => _SearchMedicineState();
// }

// class _SearchMedicineState extends State<SearchMedicine> {
//   final mMedicineController = TextEditingController();
//   int? selectPosition;

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: white,
//       appBar: Utils.myAppBarWithBack(context, "search_medicine", true, true),
//       body: Column(
//         children: [
//           Container(
//             height: Constant.textFieldHeight,
//             margin: const EdgeInsets.all(15),
//             decoration: Utils.textFieldBGWithBorder(),
//             alignment: Alignment.centerLeft,
//             child: TextFormField(
//               decoration: InputDecoration(
//                 hintText: 'Enter a product name eg. paracetamol',
//                 hintStyle: const TextStyle(fontSize: 16),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                   borderSide: const BorderSide(
//                     width: 0,
//                     style: BorderStyle.none,
//                   ),
//                 ),
//                 filled: true,
//                 contentPadding: const EdgeInsets.all(16),
//                 fillColor: white,
//               ),
//               controller: mMedicineController,
//               obscureText: false,
//               maxLines: 1,
//               keyboardType: TextInputType.name,
//               onChanged: (value) async {
//                 final medicineProvider = Provider.of<WritePrescriptionProvider>(
//                     context,
//                     listen: false);
//                 await medicineProvider.getSearchedMedicine(value);
//               },
//             ),
//           ),
//           Consumer<WritePrescriptionProvider>(
//             builder: (context, homeProvider, child) {
//               if (!homeProvider.loading) {
//                 if (homeProvider.searchMedicineModel.status == 200 &&
//                     homeProvider.searchMedicineModel.result != null) {
//                   if ((homeProvider.searchMedicineModel.result?.length ?? 0) >
//                       0) {
//                     return ListView.builder(
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount:
//                           homeProvider.searchMedicineModel.result?.length ?? 0,
//                       itemBuilder: (BuildContext context, int position) {
//                         return InkWell(
//                           onTap: () {
//                             setState(() {
//                               selectPosition = position;
//                               Navigator.pop(context,
//                                   '${homeProvider.searchMedicineModel.result?[position].name.toString()}_${homeProvider.searchMedicineModel.result?[position].id.toString()}');
//                             });
//                           },
//                           child: Container(
//                             height: 45,
//                             width: MediaQuery.of(context).size.width,
//                             margin: const EdgeInsets.only(
//                                 left: 10, right: 10, top: 5, bottom: 5),
//                             padding: const EdgeInsets.only(left: 10, right: 10),
//                             decoration: selectPosition == position
//                                 ? const BoxDecoration(color: grayLight)
//                                 : const BoxDecoration(color: white),
//                             child: Align(
//                               alignment: Alignment.centerLeft,
//                               child: MyText(
//                                   fontsize: Dimens.text16Size,
//                                   maxline: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   fontweight: FontWeight.bold,
//                                   text: homeProvider.searchMedicineModel
//                                           .result?[position].name
//                                           .toString() ??
//                                       ""),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     return const NoData(text: '');
//                   }
//                 } else {
//                   return const NoData(text: '');
//                 }
//               } else {
//                 return Utils.pageLoader();
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
