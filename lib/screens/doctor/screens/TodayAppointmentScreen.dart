import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/voice_search_suffix.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/doctor/components/appointment_fragment_appointment_component.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class TotalAppointmentScreen extends StatefulWidget {
  @override
  State<TotalAppointmentScreen> createState() => _TotalAppointmentScreenState();
}

class _TotalAppointmentScreenState extends State<TotalAppointmentScreen> {
  Future<List<UpcomingAppointmentModel>>? future;

  List<UpcomingAppointmentModel> allAppointments = [];
  List<UpcomingAppointmentModel> filteredAppointments = [];

  TextEditingController searchCont = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    fetchAppointments(showLoader: true);
  }

  Future<void> fetchAppointments({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);

    List<UpcomingAppointmentModel> result = [];
    int page = 1;
    bool hasMore = true;

    while (hasMore) {
      List<UpcomingAppointmentModel> pageAppointments = await getAppointment(
        pages: page,
        perPage: PER_PAGE,
        status: "All",
        appointmentList: [],
        lastPageCallback: (isLastPage) {
          hasMore = !isLastPage;
        },
      );
      result.addAll(pageAppointments);
      page++;
    }

    allAppointments = result;
    filterAppointments();

    if (mounted) {
      appStore.setLoading(false);
    }
  }

  void filterAppointments() {
    String query = searchCont.text.toLowerCase().trim();

    if (query.isEmpty) {
      filteredAppointments = allAppointments;
    } else {
      filteredAppointments = allAppointments.where((appointment) {
        return appointment.patientName.validate().toLowerCase().contains(query) || appointment.status.validate().toLowerCase().contains(query);
      }).toList();
    }

    if (mounted) {
      setState(() {
        future = Future.value(filteredAppointments);
      });
    }
  }

  void onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(300.milliseconds, () {
      if (mounted) filterAppointments();
    });
  }

  @override
  void dispose() {
    searchCont.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.lblTotalAppointment, textColor: white),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              AppTextField(
                controller: searchCont,
                textFieldType: TextFieldType.NAME,
                decoration: inputDecoration(
                  context: context,
                  hintText: locale.lblSearch,
                  prefixIcon: ic_search.iconImage().paddingAll(14),
                  suffixIcon: VoiceSearchSuffix(
                    controller: searchCont,
                    lottieAnimationPath: lt_voice,
                    onClear: () {
                      searchCont.clear();
                      filterAppointments();
                    },
                    onSearchChanged: (value) {
                      if (value.isEmpty) {
                        searchCont.clear();
                        if (mounted) filterAppointments();
                      } else {
                        _searchDebounce?.cancel();
                        _searchDebounce = Timer(300.milliseconds, () {
                          if (mounted) filterAppointments();
                        });
                      }
                    },
                    onSearchSubmitted: (value) {
                      hideKeyboard(context);
                      filterAppointments();
                    },
                  ),
                ),
                onChanged: onSearchChanged,
              ).paddingAll(16),
              Expanded(
                child: future == null
                    ? LoaderWidget().visible(appStore.isLoading).center()
                    : SnapHelperWidget<List<UpcomingAppointmentModel>>(
                        future: future!,
                        loadingWidget: LoaderWidget().visible(appStore.isLoading),
                        errorBuilder: (error) {
                          return NoDataFoundWidget(text: error.toString());
                        },
                        onSuccess: (snap) {
                          if (snap.isEmpty && !appStore.isLoading) {
                            return NoDataFoundWidget(
                              text: locale.lblNoAppointmentsFound,
                            ).center();
                          }

                          return SingleChildScrollView(
                            padding: EdgeInsets.only(bottom: 80),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppointmentFragmentAppointmentComponent(
                                  data: snap,
                                  refreshCallForRefresh: () {
                                    fetchAppointments(showLoader: true);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          appointmentWidgetNavigation(context);
        },
      ).visible(isVisible(SharedPreferenceKey.kiviCareAppointmentAddKey)),
    );
  }
}
