import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/add_service_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/components/service_widget.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/view_service_data_screen.dart';
import 'package:kivicare_flutter/screens/receptionist/receptionist_service_data_screen.dart';
import 'package:kivicare_flutter/screens/shimmer/components/services_shimmer_component.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../utils/constants/sharedpreference_constants.dart';

class ServiceListScreen extends StatefulWidget {
  @override
  _ServiceListScreenState createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  Future<List<ServiceData>>? future;
  String? selectedType;
  String? selectedDoctor;
  String? selectedClinic;

  TextEditingController searchCont = TextEditingController();

  List<ServiceData> serviceList = [];
  List<ServiceData> fullServiceList = []; // 🔹 NEW: full unfiltered data
  int page = 1;

  bool isLastPage = false;
  bool showClear = false;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);

    final fetchId = (isReceptionist() || isPatient()) ? userStore.userClinicId.validate().toInt() : userStore.userId.validate();

    print('Fetching services for ID: $fetchId');

    future = getServiceListAPI(
      searchString: searchCont.text,
      id: fetchId,
      perPages: 50,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      appStore.setLoading(false);

      showClear = searchCont.text.isNotEmpty;

      fullServiceList = value;
      List<ServiceData> filteredList = value;

      if (selectedType != null && selectedType!.isNotEmpty) {
        filteredList = filteredList.where((e) => e.type == selectedType).toList();
      }
      if (selectedDoctor != null && selectedDoctor!.isNotEmpty) {
        filteredList = filteredList
            .where(
              (e) => e.doctorList?.any((doc) => doc.displayName == selectedDoctor) ?? false,
            )
            .toList();
      }
      if (selectedClinic != null && selectedClinic!.isNotEmpty) {
        filteredList = filteredList.where((e) => e.clinicId == selectedClinic).toList();
      }

      serviceList = filteredList;
      setState(() {});
      return filteredList;
    }).catchError((e) {
      appStore.setLoading(false);
      setState(() {});
      throw e;
    });
  }

  Future<void> _onClearSearch() async {
    hideKeyboard(context);
    searchCont.clear();
    init(showLoader: true);
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: appBarWidget(
          locale.lblServices,
          textColor: Colors.white,
          systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
          actions: [
            Badge(
              backgroundColor: appSecondaryColor,
              isLabelVisible: selectedType != null || selectedDoctor != null || selectedClinic != null,
              label: GestureDetector(
                onTap: () {
                  selectedType = null;
                  selectedDoctor = null;
                  selectedClinic = null;
                  init(showLoader: true);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 15,
                  decoration: BoxDecoration(shape: BoxShape.rectangle),
                  child: Icon(
                    Icons.close,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              // child: IconButton(
              //   icon: Icon(
              //     Icons.filter_list,
              //     color: Colors.white,
              //   ),
              //   iconSize: 24, // Set the size of the main icon
              //   onPressed: () async {
              //     final selected = await Navigator.push<Map<String, String?>>(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => ServiceFilterScreen(
              //           serviceData: fullServiceList, // 🔹 Unfiltered
              //           currentType: selectedType,
              //           currentDoctor: selectedDoctor,
              //           currentClinic: selectedClinic,
              //         ),
              //       ),
              //     );
              //     if (selected != null) {
              //       selectedType = selected['type'];
              //       selectedDoctor = selected['doctor'];
              //       selectedClinic = selected['clinic'];

              //       page = 1;
              //       await init(showLoader: true);
              //     }
              //   },
              //   padding: EdgeInsets.zero,
              //   constraints: BoxConstraints(),
              // ),
              // alignment: Alignment.topRight,
              offset: Offset(0, 0),
            ),

            // GestureDetector(
            //   onTap: () async {
            //     final selected = await Navigator.push<Map<String, String?>>(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => ServiceFilterScreen(
            //           serviceData: fullServiceList, // 🔹 Unfiltered
            //           currentType: selectedType,
            //           currentDoctor: selectedDoctor,
            //           currentClinic: selectedClinic,
            //         ),
            //       ),
            //     );

            //     if (selected != null) {
            //       selectedType = selected['type'];
            //       selectedDoctor = selected['doctor'];
            //       selectedClinic = selected['clinic'];

            //       page = 1;
            //       await init(showLoader: true);
            //     }
            //   },
            //   child: Container(
            //     height: 35,
            //     width: 35,
            //     decoration: BoxDecoration(
            //       // color: appBarBackgroundColorGlobal,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Icon(Icons.filter_list, color: Colors.black),
            //   ),
            // ),
            // if (selectedType != null || selectedDoctor != null || selectedClinic != null)
            //   TextButton(
            //     onPressed: () {
            //       selectedType = null;
            //       selectedDoctor = null;
            //       selectedClinic = null;
            //       init(showLoader: true);
            //     },
            //     child: Text('Clear Filter', style: primaryTextStyle(color: Colors.red)),
            //   ),
            16.width
          ],
        ),
        body: InternetConnectivityWidget(
          retryCallback: () async {
            init();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: searchCont,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context: context,
                      hintText: locale.lblSearchServices,
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
                      showClear = newValue.isNotEmpty;
                      Timer(pageAnimationDuration, () => init(showLoader: true));
                      setState(() {});
                    },
                    onFieldSubmitted: (searchString) async {
                      hideKeyboard(context);
                      init(showLoader: true);
                    },
                  ),
                  16.height,
                  Text('${locale.lblNote} : ${locale.lblTapMsg}', style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                ],
              ).paddingSymmetric(horizontal: 16, vertical: 16),
              SnapHelperWidget<List<ServiceData>>(
                future: future,
                errorBuilder: (p0) => ErrorStateWidget(error: p0.toString()),
                loadingWidget: AnimatedWrap(
                  runSpacing: 16,
                  spacing: 16,
                  listAnimationType: listAnimationType,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: List.generate(4, (index) => ServicesShimmerComponent(isForDoctorServicesList: isDoctor())),
                ).paddingSymmetric(horizontal: 16, vertical: 16),
                onSuccess: (snap) {
                  if (snap.isEmpty && !appStore.isLoading) {
                    return NoDataFoundWidget(
                      iconSize: searchCont.text.isNotEmpty ? 60 : 160,
                      text: searchCont.text.isNotEmpty ? locale.lblCantFindServiceYouSearchedFor : locale.lblNoServicesFound,
                    ).center();
                  }

                  return AnimatedScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 120),
                    disposeScrollController: true,
                    listAnimationType: ListAnimationType.None,
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(verticalOffset: 400),
                    onSwipeRefresh: () async {
                      await init(showLoader: true);
                      return await 1.seconds.delay;
                    },
                    onNextPage: () async {
                      page++;
                      await init(showLoader: true);
                      return await 1.seconds.delay;
                    },
                    children: [
                      AnimatedWrap(
                        spacing: 16,
                        runSpacing: 16,
                        direction: Axis.horizontal,
                        listAnimationType: listAnimationType,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        itemCount: snap.length,
                        itemBuilder: (context, index) {
                          ServiceData data = snap[index];
                          return ServiceWidget(
                            data: data,
                            onEdit: isDoctor() || isReceptionist()
                                ? () async {
                                    await AddServiceScreen(
                                      serviceData: data,
                                      callForRefresh: () => init(),
                                    ).launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                                      if (value ?? false) init();
                                    });
                                  }
                                : null,
                            onTap: () {
                              if (isReceptionist()) {
                                ReceptionistServiceDataScreen(serviceData: data).launch(
                                  context,
                                  pageRouteAnimation: PageRouteAnimation.Slide,
                                  duration: pageAnimationDuration,
                                );
                              } else {
                                ViewServiceDataScreen(serviceData: data).launch(
                                  context,
                                  pageRouteAnimation: PageRouteAnimation.Slide,
                                  duration: pageAnimationDuration,
                                );
                              }
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ).paddingTop(isDoctor() ? 102 : 100),
              LoaderWidget().visible(appStore.isLoading).center()
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            if (appStore.isConnectedToInternet) {
              await AddServiceScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                if (value ?? false) init();
              });
            } else {
              toast(locale.lblNoInternetMsg);
            }
          },
        ).visible(isVisible(SharedPreferenceKey.kiviCareServiceAddKey)),
      );
    });
  }
}
