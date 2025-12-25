import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/rescheduleprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Reschedule extends StatefulWidget {
  final String? doctorID, appointmentID;
  const Reschedule(
      {super.key, required this.doctorID, required this.appointmentID});

  @override
  State<Reschedule> createState() => _RescheduleState();
}

class _RescheduleState extends State<Reschedule> {
  final DatePickerController mDateController = DatePickerController();
  final mReasonController = TextEditingController();
  late ProgressDialog prDialog;

  late Rescheduleprovider bookAppointmentProvider;

  String? strDate = "",
      strStartTime = "",
      strEndTime = "",
      appointmentSlotId = "";

  @override
  void initState() {
    bookAppointmentProvider =
        Provider.of<Rescheduleprovider>(context, listen: false);
    prDialog = ProgressDialog(context);

    _getData();
    super.initState();
  }

  _getData() async {
    selectTimeDefault();
    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;

      bookAppointmentProvider.notifyListener();
    });
  }

  @override
  void dispose() {
    printLog("============ dispose called! ============");
    bookAppointmentProvider.clearProvider();
    super.dispose();
  }

  selectTimeDefault() async {
    // Get today's date
    DateTime today = DateTime.now();

    // Format today's date
    strDate = Utils.formateFullDate(today.toString());
    printLog('strDate ==>> $strDate');

    // Fetch available times based on today's date
    await bookAppointmentProvider.getClickAvailableTime(0);
    await bookAppointmentProvider.getTimeSlotByDoctorId(
        widget.doctorID, today.weekday);

    // Check if the first appointment time slot is booked
    checkAndStoreValues();
  }

  void checkAndStoreValues() {
    // Check if the first appointment time slot is booked
    if (bookAppointmentProvider
            .timeSlotModel.result?[0].timeSlotes?[0].timeSchedul?[0].isBook ==
        0) {
      bookAppointmentProvider.getClickPickTime(0);

      strStartTime = bookAppointmentProvider.timeSlotModel.result?[0]
              .timeSlotes?[0].timeSchedul?[0].startTime ??
          "";
      strEndTime = bookAppointmentProvider.timeSlotModel.result?[0]
              .timeSlotes?[0].timeSchedul?[0].endTime ??
          "";
      appointmentSlotId = bookAppointmentProvider.timeSlotModel.result?[0]
              .timeSlotes?[0].timeSchedul?[0].appointmentSlotsId ??
          "";
    } else {
      // First appointment slot is booked, clear values
      strStartTime = "";
      strEndTime = "";
      appointmentSlotId = "";
    }

    // Log the extracted values
    printLog('strStartTime ======> $strStartTime');
    printLog('strEndTime ======> $strEndTime');
    printLog('appointmentSlotId ======> $appointmentSlotId');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Rescheduleprovider>(
        builder: (context, rescheduleprovider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        appBar:
            Utils.myAppBarWithBack(context, "session_reschedule", true, true),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MyText(
                  text: "choose_date",
                  multilanguage: true,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.bold,
                  maxline: 1,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 20),
                child: DatePicker(
                  height: 90,
                  initialSelectedDate: DateTime.now(),
                  DateTime.now(),
                  controller: mDateController,
                  selectionColor: white,
                  selectedTextColor: colorPrimary,
                  deactivatedColor: gray,
                  onDateChange: (date) async {
                    printLog('Clicked date ==>> $date');
                    strDate = Utils.formateFullDate(date.toString());
                    printLog('strDate ==>> $strDate');

                    await bookAppointmentProvider.getClickAvailableTime(0);
                    await bookAppointmentProvider.getTimeSlotByDoctorId(
                        widget.doctorID, date.weekday);

                    // Check and store values based on the new date
                    checkAndStoreValues();
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MyText(
                  text: "available_time",
                  multilanguage: true,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.bold,
                  maxline: 1,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(child: availableTimeList()),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: MyText(
                  text: "choose_time_slot",
                  multilanguage: true,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.w500,
                  maxline: 1,
                  textalign: TextAlign.start,
                  color: grayDark,
                ),
              ),
              const SizedBox(height: 8),
              appointmentTimeList(),
              const SizedBox(height: 17),
              InkWell(
                onTap: () {
                  validateAndMake();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                  margin: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: colorPrimaryDark,
                      borderRadius: BorderRadius.circular(10)),
                  child: MyText(
                    color: white,
                    text: "confirm_reschedule",
                    fontsize: Dimens.text15Size,
                    multilanguage: true,
                    fontweight: FontWeight.w500,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    fontstyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget availableTimeList() {
    return Consumer<Rescheduleprovider>(
      builder: (context, timeSlotProvider, child) {
        if (!timeSlotProvider.loading) {
          if (timeSlotProvider.timeSlotModel.status == 200) {
            if (timeSlotProvider.timeSlotModel.result?[0].timeSlotes != null) {
              if ((timeSlotProvider
                          .timeSlotModel.result?[0].timeSlotes?.length ??
                      0) >
                  0) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: timeSlotProvider
                            .timeSlotModel.result?[0].timeSlotes?.length ??
                        0,
                    itemBuilder: (context, position) {
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          printLog("Clicked position ===>  $position");
                          await bookAppointmentProvider
                              .getClickAvailableTime(position);

                          // Check if the selected time slot is available
                          if (timeSlotProvider
                                  .timeSlotModel
                                  .result?[0]
                                  .timeSlotes?[position]
                                  .timeSchedul?[0]
                                  .isBook ==
                              0) {
                            await bookAppointmentProvider.getClickPickTime(0);
                            strStartTime = timeSlotProvider
                                    .timeSlotModel
                                    .result?[0]
                                    .timeSlotes?[position]
                                    .timeSchedul?[0]
                                    .startTime ??
                                "";
                            strEndTime = timeSlotProvider
                                    .timeSlotModel
                                    .result?[0]
                                    .timeSlotes?[position]
                                    .timeSchedul?[0]
                                    .endTime ??
                                "";
                            appointmentSlotId = timeSlotProvider
                                    .timeSlotModel
                                    .result?[0]
                                    .timeSlotes?[position]
                                    .timeSchedul?[0]
                                    .appointmentSlotsId ??
                                "";
                            printLog('strStartTime ======> $strStartTime');
                            printLog('strEndTime ======> $strEndTime');
                            printLog(
                                'appointmentSlotId ======> $appointmentSlotId');
                          } else {
                            // If the selected time slot is booked, clear the values
                            strStartTime = "";
                            strEndTime = "";
                            appointmentSlotId = "";
                            printLog(
                                'Selected time slot is booked, values cleared.');
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: timeSlotProvider.availableTimePos != null &&
                                    timeSlotProvider.availableTimePos ==
                                        position
                                ? colorPrimary
                                : colorAccent,
                          ),
                          child: MyText(
                            text:
                                "${Utils.formateTime(timeSlotProvider.timeSlotModel.result?[0].timeSlotes?[position].startTime ?? "")} To ${Utils.formateTime(timeSlotProvider.timeSlotModel.result?[0].timeSlotes?[position].endTime ?? "")} ",
                            fontsize: Dimens.text15Size,
                            fontstyle: FontStyle.normal,
                            fontweight: FontWeight.w500,
                            textalign: TextAlign.center,
                            color: timeSlotProvider.availableTimePos != null &&
                                    timeSlotProvider.availableTimePos ==
                                        position
                                ? white
                                : colorPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                return const NoData(text: "");
              }
            } else {
              return Container();
            }
          } else {
            return Container();
          }
        } else {
          return Utils.pageLoader();
        }
      },
    );
  }

  Widget search() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: TextFormField(
          controller: mReasonController,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.next,
          obscureText: false,
          maxLines: 1,
          textAlign: TextAlign.start,
          readOnly: false,
          onChanged: (value) {
            if (value.toString().isNotEmpty) {
              printLog("value ==> $value");
            }
          },
          onFieldSubmitted: (searchedText) async {
            if (searchedText.toString().isNotEmpty) {}
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(top: 10, left: 10),
            filled: true,
            fillColor: white,
            hintText: Locales.string(context, "write_your_reasons"),
            hintStyle: GoogleFonts.roboto(
              fontSize: 16,
              color: grayDark,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              fontSize: 16,
              color: textTitleColor,
              fontWeight: FontWeight.normal,
              fontStyle: FontStyle.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget appointmentTimeList() {
    return Consumer<Rescheduleprovider>(
      builder: (context, timeSlotProvider, child) {
        if (!timeSlotProvider.loading) {
          if (timeSlotProvider.timeSlotModel.status == 200) {
            if (timeSlotProvider.timeSlotModel.result != null) {
              final timeSlots =
                  timeSlotProvider.timeSlotModel.result?[0].timeSlotes;
              if (timeSlots != null && timeSlots.isNotEmpty) {
                final selectedTimeSlot =
                    timeSlots[timeSlotProvider.availableTimePos ?? 0];
                final timeSchedules = selectedTimeSlot.timeSchedul;

                if (timeSchedules != null && timeSchedules.isNotEmpty) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: ResponsiveGridList(
                      minItemWidth: 120,
                      verticalGridSpacing: 5,
                      horizontalGridSpacing: 5,
                      minItemsPerRow: 3,
                      maxItemsPerRow: 3,
                      listViewBuilderOptions: ListViewBuilderOptions(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                      children: List.generate(timeSchedules.length, (position) {
                        final schedule = timeSchedules[position];
                        final isSelected =
                            timeSlotProvider.pickTimePos == position;

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () async {
                            if (schedule.isBook == 0) {
                              await bookAppointmentProvider
                                  .getClickPickTime(position);
                              // Update the selected time slot details
                              strStartTime = schedule.startTime ?? "";
                              strEndTime = schedule.endTime ?? "";
                              appointmentSlotId =
                                  schedule.appointmentSlotsId ?? "";
                              printLog("strStartTime ====> $strStartTime");
                              printLog("strEndTime ====> $strEndTime");
                              printLog("appointmentSlotId ====> $strStartTime");
                            } else {
                              Utils.showSnackbar(
                                  context, "alreadysimeselected", true);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: schedule.isBook == 0
                                  ? (isSelected ? colorPrimary : colorAccent)
                                  : grayLight,
                            ),
                            child: MyText(
                              text: Utils.formateTimeSetInColumn(
                                  schedule.startTime ?? ""),
                              fontsize: Dimens.text14Size,
                              fontstyle: FontStyle.normal,
                              fontweight: FontWeight.normal,
                              textalign: TextAlign.center,
                              color: schedule.isBook == 0
                                  ? (isSelected ? white : colorPrimary)
                                  : black,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                } else {
                  return const NoData(text: 'no_time_slots');
                }
              } else {
                return const SizedBox.shrink();
              }
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  validateAndMake() async {
    if ((strDate ?? "").isEmpty) {
      Utils.showToast("Select appointment date");
    } else if (strStartTime!.isEmpty) {
      Utils.showToast("Select appointment time");
    } else {
      if (!mounted) return;
      Utils.showProgress(context, prDialog);

      await bookAppointmentProvider.getUpdateRescudule(
        widget.appointmentID,
        strDate,
        strStartTime,
        strEndTime,
      );
      if (!bookAppointmentProvider.loading) {
        await prDialog.hide();
        if (!mounted) return;
        if (bookAppointmentProvider.successModel.status == 200) {
          Utils.showSnackbar(context,
              bookAppointmentProvider.successModel.message ?? "", false);
          Navigator.pop(context);
        } else {
          if (!mounted) return;
          Utils.showSnackbar(context,
              bookAppointmentProvider.successModel.message ?? "", false);
        }
      }
    }
  }
}
