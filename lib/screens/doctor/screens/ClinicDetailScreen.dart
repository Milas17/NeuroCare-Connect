import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/clinic_details_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/screens/doctor/clinic_doctors_component.dart';

import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ClinicDetailScreen extends StatefulWidget {
  final ClinicDetailsModel clinic;

  ClinicDetailScreen({required this.clinic});

  @override
  State<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends State<ClinicDetailScreen> {
  List<UserModel> doctorList = [];
  bool isLastPage = false;
  int page = 1;
  Future<List<UserModel>>? future;
  final ScrollController _scrollController = ScrollController();

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);
  }

  @override
  void initState() {
    super.initState();
    doctorList = [];

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        if (!isLastPage && !appStore.isLoading) {
          page++;
          init(showLoader: false); // next page load
        }
      }
    });
    init();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        widget.clinic.name.validate(),
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          /// ----------------- Clinic Details -----------------
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Clinic Image
                  Container(
                    width: context.width(),
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: radius(16),
                      image: DecorationImage(
                        image: (widget.clinic.profileImage != null && widget.clinic.profileImage!.isNotEmpty) ? NetworkImage(widget.clinic.profileImage!) : AssetImage(ic_clinic) as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  20.height,

                  /// Clinic Name
                  Text(widget.clinic.name.validate(), style: boldTextStyle(size: 22)),
                  12.height,

                  /// Specialties
                  if (widget.clinic.specialties.validate().isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.clinic.specialties!
                          .map((s) => Chip(
                                label: Text(s.label.validate()),
                                backgroundColor: primaryColor.withValues(alpha: 0.1),
                              ))
                          .toList(),
                    ),
                  20.height,

                  /// Address
                  if (widget.clinic.address.validate().isNotEmpty || widget.clinic.city.validate().isNotEmpty || widget.clinic.country.validate().isNotEmpty || widget.clinic.postalCode.validate().isNotEmpty)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, color: primaryColor, size: 18),
                        6.width,
                        Expanded(
                          child: Text(
                            [widget.clinic.address.validate(), widget.clinic.city.validate(), widget.clinic.postalCode.validate(), widget.clinic.country.validate()].where((e) => e.isNotEmpty).join(", "),
                            style: secondaryTextStyle(),
                          ),
                        ),
                      ],
                    ),
                  12.height,

                  /// Telephone
                  if (widget.clinic.telephoneNo.validate().isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.phone, color: primaryColor, size: 18),
                        6.width,
                        Text(
                          "${widget.clinic.countryCallingCode.validate()} ${widget.clinic.telephoneNo.validate()}",
                          style: secondaryTextStyle(),
                        ),
                      ],
                    ),
                  12.height,

                  /// Email
                  if (widget.clinic.email.validate().isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.email_outlined, color: primaryColor, size: 18),
                        6.width,
                        Text(widget.clinic.email!, style: secondaryTextStyle()),
                      ],
                    ),
                  12.height,

                  /// Owner
                  if (widget.clinic.clinicOwner.validate().isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.person, color: primaryColor, size: 20),
                        6.width,
                        Text(" ${locale.lblOnwer} : ${widget.clinic.clinicOwner.validate()}", style: secondaryTextStyle()),
                      ],
                    ),
                  20.height,
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: ClinicDoctorsComponent(
              clinicId: widget.clinic.id!,
            ),
          ),
        ],
      ),
    );
  }
}
