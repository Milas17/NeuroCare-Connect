import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/doctor_repository.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorListScreen extends StatefulWidget {
  final int clinicId;

  DoctorListScreen({required this.clinicId});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  List<UserModel> doctorList = [];
  bool isLastPage = false;
  int page = 1;
  final ScrollController _scrollController = ScrollController();

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);

    getDoctorListWithPagination(
      doctorList: doctorList,
      clinicId: widget.clinicId,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      if (page == 1) {
        doctorList = value;
      } else {
        doctorList = List<UserModel>.from(doctorList)..addAll(value);
      }
      setState(() {});
    }).catchError((e) {
      toast(e.toString());
    }).whenComplete(() {
      appStore.setLoading(false);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!isLastPage && !appStore.isLoading) {
          page++;
          init(showLoader: false);
        }
      }
    });
    init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget("All Doctors", textColor: Colors.white),
      body: doctorList.isEmpty && appStore.isLoading
          ? LoaderWidget()
          : ListView.builder(
              controller: _scrollController,
              itemCount: doctorList.length,
              padding: EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final doc = doctorList[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: radius(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: doc.profileImage.validate().isNotEmpty ? NetworkImage(doc.profileImage.validate()) : AssetImage(ic_doctor) as ImageProvider,
                      ),
                      12.width,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc.displayName.validate(), style: boldTextStyle()),
                            4.height,
                            if (doc.noOfExperience.validate().isNotEmpty) Text("Experience: ${doc.noOfExperience.validate()}", style: secondaryTextStyle()),
                            if (doc.userEmail.validate().isNotEmpty) Text("Email: ${doc.userEmail.validate()}", style: secondaryTextStyle()),
                            if (doc.mobileNumber.validate().isNotEmpty) Text("Phone: ${doc.mobileNumber.validate()}", style: secondaryTextStyle()),
                            if (doc.specialties != null && doc.specialties!.isNotEmpty)
                              Text(
                                "Specialties: ${doc.specialties!.map((e) => e.label.validate()).join(", ")}",
                                style: secondaryTextStyle(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
