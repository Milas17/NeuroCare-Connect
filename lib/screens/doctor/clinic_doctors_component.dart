import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/doctor_repository.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/component/doctor_list_component.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/doctor_details_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/doctor_list_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ClinicDoctorsComponent extends StatefulWidget {
  final int clinicId;
  final int viewLimit;

  ClinicDoctorsComponent({this.viewLimit = 5, required this.clinicId});

  @override
  State<ClinicDoctorsComponent> createState() => _ClinicDoctorsComponentState();
}

class _ClinicDoctorsComponentState extends State<ClinicDoctorsComponent> {
  List<UserModel> doctorList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    appStore.setLoading(true);
    getDoctorListWithPagination(
      clinicId: widget.clinicId,
      page: 1,
      doctorList: [],
      lastPageCallback: (_) {},
    ).then((value) {
      doctorList = value.take(widget.viewLimit).toList();
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Offstage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Doctors", style: boldTextStyle(size: 18)),
            TextButton(
              onPressed: () {
                DoctorListScreen(clinicId: widget.clinicId).launch(context);
              },
              child: Text("View All", style: primaryTextStyle(color: primaryColor)),
            ),
          ],
        ),
        8.height,

        /// Doctor List
        if (doctorList.isNotEmpty)
          Wrap(
            runSpacing: 16,
            spacing: 16,
            children: doctorList.map((doc) {
              return GestureDetector(
                onTap: () {
                  DoctorDetailScreen(doctorData: doc).launch(
                    context,
                    pageRouteAnimation: PageRouteAnimation.Fade,
                    duration: 800.milliseconds,
                  );
                },
                child: DoctorListComponent(data: doc),
              );
            }).toList(),
          )
        else
          NoDataFoundWidget(text: "No Doctors Found").center(),
      ],
    ).paddingSymmetric(horizontal: 16);
  }
}
