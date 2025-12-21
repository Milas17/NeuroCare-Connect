// ignore_for_file: unused_import

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/components/body_widget.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/doctor/components/appointment_fragment_appointment_component.dart';
import 'package:kivicare_flutter/screens/shimmer/components/appointment_shimmer_component.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/date_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:kivicare_flutter/utils/widgets/calender/date_utils.dart';
import 'package:kivicare_flutter/utils/widgets/calender/flutter_clean_calendar.dart';
import 'package:nb_utils/nb_utils.dart';

StreamController appointmentStreamController = StreamController.broadcast();

class AppointmentFragment extends StatefulWidget {
  @override
  State<AppointmentFragment> createState() => _AppointmentFragmentState();
}

class _AppointmentFragmentState extends State<AppointmentFragment> {
  Map<DateTime, List> _events = {};

  Future<List<UpcomingAppointmentModel>>? future;

  List<UpcomingAppointmentModel> appointmentList = [];

  int page = 1;

  bool isLastPage = false;
  bool isRangeSelected = false;
  DateTime? start;
  DateTime? end;

  String startDate = DateTime(DateTime.now().year, DateTime.now().month, 1).getFormattedDate(SAVE_DATE_FORMAT);
  String endDate = DateTime(DateTime.now().year, DateTime.now().month, Utils.lastDayOfMonth(DateTime.now()).day).getFormattedDate(SAVE_DATE_FORMAT);

  DateTime selectedDate = DateTime.parse(DateFormat(SAVE_DATE_FORMAT).format(DateTime.now()));

  StreamSubscription? updateAppointmentApi;

  int selectedStatusIndex = 0;

  List<String> appointmentStatusList = [
    locale.lblAll,
    locale.lblBooked,
    locale.lblCheckIn,
    locale.lblCheckOut,
    locale.lblCancelled,
  ];

  @override
  void initState() {
    super.initState();

    String res = getStringAsync(SharedPreferenceKey.cachedAppointmentListKey);
    if (res.isNotEmpty) {
      cachedDoctorAppointment = (jsonDecode(res) as List).map((e) => UpcomingAppointmentModel.fromJson(e)).toList();
    }

    updateAppointmentApi = appointmentStreamController.stream.listen((streamData) {
      page = 1;
      showData(selectedDate);
    });

    init(startDate: startDate, endDate: endDate, showLoader: false);
  }

  Map<DateTime, List<UpcomingAppointmentModel>> groupAppointmentByDates({required List<UpcomingAppointmentModel> appointmentList}) {
    return groupBy(appointmentList, (UpcomingAppointmentModel appointmentData) => DateFormat(SAVE_DATE_FORMAT).parse(appointmentData.appointmentGlobalStartDate.validate()));
  }

  Future<void> init({bool showLoader = true, String? todayDate, String? startDate, String? endDate}) async {
    if (showLoader) appStore.setLoading(true);

    if (cachedDoctorAppointment!.isNotEmpty && page == 1) {
      setState(() {
        future = Future.value(cachedDoctorAppointment);
      });
    }

    // 🚀 Clear old events when new fetch begins
    if (startDate != null && endDate != null) {
      _events.clear();
    }

    future = getAppointment(
      pages: page,
      perPage: PER_PAGE,
      appointmentList: appointmentList,
      lastPageCallback: (b) => isLastPage = b,
      todayDate: todayDate,
      startDate: startDate,
      endDate: endDate,
    ).then((value) {
      if (todayDate != null && startDate == null && endDate == null) {
        if (value.isNotEmpty) {
          groupAppointmentByDates(appointmentList: value).forEach((key, value) {
            DateTime date = key;
            _events[DateTime(date.year, date.month, date.day)] = value;
          });
        } else {
          DateTime date = DateFormat(SAVE_DATE_FORMAT).parse(todayDate);
          _events.remove(DateTime(date.year, date.month, date.day));
        }
      }

      if (startDate != null && endDate != null) {
        groupAppointmentByDates(appointmentList: value).forEach((key, value) {
          DateTime date = key;
          _events.addAll({
            DateTime(date.year, date.month, date.day): value,
          });
        });
      }

      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  Future<void> onSwipeRefresh({bool isFirst = false}) async {
    setState(() {
      isRangeSelected = false;
    });

    showData(selectedDate);

    return await 1.seconds.delay;
  }

  void showData(DateTime dateTime) {
    selectedDate = DateTime.parse(DateFormat(SAVE_DATE_FORMAT).format(dateTime));
    setState(() {});

    // 👉 Range selected hoy
    if (isRangeSelected && start != null && end != null) {
      init(
        todayDate: null,
        startDate: start!.getFormattedDate(SAVE_DATE_FORMAT),
        endDate: end!.getFormattedDate(SAVE_DATE_FORMAT),
      );
      return;
    }

    // 👉 Single date hoy
    if (selectedDate.getFormattedDate(SAVE_DATE_FORMAT) == DateTime.now().getFormattedDate(SAVE_DATE_FORMAT)) {
      // Aaje ni date → todayDate param
      init(
        todayDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
        startDate: null,
        endDate: null,
      );
    } else {
      // Any other date → start & end same
      init(
        todayDate: null,
        startDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
        endDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
      );
    }
  }

  void onNextPage() {
    if (!isLastPage) {
      page++;
      showData(selectedDate);
    }
  }

  Future<void> onRangeSelected(Range range) async {
    isRangeSelected = true;
    page = 1;
    init(
      todayDate: null,
      startDate: range.from.getFormattedDate(SAVE_DATE_FORMAT),
      endDate: range.to.getFormattedDate(SAVE_DATE_FORMAT),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (updateAppointmentApi != null) {
      updateAppointmentApi!.cancel().then((value) {
        log("============== Stream Cancelled ==============");
      });
    }

    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedScrollView(
        padding: EdgeInsets.only(bottom: 60),
        onSwipeRefresh: onSwipeRefresh,
        onNextPage: onNextPage,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(locale.lblTodaySAppointments, style: boldTextStyle(size: fragmentTextSize)),
                  8.width,
                  Marquee(child: Text("(${selectedDate.getDateInString(format: CONFIRM_APPOINTMENT_FORMAT)})", style: boldTextStyle(size: 14, color: context.primaryColor))).expand(),
                ],
              ),
              4.height,
              Text(locale.lblSwipeMassage, style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
            ],
          ).paddingOnly(top: 16, right: 16, left: 16),
          Container(
            margin: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
            child: CleanCalendar(
              startOnMonday: true,
              weekDays: [locale.lblMon, locale.lblTue, locale.lblWed, locale.lblThu, locale.lblFri, locale.lblSat, locale.lblSun],
              events: _events,
              onDateSelected: (e) {
                showData(e);
              },
              initialDate: selectedDate,
              onRangeSelected: (Range range) {
                onRangeSelected(range);
              },
              isExpandable: true,
              locale: appStore.selectedLanguage,
              isExpanded: false,
              eventColor: appSecondaryColor,
              selectedColor: primaryColor,
              todayColor: primaryColor,
              bottomBarArrowColor: context.iconColor,
              dayOfWeekStyle: TextStyle(color: appStore.isDarkModeOn ? Colors.white : Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          HorizontalList(
            itemCount: appointmentStatusList.length,
            padding: EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              bool isSelected = selectedStatusIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedStatusIndex = index;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: EdgeInsets.only(right: 8),
                  decoration: boxDecorationDefault(
                    color: isSelected ? context.primaryColor : context.cardColor,
                    borderRadius: radius(20),
                  ),
                  child: Text(
                    appointmentStatusList[index],
                    style: primaryTextStyle(
                      color: isSelected ? Colors.white : textPrimaryColorGlobal,
                      size: 14,
                    ),
                  ),
                ),
              );
            },
          ).paddingBottom(8),
          SnapHelperWidget<List<UpcomingAppointmentModel>>(
            initialData: cachedDoctorAppointment,
            future: future,
            errorBuilder: (error) {
              return NoDataFoundWidget(
                onRetry: () => init(showLoader: true),
                retryText: locale.clickToRefresh,
                text: error.toString(),
                iconSize: 170,
              );
            },
            loadingWidget: AnimatedWrap(
              listAnimationType: ListAnimationType.None,
              runSpacing: 16,
              spacing: 16,
              children: [
                AppointmentShimmerComponent(),
                AppointmentShimmerComponent(),
                AppointmentShimmerComponent(),
              ],
            ).paddingSymmetric(horizontal: 16),
            onSuccess: (snap) {
              List<UpcomingAppointmentModel> filteredList;

              switch (selectedStatusIndex) {
                case 1: // Booked
                  filteredList = snap.where((e) => e.status == '1').toList();
                  break;
                case 2: // checkIn
                  filteredList = snap.where((e) => e.status == '4').toList();
                  break;
                case 3: // Checkout
                  filteredList = snap.where((e) => e.status == '3').toList();
                  break;
                case 4: // Cancelled
                  filteredList = snap.where((e) => e.status == '0').toList();
                  break;

                default: // All
                  filteredList = snap;
              }

              List<UpcomingAppointmentModel> groupedList = groupAppointmentByDates(appointmentList: filteredList)[selectedDate].validate();

              return AppointmentFragmentAppointmentComponent(
                data: groupedList,
                refreshCallForRefresh: () {
                  onSwipeRefresh(isFirst: true);
                },
              ).visible(
                groupedList.isNotEmpty,
                defaultWidget: NoDataFoundWidget(
                  text: selectedDate.getFormattedDate(SAVE_DATE_FORMAT) == DateTime.now().getFormattedDate(SAVE_DATE_FORMAT) ? locale.lblNoAppointmentForToday : locale.lblNoAppointmentForThisDay,
                ).center().visible(groupedList.isEmpty && !appStore.isLoading),
              );
            },
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
