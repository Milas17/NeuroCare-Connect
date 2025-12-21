import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/appointment_details_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/network/encounter_repository.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/appointment_fragment.dart';
import 'package:kivicare_flutter/screens/encounter/screen/encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/patient_encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/int_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentDetailsModel appointment;
  final VoidCallback? refreshCall;

  AppointmentDetailScreen({required this.appointment, this.refreshCall});

  @override
  State<AppointmentDetailScreen> createState() => _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  bool get showEncounterButton {
    if (isReceptionist() || isDoctor()) {
      // Doctor & Receptionist → Show encounter when appointment is Check-In
      return (isVisible(SharedPreferenceKey.kiviCarePatientEncounterAddKey) && widget.appointment.status!.toInt() == CheckInStatusInt);
    }

    if (isPatient()) {
      // Patient → Show encounter ONLY after doctor closes (Check-Out)
      return (isVisible(SharedPreferenceKey.kiviCarePatientEncounterViewKey) && widget.appointment.status!.toInt() == CheckOutStatusInt);
    }

    return false;
  }

  bool get showCheckInButton {
    if (isVisible(SharedPreferenceKey.kiviCarePatientAppointmentStatusChangeKey)) {
      bool beforeTime = getDateDifference(widget.appointment.appointmentGlobalStartDate.validate()) == 0;
      return ((isDoctor() || isReceptionist()) && (widget.appointment.status!.toInt() == BookedStatusInt || widget.appointment.status!.toInt() == CheckInStatusInt) && beforeTime);
    } else
      return false;
  }

  bool get ifCheckIn {
    return ((isDoctor() || isReceptionist()) && widget.appointment.status!.toInt() == CheckInStatusInt);
  }

  bool get showGoogleMeet {
    bool gMeetIsON = false;
    if (!isReceptionist()) {
      if (widget.appointment.googleMeetData.validate().isNotEmpty && (widget.appointment.status!.toInt() != CancelledStatusInt || widget.appointment.status!.toInt() != PendingStatusInt) && widget.appointment.status!.toInt() != CheckOutStatusInt) {
        return gMeetIsON = true;
      }
    }
    return gMeetIsON;
  }

  bool get showZoom {
    bool gZoomIsON = false;
    if (!isReceptionist()) {
      if (widget.appointment.zoomData != null && (widget.appointment.status!.toInt() != CancelledStatusInt || widget.appointment.status!.toInt() != PendingStatusInt) && widget.appointment.status!.toInt() != CheckOutStatusInt) {
        return gZoomIsON = true;
      }
    }
    return gZoomIsON;
  }

  void closeEncounter({String? appointmentId, bool isCheckOut = false, required int encounterId}) async {
    Map<String, dynamic> request = {
      "encounter_id": encounterId,
    };
    if (isCheckOut) {
      request.putIfAbsent("appointment_id", () => appointmentId.validate());
      request.putIfAbsent("appointment_status", () => CheckOutStatusInt);
    }
    appStore.setLoading(true);

    await encounterClose(request).then((value) {
      appStore.setLoading(false);
      appointmentStreamController.add(true);
      toast(value.message);
      if (isCheckOut) {
        widget.appointment.status = CheckOutStatusInt;
      }
      widget.refreshCall?.call();
      setState(() {});
      finish(context, isCheckOut);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void changeAppointmentStatus() async {
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (p0) {
        return buildChangeStatusWidget();
      },
    );
  }

  String nextStatus(String status) {
    if (status.validate().toInt() == 0) return '';
    if (status.validate().toInt() % 4 == 1)
      return locale.lblCheckIn;
    else if (status.validate().toInt() % 4 == 2)
      return locale.lblPending;
    else if (status.validate().toInt() % 4 == 3)
      return locale.lblClose;
    else if (status.validate().toInt() == 4) return locale.lblCheckOut;

    return '';
  }

  void updateStatus({int? id, int? status}) async {
    appStore.setLoading(true);

    Map<String, dynamic> request = {
      "appointment_id": id.toString(),
      "appointment_status": status.toString(),
    };

    await updateAppointmentStatus(request).then((value) {
      appointmentStreamController.add(true);
      toast(locale.lblChangedTo + " ${status.getStatus()}");
      widget.appointment.status = status;
      appStore.setLoading(false);
      widget.refreshCall?.call();
      setState(() {});
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  Widget buildChangeStatusWidget() {
    return Container(
      color: context.cardColor,
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ic_appointment, color: appStore.isDarkModeOn ? Colors.white : Colors.black, fit: BoxFit.cover),
          16.height,
          Text(locale.lblChangingStatusFrom, style: primaryTextStyle(), textAlign: TextAlign.center),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(getStatus(widget.appointment.status.toString().validate()), style: boldTextStyle(size: 20)),
              Container(child: Icon(Icons.arrow_forward, size: 20)),
              Text(nextStatus(widget.appointment.status.toString().validate()), style: boldTextStyle(size: 20, color: primaryColor)),
            ],
          ).center(),
          32.height,
          Row(
            children: [
              AppButton(
                color: context.scaffoldBackgroundColor,
                text: locale.lblCancel,
                onTap: () => finish(context),
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: context.primaryColor)),
                textColor: context.primaryColor,
              ).expand(),
              16.width,
              Observer(
                builder: (context) {
                  return AppButton(
                    color: context.primaryColor,
                    text: locale.lblChange,
                    onTap: () async {
                      updateStatus(id: widget.appointment.id!.toInt(), status: 4);
                    },
                  ).expand().visible(!appStore.isLoading, defaultWidget: LoaderWidget(size: 30).expand());
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  void _handleCheckInOutButton() {
    if (ifCheckIn && widget.appointment.encounterStatus == 1) {
      toast(locale.lblPleaseCloseTheEncounterToCheckoutPatient);
    } else {
      if (ifCheckIn && widget.appointment.encounterStatus == 0) {
        showConfirmDialogCustom(
          context,
          title: locale.lblDoYouWantToCheckoutAppointment,
          dialogType: DialogType.CONFIRMATION,
          primaryColor: appPrimaryColor,
          onAccept: (p0) {
            closeEncounter(encounterId: widget.appointment.encounterId.toInt(), appointmentId: widget.appointment.id.toString(), isCheckOut: true);
          },
        );
      } else
        changeAppointmentStatus();
    }
  }

  void _handleEncounterButton() {
    if (isPatient()) {
      PatientEncounterDashboardScreen(
        id: widget.appointment.encounterId.validate(),
        callBack: () => widget.refreshCall?.call(),
      ).launch(context);
    } else {
      EncounterDashboardScreen(encounterId: widget.appointment.encounterId.validate()).launch(context).then(
        (value) {
          if (value != null) {
            if (value) {
              widget.refreshCall?.call();
              setState(() {});
              updateStatus(id: widget.appointment.encounterId.validate().toInt(), status: CheckOutStatusInt);
            } else {
              widget.refreshCall?.call();
              setState(() {});
            }
          }
        },
      );
    }
  }

  void _handleTelemedButton() {
    if ((isDoctor() || isPatient()) && widget.appointment.googleMeetData != null) {
      meetLaunch(widget.appointment.googleMeetData.validate());
    } else {
      toast(locale.lblYouCannotStart);
    }
  }

  void _handleZoomButton() {
    if ((isDoctor() || isPatient()) && widget.appointment.zoomData != null) {
      zoomLaunch(isPatient() ? widget.appointment.zoomData!.joinUrl.validate() : widget.appointment.zoomData!.startUrl.validate());
    } else {
      toast(locale.lblYouCannotStart);
    }
  }

  String getFileNameFromUrl(String url) {
    return url.split('/').last;
  }

  String getStatusText(int status) {
    switch (status) {
      case 1:
        return locale.lblBooked;
      case 2:
        return locale.lblCompleted;
      case 3:
        return locale.lblCheckOut;
      case 4:
        return locale.lblCheckIn;
      default:
        return locale.lblCancelled;
    }
  }

  Color getStatusColor(BuildContext context, int status) {
    switch (status) {
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case 3:
        return Colors.deepOrange;
      case 4:
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        "${locale.lblAppointments} #${widget.appointment.id.validate()}",
        textColor: Colors.white,
        color: context.primaryColor,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ----------------- Session Summary -----------------
            sectionTitle(locale.lblSessionSummary),
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 20),
              padding: EdgeInsets.all(12),
              decoration: boxDecorationDefault(color: context.cardColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  rowItem(context, "${locale.lblDateandTime}:", "${widget.appointment.appointmentStartDate.validate()} at ${widget.appointment.appointmentStartTime.validate()}"),
                  rowItem(context, "${locale.lblAppointmentStatus}:", getStatusText(widget.appointment.status.validate()), valueColor: getStatusColor(context, widget.appointment.status.validate())),
                  rowItem(
                    context,
                    "${locale.lblPaymentStatus}:",
                    widget.appointment.paymentStatus == 1 ? locale.lblPaid : locale.lblUnPaid,
                    valueColor: widget.appointment.paymentStatus == 1 ? Colors.green : Colors.orange,
                  ),
                ],
              ),
            ),

            /// ----------------- Medical History -----------------
            sectionTitle(locale.lblMedicalHistory),
            if (widget.appointment.appointmentReport?.isNotEmpty ?? false)
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 20),
                padding: EdgeInsets.all(12),
                decoration: boxDecorationDefault(color: context.cardColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.appointment.appointmentReport!.asMap().entries.map((entry) {
                    int i = entry.key;
                    var report = entry.value;

                    String fileName = getFileNameFromUrl(report.url.validate());
                    String ext = fileName.split('.').last.toLowerCase();

                    IconData fileIcon;
                    if (ext == 'pdf') {
                      fileIcon = Icons.picture_as_pdf;
                    } else if (['jpg', 'jpeg', 'png'].contains(ext)) {
                      fileIcon = Icons.image;
                    } else if (ext == 'txt') {
                      fileIcon = Icons.description;
                    } else {
                      fileIcon = Icons.insert_drive_file;
                    }

                    return Row(
                      children: [
                        Icon(fileIcon, color: context.iconColor),
                        8.width,
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              commonLaunchUrl(report.url.validate(), launchMode: LaunchMode.externalApplication);
                            },
                            child: Text(
                              "Report ${i + 1} ($fileName)",
                              style: primaryTextStyle(size: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ).paddingSymmetric(vertical: 6);
                  }).toList(),
                ),
              )
            else
              Container(
                margin: EdgeInsets.only(top: 12, bottom: 20),
                padding: EdgeInsets.all(12),
                decoration: boxDecorationDefault(color: context.cardColor),
                child: Row(
                  children: [
                    Icon(Icons.history, color: context.iconColor),
                    8.width,
                    Text("${locale.lblNoReportsFound}", style: secondaryTextStyle()),
                  ],
                ),
              ),

            /// ----------------- Clinic Info -----------------
            if (isDoctor() || isPatient()) ...[
              sectionTitle(locale.lblClinicInfo),
              infoCard(
                context: context,
                img: widget.appointment.clinicProfileImg,
                title: widget.appointment.clinicName.validate(),
                email: widget.appointment.clinicEmail.validate(),
              ),
              20.height,
            ],

            /// ----------------- Doctor Info -----------------
            if (isReceptionist() || isPatient()) ...[
              sectionTitle(locale.lblDoctorInfo),
              infoCard(
                context: context,
                img: widget.appointment.doctorProfileImg,
                title: widget.appointment.doctorName.validate(),
                email: widget.appointment.doctorEmail.validate(),
              ),
              20.height,
            ],

            /// ----------------- Patient Info -----------------
            if (isDoctor() || isReceptionist()) ...[
              sectionTitle(locale.lblPatientInfo),
              infoCard(
                context: context,
                img: widget.appointment.patientProfileImg,
                title: widget.appointment.patientName.validate(),
                email: widget.appointment.patientEmail.validate(),
              ),
              20.height,
            ],

            /// ----------------- About Service -----------------
            /// ----------------- About Service -----------------
            sectionTitle(locale.lblAboutService),
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 20),
              padding: EdgeInsets.all(12),
              decoration: boxDecorationDefault(color: context.cardColor),
              child: (widget.appointment.visitType != null && widget.appointment.visitType!.isNotEmpty)
                  ? Column(
                      children: widget.appointment.visitType!.map((s) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: s.servicesProfileImg.validate().isNotEmpty ? NetworkImage(s.servicesProfileImg!) : AssetImage(ic_services) as ImageProvider,
                            ),
                            12.width,
                            Expanded(
                              child: Text(
                                s.serviceName.validate(),
                                style: boldTextStyle(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            4.width,
                            Text("\$${s.charges.validate()}", style: secondaryTextStyle()),
                          ],
                        ).paddingSymmetric(vertical: 8);
                      }).toList(),
                    )
                  : Row(
                      children: [
                        Icon(Icons.info_outline, color: context.iconColor),
                        8.width,
                        Text(
                          locale.lblServiceIsDeletedCurrentlyUnavailable,
                          style: secondaryTextStyle(color: Colors.red),
                        ),
                      ],
                    ),
            ),

            /// ----------------- Payment Details -----------------
            sectionTitle(locale.lblPaymentDetails),
            Container(
              margin: EdgeInsets.only(top: 12, bottom: 20),
              padding: EdgeInsets.all(12),
              decoration: boxDecorationDefault(color: context.cardColor),
              child: (widget.appointment.visitType != null && widget.appointment.visitType!.isNotEmpty)
                  ? Column(
                      children: [
                        rowItem(context, locale.lblServiceTotal, "\$${widget.appointment.allServiceCharges.validate()}"),
                        rowItem(context, "${locale.lblDiscount}", "-\$${widget.appointment.discount.validate()}", valueColor: Colors.green),
                        rowItem(context, locale.lblExclusiveTax, "\$${widget.appointment.taxData?.totalTax.validate() ?? "0"}", valueColor: Colors.red),
                        Divider(color: context.dividerColor),
                        rowItem(context, "${locale.lblTotal}", "\$${widget.appointment.totalAmount.validate()}", isBold: true, valueColor: context.primaryColor),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.orange),
                        8.width,
                        Expanded(
                          // 👈 Fix applied here
                          child: Text(
                            locale.lblPaymentDetailsNotAvailable,
                            style: secondaryTextStyle(color: Colors.orange),
                            maxLines: 2, // optional: wrap into 2 lines
                            overflow: TextOverflow.ellipsis, // optional: ellipsis if too long
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),

      /// ---------- Bottom Buttons ----------
      // bottomNavigationBar: Container(
      //   padding: EdgeInsets.all(12),
      //   decoration: boxDecorationDefault(color: context.cardColor),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       if (showGoogleMeet)
      //         Expanded(
      //           child: AppButton(
      //             text: isPatient() ? locale.lblJoin : locale.lblStart,
      //             color: telemedColor,
      //             onTap: _handleTelemedButton,
      //           ),
      //         ),
      //       if (showZoom)
      //         Expanded(
      //           child: AppButton(
      //             text: isPatient() ? locale.lblJoin : locale.lblStart,
      //             color: zoomColor,
      //             onTap: _handleZoomButton,
      //           ),
      //         ),
      //       if (showEncounterButton)
      //         Expanded(
      //           child: AppButton(
      //             text: locale.lblEncounter,
      //             color: context.primaryColor,
      //             onTap: _handleEncounterButton,
      //           ),
      //         ),
      //       if (showCheckInButton)
      //         Expanded(
      //             child: Row(
      //           children: [
      //             if (showCheckInButton) ...[
      //               if (!ifCheckIn)
      //                 AppButton(
      //                   text: "Check-In",
      //                   color: appSecondaryColor,
      //                   onTap: _handleCheckInOutButton,
      //                 ),
      //               if (ifCheckIn && widget.appointment.paymentStatus == 1 && widget.appointment.encounterStatus == 0)
      //                 AppButton(
      //                   text: "Check-Out",
      //                   color: appSecondaryColor,
      //                   onTap: _handleCheckInOutButton,
      //                 ),
      //             ],
      //           ],
      //         )),
      //     ],
      //   ),
      // ),
      bottomNavigationBar: Builder(
        builder: (context) {
          // Collect all the buttons you want to show
          List<Widget> buttons = [];

          if (showGoogleMeet) {
            buttons.add(
              AppButton(
                text: isPatient() ? locale.lblJoin : locale.lblStart,
                color: telemedColor,
                onTap: _handleTelemedButton,
              ),
            );
          }

          if (showZoom) {
            buttons.add(
              AppButton(
                text: isPatient() ? locale.lblJoin : locale.lblStart,
                color: zoomColor,
                onTap: _handleZoomButton,
              ),
            );
          }

          if (showEncounterButton) {
            buttons.add(
              AppButton(
                text: locale.lblEncounter,
                color: context.primaryColor,
                onTap: _handleEncounterButton,
              ),
            );
          }

          if (showCheckInButton) {
            if (!ifCheckIn) {
              buttons.add(
                AppButton(
                  text: locale.lblCheckIn,
                  color: appSecondaryColor,
                  onTap: _handleCheckInOutButton,
                ),
              );
            } else if (ifCheckIn && widget.appointment.paymentStatus == 1 && widget.appointment.encounterStatus == 0) {
              buttons.add(
                AppButton(
                  text: locale.lblCheckOut,
                  color: appSecondaryColor,
                  onTap: _handleCheckInOutButton,
                ),
              );
            }
          }

          // ✅ If there are no buttons → return an empty widget
          if (buttons.isEmpty) {
            return SizedBox(); // 👈 This prevents the "null return" warning
          }

          // ✅ When there are buttons, display them evenly spaced
          return Container(
            padding: EdgeInsets.all(12),
            decoration: boxDecorationDefault(color: context.cardColor),
            child: Row(
              children: buttons.map((btn) => Expanded(child: btn)).expand((widget) => [widget, 12.width]).toList()..removeLast(), // remove last extra spacing
            ),
          ).visible(showCheckInButton || showEncounterButton || showGoogleMeet || showZoom);
        },
      ),
    );
  }

  Widget sectionTitle(String text) => Text(text, style: boldTextStyle(size: 18));

  Widget rowItem(BuildContext context, String title, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: primaryTextStyle()),
          Text(value, style: isBold ? boldTextStyle(color: valueColor ?? textPrimaryColorGlobal) : secondaryTextStyle(color: valueColor)),
        ],
      ),
    );
  }

  Widget infoCard({
    required BuildContext context,
    String? img,
    required String title,
    String? subTitle1,
    String? subTitle2,
    String? email,
  }) {
    return Container(
      margin: EdgeInsets.only(top: 12),
      padding: EdgeInsets.all(12),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage: img.validate().isNotEmpty ? NetworkImage(img!) : AssetImage(ic_clinic) as ImageProvider,
          ),
          12.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: boldTextStyle()),
              if (subTitle1.validate().isNotEmpty) ...[
                6.height,
                Text(subTitle1!, style: secondaryTextStyle()),
              ],
              if (subTitle2.validate().isNotEmpty) ...[
                6.height,
                Text(subTitle2!, style: secondaryTextStyle(color: context.primaryColor)),
              ],
              if (email.validate().isNotEmpty) ...[
                6.height,
                Text(email!, style: secondaryTextStyle(color: Colors.red)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
