import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/components/filter_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/view_service_detail_screen.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/patient_service_list_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/screens/patient/components/category_widget.dart';

class PatientServiceListScreen extends StatefulWidget {
  const PatientServiceListScreen({Key? key}) : super(key: key);

  @override
  State<PatientServiceListScreen> createState() => _PatientServiceListScreenState();
}

class _PatientServiceListScreenState extends State<PatientServiceListScreen> {
  Future<List<ServiceData>>? future;
  String? selectedType;
  String? selectedDoctor;
  String? selectedClinic;
  TextEditingController searchCont = TextEditingController();

  List<ServiceData> serviceList = [];
  List<ServiceData> fullServiceList = [];

  int page = 1;

  bool isLastPage = false;
  bool showClear = false;

  @override
  void initState() {
    super.initState();
    if (appStore.isLoading) {
      appStore.setLoading(false);
    }
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) appStore.setLoading(true);

    final fetchId = (isReceptionist() || isPatient()) ? userStore.userClinicId.validate().toInt() : userStore.userId.validate();
    // int fetchId = 5;
    print('Fetching services for ID: $fetchId');

    future = getServiceListAPI(
      searchString: searchCont.text,
      id: fetchId,
      perPages: 50,
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      appStore.setLoading(false);

      showClear = searchCont.text.isNotEmpty || (selectedType != null && selectedType!.isNotEmpty) || (selectedDoctor != null && selectedDoctor!.isNotEmpty) || (selectedClinic != null && selectedClinic!.isNotEmpty);

      fullServiceList = value;

      //for logs of clinic
      // for (final service in fullServiceList) {
      //   if (service.clinicName != null && service.clinicName!.isNotEmpty) {
      //     print("Clinic: ${service.clinicName}");
      //   } else if (service.clinicList != null && service.clinicList!.isNotEmpty) {
      //     for (final clinic in service.clinicList!) {
      //       print("Clinic: ${clinic.name}");
      //     }
      //   } else {
      //     print("Clinic: Not available for service '${service.name}'");
      //   }
      // }

      List<ServiceData> filteredList = value;

      if (selectedType != null && selectedType!.isNotEmpty) {
        filteredList = filteredList.where((e) => e.type.validate() == selectedType).toList();
      }
      if (selectedDoctor != null && selectedDoctor!.isNotEmpty) {
        filteredList = filteredList
            .where(
              (e) => e.doctorList?.any((doc) => doc.displayName.validate() == selectedDoctor) ?? false,
            )
            .toList();
      }
      if (selectedClinic != null && selectedClinic!.isNotEmpty) {
        filteredList = filteredList.where((e) => e.clinicName == selectedClinic).toList();
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
      appBar: appBarWidget(locale.lblServices, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context), actions: [
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
          child: IconButton(
            icon: Icon(
              Icons.filter_list,
              color: Colors.white,
            ),
            iconSize: 24, // Set the size of the main icon
            onPressed: () async {
              final selected = await Navigator.push<Map<String, String?>>(
                context,
                MaterialPageRoute(
                  builder: (context) => ServiceFilterScreen(
                    serviceData: fullServiceList, // 🔹 Unfiltered
                    currentType: selectedType,
                    currentDoctor: selectedDoctor,
                    currentClinic: selectedClinic,
                  ),
                ),
              );
              if (selected != null) {
                selectedType = selected['type'];
                selectedDoctor = selected['doctor'];
                selectedClinic = selected['clinic'];

                page = 1;
                await init(showLoader: true);
              }
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          alignment: Alignment.topRight,
          offset: Offset(0, 0),
        ),
        16.width
      ]),
      body: Observer(builder: (context) {
        return Stack(
          fit: StackFit.expand,
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
                if (newValue.isEmpty) {
                  showClear = false;
                  _onClearSearch();
                } else {
                  Timer(pageAnimationDuration, () {
                    init(showLoader: true);
                  });
                  showClear = true;
                }
                setState(() {});
              },
              onFieldSubmitted: (searchString) async {
                hideKeyboard(context);
                init(showLoader: true);
              },
            ).paddingOnly(left: 16, right: 16, top: 24, bottom: 32),
            SnapHelperWidget<List<ServiceData>>(
              future: future,
              loadingWidget: PatientServiceListShimmerScreen(),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                ).center();
              },
              errorWidget: ErrorStateWidget(),
              onSuccess: (snap) {
                return AnimatedScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  disposeScrollController: true,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 80),
                  listAnimationType: ListAnimationType.None,
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  onSwipeRefresh: () async {
                    setState(() {
                      page = 1;
                    });
                    init(showLoader: false);
                    return await 1.seconds.delay;
                  },
                  onNextPage: () {
                    if (!isLastPage) {
                      setState(() {
                        page++;
                      });
                      init(showLoader: false);
                    }
                  },
                  children: List.generate(groupServicesByCategory(snap).keys.length, (index) {
                    String title = groupServicesByCategory(snap).keys.toList()[index].toString();
                    return SettingSection(
                      title: Text(title.replaceAll('_', ' ').capitalizeEachWord(), style: boldTextStyle()),
                      headingDecoration: BoxDecoration(),
                      headerPadding: EdgeInsets.all(4),
                      divider: 16.height,
                      items: [
                        AnimatedWrap(
                          itemCount: groupServicesByCategory(snap).values.toList()[index].length,
                          spacing: 16,
                          runSpacing: 16,
                          itemBuilder: (context, i) {
                            ServiceData serviceData = groupServicesByCategory(snap).values.toList()[index][i];

                            return GestureDetector(
                              onTap: () {
                                ViewServiceDetailScreen(serviceData: serviceData).launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration);
                              },
                              child: CategoryWidget(data: serviceData, hideMoreButton: false),
                            );
                          },
                        ).paddingBottom(24),
                      ],
                    );
                  }),
                ).visible(snap.isNotEmpty,
                    defaultWidget: SingleChildScrollView(
                      child: NoDataFoundWidget(text: searchCont.text.isEmpty ? locale.lblNoServicesFound : locale.lblCantFindServiceYouSearchedFor),
                    ).center().visible(snap.isEmpty && !appStore.isLoading));
              },
            ).paddingTop(90),
            LoaderWidget().visible(appStore.isLoading).center()
          ],
        );
      }),
    );
  }
}

List<ServiceData> getRemovedDuplicateServiceList(List<ServiceData> serviceList) {
  Map<int, bool> uniqueIds = {};
  List<ServiceData> filteredList = [];

  for (ServiceData data in serviceList) {
    int dataId = int.parse(data.id.validate());
    if (!uniqueIds.containsKey(dataId)) {
      uniqueIds[dataId] = true;
      filteredList.add(data);
    }
  }

  return filteredList;
}

Map<String, List<ServiceData>> groupServicesByCategory(List<ServiceData> services) {
  return groupBy(services, (ServiceData e) => e.type.validate());
}
