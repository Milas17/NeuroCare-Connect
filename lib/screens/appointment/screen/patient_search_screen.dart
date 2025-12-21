import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/patient_list_repository.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/patient_search_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientSearchScreen extends StatefulWidget {
  final UserModel? selectedData;

  PatientSearchScreen({Key? key, this.selectedData}) : super(key: key);

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  Future<List<UserModel>>? future;

  List<UserModel> patientList = [];

  TextEditingController searchCont = TextEditingController();

  int page = 1;

  bool isLastPage = false;
  bool isFirst = true;
  bool showClear = false;

  UserModel? selectedData;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);

    page = 1;
    isLastPage = false;
    patientList.clear();

    future = getPatientListAPI(
      searchString: searchCont.text,
      patientList: patientList,
      doctorId: isDoctor() ? userStore.userId : appointmentAppStore.mDoctorSelected!.iD.validate(),
      clinicId: isReceptionist() ? userStore.userClinicId.toInt() : appointmentAppStore.mClinicSelected?.id.toInt(),
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      showClear = searchCont.text.isNotEmpty;
      appStore.setLoading(false);
      setState(() {});
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
      throw e;
    });
  }

  void _onSearchClear() async {
    hideKeyboard(context);
    searchCont.clear();
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget('${locale.lblPatientList} ', textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context)),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
          children: [
            AppTextField(
              controller: searchCont,
              textFieldType: TextFieldType.NAME,
              decoration: inputDecoration(
                context: context,
                hintText: locale.lblSearchPatient,
                prefixIcon: ic_search.iconImage().paddingAll(16),
                suffixIcon: VoiceSearchSuffix(
                  controller: searchCont,
                  lottieAnimationPath: lt_voice,
                  onClear: () {
                    _onSearchClear();
                  },
                  onSearchChanged: (value) {
                    if (value.isEmpty) {
                      _onSearchClear();
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
                if (newValue.isEmpty) {
                  showClear = false;
                  _onSearchClear();
                } else {
                  Timer(pageAnimationDuration, () {
                    init(showLoader: true);
                  });
                  showClear = true;
                }
                setState(() {});
              },
              onFieldSubmitted: (searchString) {
                hideKeyboard(context);

                init(showLoader: true);
              },
            ).paddingSymmetric(horizontal: 16, vertical: 16),
            SnapHelperWidget<List<UserModel>>(
              future: future,
              loadingWidget: PatientSearchShimmerScreen(),
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
                if (widget.selectedData != null && isFirst) {
                  selectedData = snap.firstWhere((element) => element.iD.validate() == widget.selectedData!.iD.validate());
                  isFirst = false;
                }
                snap.retainWhere((element) => element.userStatus.toInt() == ACTIVE_USER_INT_STATUS);
                if (snap.isEmpty && !appStore.isLoading) {
                  return SingleChildScrollView(child: NoDataFoundWidget(text: searchCont.text.isEmpty ? locale.lblNoActivePatientAvailable : locale.lblCantFindPatientYouSearchedFor)).center();
                }
                return AnimatedScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                  disposeScrollController: true,
                  listAnimationType: ListAnimationType.None,
                  physics: AlwaysScrollableScrollPhysics(),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  onSwipeRefresh: () async {
                    init(showLoader: false);
                    return await 1.seconds.delay;
                  },
                  onNextPage: () async {
                    if (!isLastPage && !appStore.isLoading) {
                      page++;
                      appStore.setLoading(true);

                      try {
                        await getPatientListAPI(
                          searchString: searchCont.text,
                          patientList: patientList,
                          doctorId: isDoctor() ? userStore.userId : appointmentAppStore.mDoctorSelected!.iD.validate(),
                          clinicId: isReceptionist() ? userStore.userClinicId.toInt() : appointmentAppStore.mClinicSelected?.id.toInt(),
                          page: page,
                          lastPageCallback: (b) => isLastPage = b,
                        ).then((value) {
                          patientList.addAll(value);
                        });

                        setState(() {});
                      } catch (e) {
                        log(e.toString());
                      } finally {
                        appStore.setLoading(false);
                      }
                    }
                  },
                  children: [
                    ...snap.map(
                      (e) {
                        UserModel data = e;
                        return Container(
                          decoration: boxDecorationDefault(boxShadow: [], color: context.cardColor),
                          child: RadioGroup<UserModel>(
                              groupValue: selectedData,
                              onChanged: (value) {
                                if (value != null) {
                                  selectedData = value;
                                  setState(() {});
                                }
                              },
                              child: RadioListTile<UserModel>(
                                value: data,
                                tileColor: context.cardColor,
                                controlAffinity: ListTileControlAffinity.trailing,
                                shape: RoundedRectangleBorder(borderRadius: radius()),
                                secondary: ImageBorder(
                                  src: data.profileImage.validate(),
                                  height: 30,
                                  nameInitial: data.displayName.validate(value: 'P')[0],
                                ),
                                title: Text(
                                  data.displayName.capitalizeEachWord().validate(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: primaryTextStyle(),
                                ),
                              )),
                        ).paddingSymmetric(vertical: 8);
                      },
                    ).toList(),
                  ],
                );
              },
            ).paddingTop(70),
            LoaderWidget().visible(appStore.isLoading).center()
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          finish(context, selectedData);
        },
      ),
    );
  }
}
