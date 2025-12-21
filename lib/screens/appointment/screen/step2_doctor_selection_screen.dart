import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/doctor_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/component/doctor_list_component.dart';
import 'package:kivicare_flutter/screens/shimmer/components/doctor_shimmer_component.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class Step2DoctorSelectionScreen extends StatefulWidget {
  final int? clinicId;
  final bool isForAppointment;
  final int? doctorId;

  Step2DoctorSelectionScreen({this.clinicId, this.isForAppointment = false, this.doctorId});

  @override
  _Step2DoctorSelectionScreenState createState() => _Step2DoctorSelectionScreenState();
}

class _Step2DoctorSelectionScreenState extends State<Step2DoctorSelectionScreen> {
  Future<List<UserModel>>? future;

  TextEditingController searchCont = TextEditingController();

  List<UserModel> doctorList = [];

  bool isLastPage = false;
  bool showClear = false;
  Timer? _debounce;
  int page = 1;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }

    future = getDoctorListWithPagination(
      searchString: searchCont.text,
      clinicId: widget.clinicId,
      doctorList: doctorList,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      if (value.validate().isNotEmpty) {
        listAppStore.addDoctor(value);
      }
      if (searchCont.text.isNotEmpty) {
        showClear = true;
      } else {
        showClear = false;
      }
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
      throw e;
    });
  }

  Future<void> _onClearSearch() async {
    searchCont.clear();
    doctorList.clear();
    page = 1;
    hideKeyboard(context);
    init(showLoader: true);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    appointmentAppStore.setSelectedDoctor(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        !widget.isForAppointment.validate() ? locale.lblSelectDoctor : locale.lblAddNewAppointment,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Observer(builder: (context) {
        return Stack(
          children: [
            if (widget.isForAppointment)
              Column(
                children: [
                  AppTextField(
                    controller: searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context: context,
                      hintText: locale.lblSearchDoctor,
                      prefixIcon: ic_search.iconImage().paddingAll(16),
                      suffixIcon: VoiceSearchSuffix(
                        controller: searchCont,
                        lottieAnimationPath: lt_voice,
                        onClear: () {
                          _onClearSearch();
                        },
                        onSearchChanged: (value) {
                          if (value.isEmpty) {
                            _onClearSearch();
                          } else {
                            Timer(pageAnimationDuration, () {
                              init(showLoader: true);
                            });
                          }
                        },
                        onSearchSubmitted: (value) {
                          hideKeyboard(context);
                          init(showLoader: true);
                        },
                      ),
                    ),
                    onChanged: (newValue) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();

                      _debounce = Timer(Duration(milliseconds: 500), () {
                        if (newValue.isEmpty) {
                          showClear = false;
                          _onClearSearch();
                        } else {
                          showClear = true;
                          page = 1; // reset pagination
                          doctorList.clear(); // old data remove
                          init(showLoader: true);
                        }
                        setState(() {});
                      });
                    },
                    onFieldSubmitted: (searchString) async {
                      hideKeyboard(context);
                      init(showLoader: true);
                    },
                  ),
                  16.height,
                  stepCountWidget(
                    name: locale.lblChooseYourDoctor,
                    currentCount: isPatient() ? 2 : 1,
                    totalCount: isReceptionist() ? 2 : 3,
                    percentage: isPatient() ? 0.66 : 0.50,
                  ),
                ],
              ).paddingSymmetric(vertical: 8),
            SnapHelperWidget<List<UserModel>>(
              future: future,
              loadingWidget: AnimatedWrap(
                spacing: 16,
                runSpacing: 16,
                children: List.generate(
                  4,
                  (index) => DoctorShimmerComponent(),
                ),
              ),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(
                    ic_somethingWentWrong,
                    height: 180,
                    width: 180,
                  ),
                  title: error.toString(),
                );
              },
              errorWidget: ErrorStateWidget(),
              onSuccess: (snap) {
                snap.retainWhere((element) => element.userStatus.toInt() == ACTIVE_USER_INT_STATUS);
                if (snap.isEmpty && !appStore.isLoading) {
                  return SingleChildScrollView(
                    child: NoDataFoundWidget(
                      text: searchCont.text.isEmpty ? locale.lblNoActiveDoctorAvailable : locale.lblCantFindDoctorYouSearchedFor,
                    ),
                  ).center();
                }

                return AnimatedListView(
                  itemCount: snap.length,
                  padding: EdgeInsets.only(bottom: 80),
                  shrinkWrap: true,
                  physics: AlwaysScrollableScrollPhysics(),
                  onSwipeRefresh: () async {
                    init(showLoader: false);
                    await 1.seconds.delay;
                  },
                  onNextPage: () async {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(showLoader: true);
                      await 1.seconds.delay;
                    }
                  },
                  itemBuilder: (context, index) {
                    UserModel data = snap[index];
                    if (widget.doctorId != null && data.iD == widget.doctorId) {
                      appointmentAppStore.setSelectedDoctor(data);
                    }

                    return GestureDetector(
                      onTap: () {
                        if (appointmentAppStore.mDoctorSelected != null ? appointmentAppStore.mDoctorSelected!.iD.validate() == data.iD.validate() : false) {
                          appointmentAppStore.setSelectedDoctor(null);
                        } else {
                          appointmentAppStore.setSelectedDoctor(data);
                        }
                      },
                      child: Observer(builder: (context) {
                        return DoctorListComponent(data: data, isSelected: appointmentAppStore.mDoctorSelected?.iD.validate() == data.iD.validate()).paddingSymmetric(vertical: 8);
                      }),
                    );
                  },
                );
              },
            ).paddingTop(widget.isForAppointment ? 142 : 0),
            LoaderWidget().visible(appStore.isLoading).center()
          ],
        ).paddingOnly(left: 16, right: 16, top: 16);
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(widget.isForAppointment ? Icons.arrow_forward_outlined : Icons.done),
        onPressed: () {
          if (appointmentAppStore.mDoctorSelected == null) {
            toast(locale.lblSelectOneDoctor);
          } else {
            if (!widget.isForAppointment.validate())
              finish(context, appointmentAppStore.mDoctorSelected);
            else
              doctorNavigation(context).then((value) {});
          }
        },
      ),
    );
  }
}
