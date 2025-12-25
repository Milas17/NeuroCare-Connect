import 'dart:convert';
import 'package:yourappname/provider/addworkslotprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddWorkSlot extends StatefulWidget {
  final String weekDay;
  final int weekDayPos;
  final String date;
  const AddWorkSlot(this.weekDay, this.weekDayPos, this.date, {super.key});

  @override
  State<AddWorkSlot> createState() => _AddWorkSlotState();
}

class _AddWorkSlotState extends State<AddWorkSlot> {
  late ProgressDialog prDialog;
  late AddWorkSlotProvider addWorkSlotProvider = AddWorkSlotProvider();
  TimeOfDay currentTime = TimeOfDay.now();

  @override
  void initState() {
    printLog("============ weekDay ! ============ ${widget.weekDay}");
    printLog("============ weekDayPos ! ============ ${widget.weekDayPos}");

    prDialog = ProgressDialog(context);
    addWorkSlotProvider =
        Provider.of<AddWorkSlotProvider>(context, listen: false);
    addWorkSlotProvider.getWorkingSlots(widget.date);
    super.initState();
  }

  @override
  void dispose() {
    printLog("============ dispose called! ============");
    addWorkSlotProvider.clearWrokSlotProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "state_work_hours", true, true),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: createWorkSlotList(),
              ),
            ],
          ),
          Positioned(
            bottom: 60,
            right: 10,
            child: FloatingActionButton(
              onPressed: () {
                printLog(
                    "slotList length ====> ${addWorkSlotProvider.slotList.isNotEmpty ? addWorkSlotProvider.slotList.length : 0}");
                printLog("weekDay ====> ${widget.weekDay}");
                addWorkSlotProvider.addEmptySlot(widget.weekDay);
              },
              backgroundColor: colorPrimaryDark,
              child: const Icon(
                Icons.add,
                color: white,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            child: InkWell(
              onTap: () {
                validateAndSave();
              },
              child: Container(
                height: Constant.buttonHeight,
                width: MediaQuery.of(context).size.width * 0.4,
                margin: const EdgeInsets.only(left: 5, right: 5),
                alignment: Alignment.center,
                decoration: Utils.primaryDarkButton(),
                child: MyText(
                  text: "save",
                  multilanguage: true,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.normal,
                  textalign: TextAlign.center,
                  color: white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createWorkSlotList() {
    return Consumer<AddWorkSlotProvider>(
      builder: (context, addWorkSlotProvider, child) {
        if (!addWorkSlotProvider.loading) {
          if (addWorkSlotProvider.workingTimeSlotModel.status == 200) {
            if (addWorkSlotProvider.workingTimeSlotModel.result != null &&
                (addWorkSlotProvider.workingTimeSlotModel.result?.length ?? 0) >
                    0) {
              if ((addWorkSlotProvider
                          .workingTimeSlotModel.result?[0].timeSlotes?.length ??
                      0) >
                  0) {
                addWorkSlotProvider.slotList = addWorkSlotProvider
                        .workingTimeSlotModel.result?[0].timeSlotes ??
                    [];
                printLog(
                    "createWorkSlotList slotList size ===> ${addWorkSlotProvider.slotList.length}");
              }
            }
          }
          if (addWorkSlotProvider.slotList.isNotEmpty) {
            return ListView.builder(
              scrollDirection: Axis.vertical,
              padding: const EdgeInsets.only(bottom: 120),
              physics: const AlwaysScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: addWorkSlotProvider.slotList.length,
              itemBuilder: (BuildContext context, int position) {
                return Container(
                  key: ValueKey(position),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      constraints: const BoxConstraints(
                        minHeight: 0,
                      ),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(12),
                        shape: BoxShape.rectangle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    printLog('position => $position');
                                    selectTime(position, "Start");
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MyText(
                                        text: "start_time",
                                        multilanguage: true,
                                        fontsize: Dimens.text14Size,
                                        fontstyle: FontStyle.normal,
                                        fontweight: FontWeight.normal,
                                        textalign: TextAlign.start,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        color: otherColor,
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 45,
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: grayDark,
                                            width: .5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            MyText(
                                              text: addWorkSlotProvider
                                                      .slotList[position]
                                                      .startTime ??
                                                  '--:--',
                                              fontsize: Dimens.text15Size,
                                              fontstyle: FontStyle.normal,
                                              fontweight: FontWeight.normal,
                                              textalign: TextAlign.start,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              color: textTitleColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              MyText(
                                text: "to",
                                fontsize: Dimens.text16Size,
                                multilanguage: true,
                                fontstyle: FontStyle.normal,
                                fontweight: FontWeight.w400,
                                textalign: TextAlign.center,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                                color: textTitleColor,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    printLog('position => $position');
                                    selectTime(position, "End");
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      MyText(
                                        text: "end_time",
                                        multilanguage: true,
                                        fontsize: Dimens.text14Size,
                                        fontstyle: FontStyle.normal,
                                        fontweight: FontWeight.normal,
                                        textalign: TextAlign.start,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        color: otherColor,
                                      ),
                                      const SizedBox(height: 3),
                                      Container(
                                        height: 45,
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: grayDark,
                                            width: .5,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          shape: BoxShape.rectangle,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            MyText(
                                              text: addWorkSlotProvider
                                                      .slotList[position]
                                                      .endTime ??
                                                  '--:--',
                                              fontsize: Dimens.text15Size,
                                              fontstyle: FontStyle.normal,
                                              fontweight: FontWeight.normal,
                                              textalign: TextAlign.start,
                                              maxline: 1,
                                              overflow: TextOverflow.ellipsis,
                                              color: textTitleColor,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              InkWell(
                                  onTap: () async {
                                    printLog('Tapped on Delete! => $position');
                                    if (addWorkSlotProvider
                                            .slotList[position].id
                                            .toString() !=
                                        "0") {
                                      Utils.showProgress(context, prDialog);
                                    }
                                    await addWorkSlotProvider.deleteSlot(
                                        addWorkSlotProvider
                                            .slotList[position].id,
                                        position);
                                    prDialog.hide();
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color:
                                          rejectedStatus.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Iconify(
                                      MaterialSymbols.delete_outline,
                                      size: 20,
                                      color: rejectedStatus,
                                    ),
                                  )),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Card(
                            color: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Container(
                              height: Constant.textFieldHeight,
                              padding:
                                  const EdgeInsets.only(left: 15, right: 15),
                              // decoration: Utils.textFieldBGWithBorder(),
                              alignment: Alignment.centerLeft,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButtonFormField2(
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  value: ((addWorkSlotProvider
                                                  .slotList[position]
                                                  .timeSchedul
                                                  ?.length ??
                                              0) >
                                          0)
                                      ? addWorkSlotProvider.slotList[position]
                                                  .timeDuration !=
                                              "00"
                                          ? "${addWorkSlotProvider.slotList[position].timeDuration ?? ""} minutes"
                                          : selectDuration
                                      : selectDuration,
                                  onChanged: (String? newValue) {
                                    printLog('newValue :=> $newValue');
                                    printLog('position :=> $position');

                                    if (newValue != "") {
                                      if (addWorkSlotProvider.slotList[position]
                                                  .startTime !=
                                              "" &&
                                          addWorkSlotProvider
                                                  .slotList[position].endTime !=
                                              "") {
                                        if (newValue == "15 minutes") {
                                          addWorkSlotProvider.slotList[position]
                                              .timeDuration = "15";
                                        } else if (newValue == "30 minutes") {
                                          addWorkSlotProvider.slotList[position]
                                              .timeDuration = "30";
                                        } else if (newValue == "45 minutes") {
                                          addWorkSlotProvider.slotList[position]
                                              .timeDuration = "45";
                                        } else if (newValue == "60 minutes") {
                                          addWorkSlotProvider.slotList[position]
                                              .timeDuration = "60";
                                        }
                                        printLog(
                                            'StartTime :=> ${addWorkSlotProvider.slotList[position].startTime}');
                                        printLog(
                                            'EndTime :=> ${addWorkSlotProvider.slotList[position].endTime}');
                                        if (addWorkSlotProvider
                                                    .slotList[position]
                                                    .startTime !=
                                                "00:00" &&
                                            addWorkSlotProvider
                                                    .slotList[position]
                                                    .endTime !=
                                                "00:00") {
                                          addWorkSlotProvider.createWorkTiming(
                                              context, position);
                                        }
                                      }
                                    }
                                  },
                                  hint: MyText(
                                    text: "duration",
                                    multilanguage: true,
                                    fontsize: Dimens.text16Size,
                                    fontweight: FontWeight.normal,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.start,
                                    color: textHintColor,
                                  ),
                                  items: <String>[
                                    selectDuration,
                                    '15 minutes',
                                    '30 minutes',
                                    '45 minutes',
                                    '60 minutes',
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: MyText(
                                        text: value,
                                        fontsize: Dimens.text15Size,
                                        fontweight: FontWeight.normal,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: textTitleColor,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          buildWorkTiming(position),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            return Container();
          }
        } else {
          return Utils.pageLoader();
        }
      },
    );
  }

  Future<void> selectTime(int position, String type) async {
    final TimeOfDay? pickedS = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    printLog("selectTime pickedS ==> $pickedS");
    printLog("selectTime type ==> $type");
    if (pickedS != null && pickedS != currentTime) {
      addWorkSlotProvider.updateTime(
          type,
          "${pickedS.hour < 10 && pickedS.hour > 0 ? "0${pickedS.hour}" : pickedS.hour}:${pickedS.minute < 10 && pickedS.minute > 0 ? "0${pickedS.minute}" : pickedS.minute == 0 ? "${pickedS.minute}0" : pickedS.minute}",
          position);
    }
  }

  Widget buildWorkTiming(int slotPos) {
    return Consumer<AddWorkSlotProvider>(
      builder: (context, addWorkSlotProvider, child) {
        if (addWorkSlotProvider.slotList[slotPos].timeSchedul != null ||
            (addWorkSlotProvider.slotList[slotPos].timeSchedul?.length ?? 0) >
                0) {
          if (addWorkSlotProvider.slotList[slotPos].startTime != "00:00" &&
              addWorkSlotProvider.slotList[slotPos].endTime != "00:00") {
            printLog(
                'buildWorkTiming timeSchedul => ${addWorkSlotProvider.slotList[slotPos].timeSchedul?.length}');

            return Container(
              key: ValueKey(slotPos),
              constraints: const BoxConstraints(
                minHeight: 0,
                minWidth: 0,
              ),
              child: GridView.builder(
                itemCount:
                    addWorkSlotProvider.slotList[slotPos].timeSchedul!.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 2 / 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (BuildContext context, int position) {
                  return Container(
                    key: ValueKey(slotPos),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 8, right: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: otherLightColor,
                        width: .5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      shape: BoxShape.rectangle,
                    ),
                    child: MyText(
                      text: addWorkSlotProvider.slotList[slotPos]
                              .timeSchedul![position].startTime ??
                          "--:--",
                      fontsize: Dimens.text11Size,
                      fontstyle: FontStyle.normal,
                      fontweight: FontWeight.normal,
                      textalign: TextAlign.start,
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                      color: textTitleColor,
                    ),
                  );
                },
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void validateAndSave() async {
    if (addWorkSlotProvider.slotList.isNotEmpty) {
      List<Map<String, dynamic>> finalScheduleList = [];

      // Format today's date (or widget.date)
      String formattedDate = Utils.formatDates(
        DateTime.parse(widget.date),
        "yyyy-MM-dd",
      );

      // Validate and prepare times
      List<Map<String, dynamic>> timeList = [];

      for (int i = 0; i < addWorkSlotProvider.slotList.length; i++) {
        var slot = addWorkSlotProvider.slotList[i];

        if (slot.startTime == "00:00") {
          Utils.showSnackbar(context, selectStartTime, false);
          return;
        }
        if (slot.endTime == "00:00") {
          Utils.showSnackbar(context, selectEndTime, false);
          return;
        }
        if (slot.startTime == slot.endTime) {
          Utils.showSnackbar(context, startEndTimeNotEqual, false);
          return;
        }
        if (slot.timeDuration == "00" ||
            slot.timeDuration == "" ||
            slot.timeDuration == selectDuration) {
          Utils.showSnackbar(context, selectDuration, false);
          return;
        }

        // Add each valid time slot
        timeList.add({
          "start_time": slot.startTime,
          "end_time": slot.endTime,
          "duration": int.parse(slot.timeDuration ?? ""),
        });
      }

      // Build the final structure
      finalScheduleList.add({
        "date": formattedDate,
        "times": timeList,
      });

      // Convert to JSON string
      String drSchedule = jsonEncode(finalScheduleList);

      printLog("drSchedule JSON ==> $drSchedule");

      // 🔹 Example Output:
      // [
      //   {
      //     "date":"2025-11-10",
      //     "times":[{"start_time":"10:00","end_time":"10:30","duration":30}]
      //   }
      // ]

      /* update_doctor_time_slots API */
      Utils.showProgress(context, prDialog);
      await addWorkSlotProvider.updateDoctorTimeSlot(drSchedule);
      if (!addWorkSlotProvider.loadingUpdate) {
        prDialog.hide();
        if (addWorkSlotProvider.successUpdateModel.status == 200) {
          if (!mounted) return;
          Navigator.pop(context, true);
        } else {
          Utils.showToast(addWorkSlotProvider.successUpdateModel.message ?? "");
        }
      }
    }
  }

}
