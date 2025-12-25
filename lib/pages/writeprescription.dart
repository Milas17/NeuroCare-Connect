import 'package:yourappname/pages/addmedicine.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/chatprovider.dart';
import 'package:yourappname/provider/writeprescriptionprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/mytextformfield.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class WritePrescription extends StatefulWidget {
  final String appointmentID,
      appointmentNo,
      patientID,
      patientName,
      patientImg,
      appointmentDate,
      doctorFirebaseID,
      symtoms,
      starttime,
      status,
      endTime;

  const WritePrescription(
      this.appointmentID,
      this.appointmentNo,
      this.patientID,
      this.patientName,
      this.patientImg,
      this.appointmentDate,
      this.doctorFirebaseID,
      this.starttime,
      this.symtoms,
      this.status,
      this.endTime,
      {super.key});

  @override
  State<WritePrescription> createState() => _WritePrescriptionState();
}

class _WritePrescriptionState extends State<WritePrescription>
    with SingleTickerProviderStateMixin {
  ProgressDialog? prDialog;
  final mSymptomsController = TextEditingController();
  final mReportController = TextEditingController();
  final mDiagnosisController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late WritePrescriptionProvider writePrescriptionProvider;
  late ChatProvider chatProvider;
  final _formReportKey = GlobalKey<FormState>();
  late String updatedStatus;
  String? pillName;
  int? medicineSize;
  int? medicineDuration;
  int? selectedTime;
  String? medicineNote;
  String? currentUserId;
  String? strSymptoms, strDiagnosis;
  SharedPre sharedPref = SharedPre();
  late TabController _tabController;
  ValueNotifier<bool> updateSaveBtn = ValueNotifier(false);

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    prDialog = ProgressDialog(context);
    updatedStatus = widget.status;
    writePrescriptionProvider =
        Provider.of<WritePrescriptionProvider>(context, listen: false);
    init();

    chatProvider = Provider.of<ChatProvider>(context, listen: false);
    mSymptomsController.text = widget.symtoms;
    getData();

    _tabController.addListener(() {
      printLog("Current tab index: ${_tabController.index}");
    });
    super.initState();
  }

  init() async {
    await writePrescriptionProvider.getPrescription(widget.appointmentID);
    if (writePrescriptionProvider.prescriptionModel.result != null &&
        writePrescriptionProvider.prescriptionModel.status == 200 &&
        writePrescriptionProvider.prescriptionModel.result != []) {
      pillName =
          writePrescriptionProvider.prescriptionModel.result?[0].pillName ?? "";
      medicineSize =
          writePrescriptionProvider.prescriptionModel.result?[0].howMany;
      medicineDuration =
          writePrescriptionProvider.prescriptionModel.result?[0].howLong;
      selectedTime = int.tryParse(
          writePrescriptionProvider.prescriptionModel.result?[0].whenToTake ??
              "");

      medicineNote =
          writePrescriptionProvider.prescriptionModel.result?[0].note;
      mDiagnosisController.text =
          writePrescriptionProvider.prescriptionModel.result?[0].diagnosis ??
              "";
      mReportController.text = writePrescriptionProvider
              .prescriptionModel.result?[0].laboratoryTest ??
          "";
    }
  }

  getData() async {
    currentUserId = await sharedPref.read("firebaseid");
  }

  clearAllTeztFields() {
    mSymptomsController.clear();
    mReportController.clear();
    mDiagnosisController.clear();
    pillName = null;
    medicineSize = null;
    medicineDuration = null;
    selectedTime = null;
    medicineNote = null;
    strSymptoms = null;
    strDiagnosis = null;
    mSymptomsController.text = widget.symtoms;
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  void _nextTab() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
      printLog("_tabController.index ==${_tabController.index}");
      writePrescriptionProvider.notifyListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WritePrescriptionProvider>(
      builder: (context, prescriptionProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: white,
          appBar:
              Utils.myAppBarWithBack(context, "write_prescription", true, true),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.max, // Change to max to take full height
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Card(
                        color: white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(15, 8, 15, 20),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    clipBehavior: Clip.antiAlias,
                                    child: MyNetworkImage(
                                      imageUrl: widget.patientImg.isNotEmpty
                                          ? widget.patientImg
                                          : Constant.userPlaceholder,
                                      fit: BoxFit.cover,
                                      imgHeight: 60,
                                      imgWidth: 60,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.only(left: 15),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Expanded(
                                                child: MyText(
                                                  text: widget.patientName
                                                          .isNotEmpty
                                                      ? widget.patientName
                                                      : guestPatient,
                                                  textalign: TextAlign.start,
                                                  color: colorPrimaryDark,
                                                  maxline: 1,
                                                  fontsize: Dimens.text18Size,
                                                  fontstyle: FontStyle.normal,
                                                  fontweight: FontWeight.w500,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 5, 10, 5),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: updatedStatus
                                                              .toString() ==
                                                          "1"
                                                      ? pendingStatus
                                                          .withValues(
                                                              alpha: 0.2)
                                                      : (updatedStatus
                                                                  .toString() ==
                                                              "2"
                                                          ? approvedStatus
                                                              .withValues(
                                                                  alpha: 0.2)
                                                          : (updatedStatus
                                                                      .toString() ==
                                                                  "3"
                                                              ? rejectedStatus
                                                                  .withValues(
                                                                      alpha:
                                                                          0.2)
                                                              : updatedStatus
                                                                          .toString() ==
                                                                      "4"
                                                                  ? otherColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.2)
                                                                  : (updatedStatus
                                                                              .toString() ==
                                                                          "5"
                                                                      ? approvedStatus
                                                                          .withValues(
                                                                              alpha: 0.2)
                                                                      : black))),
                                                ),
                                                child: MyText(
                                                  text: updatedStatus
                                                              .toString() ==
                                                          "1"
                                                      ? "pending"
                                                      : (updatedStatus
                                                                  .toString() ==
                                                              "2"
                                                          ? "approved"
                                                          : (updatedStatus
                                                                      .toString() ==
                                                                  "3"
                                                              ? "rejected"
                                                              : updatedStatus
                                                                          .toString() ==
                                                                      "4"
                                                                  ? "absent"
                                                                  : (updatedStatus
                                                                              .toString() ==
                                                                          "5"
                                                                      ? "completed"
                                                                      : "-"))),
                                                  multilanguage: true,
                                                  fontsize: Dimens.text13Size,
                                                  fontweight: FontWeight.w600,
                                                  textalign: TextAlign.start,
                                                  color: updatedStatus
                                                              .toString() ==
                                                          "1"
                                                      ? pendingStatus
                                                      : (updatedStatus
                                                                  .toString() ==
                                                              "2"
                                                          ? approvedStatus
                                                          : (updatedStatus
                                                                      .toString() ==
                                                                  "3"
                                                              ? rejectedStatus
                                                              : updatedStatus
                                                                          .toString() ==
                                                                      "4"
                                                                  ? otherColor
                                                                  : (updatedStatus
                                                                              .toString() ==
                                                                          "5"
                                                                      ? approvedStatus
                                                                      : black))),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          MyText(
                                            text:
                                                widget.appointmentNo.isNotEmpty
                                                    ? widget.appointmentNo
                                                    : "_",
                                            textalign: TextAlign.start,
                                            color: grayDark,
                                            fontsize: Dimens.text15Size,
                                            maxline: 1,
                                            fontstyle: FontStyle.normal,
                                            fontweight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(10, 10, 10, 10),
                                alignment: Alignment.topLeft,
                                decoration: BoxDecoration(
                                    color: lightBlue,
                                    borderRadius: BorderRadius.circular(4)),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_rounded,
                                      color: colorPrimary,
                                      size: 25,
                                    ),
                                    const SizedBox(width: 10),
                                    MyText(
                                      text: Utils.formateDate(
                                          ((widget.appointmentDate).toString())
                                              .toString()),
                                      fontsize: Dimens.text14Size,
                                      overflow: TextOverflow.ellipsis,
                                      maxline: 1,
                                      fontweight: FontWeight.w500,
                                      textalign: TextAlign.start,
                                      color: colorPrimaryDark,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: colorPrimary,
                                            size: 25,
                                          ),
                                          Flexible(
                                            child: MyText(
                                              text:
                                                  '  ${Utils.formateTime(((widget.starttime)))}-${Utils.formateTime(((widget.endTime)))}',
                                              fontsize: Dimens.text14Size,
                                              overflow: TextOverflow.ellipsis,
                                              maxline: 1,
                                              fontweight: FontWeight.w500,
                                              textalign: TextAlign.start,
                                              color: colorPrimaryDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    prescriptionTabs(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    spacing: 20,
                    children: [
                      if (_tabController.index != 2)
                        Expanded(child: diagnosisSaveButton()),
                      Expanded(child: completeButton()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget prescriptionTabs() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: MyText(
              text: "prescription",
              multilanguage: true,
              fontsize: Dimens.text17Size,
              fontstyle: FontStyle.normal,
              fontweight: FontWeight.w600,
              maxline: 1,
              color: textTitleColor,
              overflow: TextOverflow.ellipsis,
              textalign: TextAlign.center,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: TabBar(
              onTap: (int value) {
                FocusScope.of(context).requestFocus(FocusNode());
                updateSaveBtn.value = !updateSaveBtn.value;
                writePrescriptionProvider.notifyListener();
              },
              controller: _tabController,
              indicatorColor: colorPrimary,
              dividerColor: transparent,
              labelColor: colorPrimary,
              indicatorSize: TabBarIndicatorSize.tab,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                      colors: [colorAccent, colorAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.mirror)),
              tabs: <Widget>[
                Tab(
                  child: MyText(
                    text: "diagnosis",
                    multilanguage: true,
                    fontsize: Dimens.text15Size,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: MyText(
                    text: "report",
                    multilanguage: true,
                    fontsize: Dimens.text15Size,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                  ),
                ),
                Tab(
                  child: MyText(
                    text: "prescription",
                    multilanguage: true,
                    fontsize: Dimens.text15Size,
                    fontstyle: FontStyle.normal,
                    fontweight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                diagnosisTab(),
                historyTab(),
                prescriptionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget historyTab() {
    return Form(
      key: _formReportKey,
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            //===== Symptoms =====//
            MyText(
              text: "laboratory_test_list",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.bold,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: textTitleColor,
            ),
            const SizedBox(
              height: 8,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 100,
                minWidth: MediaQuery.of(context).size.width,
              ),
              child: Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                decoration: Utils.r10BGWithBorder(),
                child: MyTextFormField(
                  mHint: "Laboratory Test List",
                  mController: mReportController,
                  mObscureText: false,
                  mHintTextColor: textHintColor,
                  mTextColor: textTitleColor,
                  mkeyboardType: TextInputType.multiline,
                  mTextInputAction: TextInputAction.next,
                  mInputBorder: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(
              height: 120,
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget diagnosisTab() {
    return Form(
      key: _formKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 50,
            ),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    MyText(
                      text: "symptoms",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: Utils.r10BGWithBorder(),
                      child: MyTextFormField(
                        mHint: textHere,
                        mController: mSymptomsController,
                        mkeyboardType: TextInputType.multiline,
                        mTextInputAction: TextInputAction.next,
                        mInputBorder: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 25),
                    MyText(
                      text: "diagnosis",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      decoration: Utils.r10BGWithBorder(),
                      child: MyTextFormField(
                        mHint: textHere,
                        mController: mDiagnosisController,
                        mkeyboardType: TextInputType.multiline,
                        mTextInputAction: TextInputAction.done,
                        mInputBorder: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget prescriptionTab() {
    return Consumer<WritePrescriptionProvider>(
      builder: (context, prescriptionProvider, child) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Consumer<WritePrescriptionProvider>(
                builder: (context, prescriptionProvider, child) {
                  if (!prescriptionProvider.loading) {
                    if (prescriptionProvider.prescriptionModel.status == 200 &&
                        prescriptionProvider.prescriptionModel.result != null) {
                      if ((prescriptionProvider
                                  .prescriptionModel.result?.length ??
                              0) >
                          0) {
                        printLog("Refresh View Called");
                        return ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: prescriptionProvider
                                  .prescriptionModel.result?.length ??
                              0,
                          itemBuilder: (BuildContext context, int position) {
                            return Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 10, 20, 10),
                              child: Card(
                                color: white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                child: Container(
                                  constraints:
                                      const BoxConstraints(minHeight: 44),
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(10),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      SizedBox(
                                        height: 44,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: MyText(
                                                text: prescriptionProvider
                                                        .prescriptionModel
                                                        .result?[position]
                                                        .pillName
                                                        .toString() ??
                                                    '-',
                                                fontsize: Dimens.text17Size,
                                                fontstyle: FontStyle.normal,
                                                fontweight: FontWeight.w500,
                                                textalign: TextAlign.start,
                                                maxline: 1,
                                                overflow: TextOverflow.ellipsis,
                                                color: black,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                printLog(
                                                    'on DeleteIcon Click position :=> $position');
                                                deletePrescriptionItem(
                                                    prescriptionProvider
                                                            .prescriptionModel
                                                            .result?[position]
                                                            .id
                                                            .toString() ??
                                                        '');
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: rejectedStatus,
                                                        width: 0.5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: rejectedStatus,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(height: 0.5, color: grayDark),
                                      const SizedBox(height: 12),
                                      MyText(
                                        text: "when_to_take",
                                        multilanguage: true,
                                        fontsize: Dimens.text14Size,
                                        fontweight: FontWeight.w400,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: otherLightColor,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        text: prescriptionProvider
                                                    .prescriptionModel
                                                    .result?[position]
                                                    .whenToTake
                                                    .toString() ==
                                                "1"
                                            ? "before_food"
                                            : prescriptionProvider
                                                        .prescriptionModel
                                                        .result?[position]
                                                        .whenToTake
                                                        .toString() ==
                                                    "2"
                                                ? "after_food"
                                                : "-",
                                                multilanguage: true,
                                        fontsize: Dimens.text15Size,
                                        fontweight: FontWeight.normal,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: textTitleColor,
                                      ),
                                      const SizedBox(height: 15),
                                      MyText(
                                        text: "duration",
                                        multilanguage: true,
                                        fontsize: Dimens.text14Size,
                                        fontweight: FontWeight.w400,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: otherLightColor,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      MyText(
                                        text:
                                            "${prescriptionProvider.prescriptionModel.result?[position].howLong.toString() ?? "0"} Days",
                                        fontsize: Dimens.text15Size,
                                        fontweight: FontWeight.normal,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: textTitleColor,
                                      ),
                                      const SizedBox(height: 15),
                                      MyText(
                                        text: "additional_note",
                                        multilanguage: true,
                                        fontsize: Dimens.text14Size,
                                        fontweight: FontWeight.w400,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: otherLightColor,
                                      ),
                                      const SizedBox(height: 4),
                                      MyText(
                                        text: prescriptionProvider
                                                .prescriptionModel
                                                .result?[position]
                                                .note
                                                .toString() ??
                                            '-',
                                        fontsize: Dimens.text15Size,
                                        fontweight: FontWeight.normal,
                                        fontstyle: FontStyle.normal,
                                        textalign: TextAlign.start,
                                        color: textTitleColor,
                                      ),
                                      const SizedBox(height: 15),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      } else {
                        return const NoData(text: '');
                      }
                    } else {
                      return const NoData(text: '');
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(height: 20),
              addMedicineButton(),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget addMedicineButton() {
    return InkWell(
      focusColor: colorPrimary,
      onTap: () async {
        printLog("Clicked on Add Medicine Button!");
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                AddMedicine(widget.appointmentID /* other params */
                    ),
          ),
        );

        // Check if result is not null
        if (result != null) {
          // setState(() {
          pillName = result['pillName'];
          medicineSize = result['medicineSize'];
          medicineDuration = result['medicineDuration'];
          selectedTime = result['selectedTime'];
          medicineNote = result['medicineNote'];
          writePrescriptionProvider.notifyListener();

          // });

          printLog('Pill Name:::: $pillName');
          printLog('Medicine Size:::: $medicineSize');
          printLog('Medicine Duration:::: $medicineDuration');
          printLog('Selected Time:::: $selectedTime');
          printLog('Medicine Note:::: $medicineNote');

          if (_tabController.index == 2) {
            strSymptoms = mSymptomsController.text.toString().trim();
            strDiagnosis = mDiagnosisController.text.toString().trim();

            printLog("strSymptoms ==> $strSymptoms");
            printLog("strDiagnosis ==> $strDiagnosis");

            if ((strSymptoms ?? "").isEmpty) {
              Utils.showToast(enterSymptoms);
              return;
            }
            if ((pillName ?? "").isEmpty) {
              Utils.showToast(enterpill);
              return;
            }

            if ((strDiagnosis ?? "").isEmpty) {
              Utils.showToast(enterDiagnosis);
              return;
            }

            // Call the API function
            addUpdateAppointment(
                strSymptoms!,
                strDiagnosis!,
                mReportController.text.toString(),
                "diagnosis",
                medicineNote ?? "");
          }
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: Constant.buttonHeight,
        decoration: Utils.primaryDarkButton(),
        alignment: Alignment.center,
        child: MyText(
          text: "add_medicine",
          multilanguage: true,
          color: white,
          textalign: TextAlign.center,
          fontsize: Dimens.text16Size,
          fontweight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget diagnosisSaveButton() {
    return InkWell(
      focusColor: colorPrimary,
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        // Check which tab is currently active

        // Move to the next tab
        _nextTab();
      },
      child: ValueListenableBuilder(
        valueListenable: updateSaveBtn,
        builder: (context, value, child) => Container(
          width: MediaQuery.of(context).size.width * 0.45,
          height: Constant.buttonHeight,
          decoration: Utils.primaryDarkButton(),
          alignment: Alignment.center,
          child: MyText(
            text: _tabController.index == 2 ? "save" : "next",
            multilanguage: true,
            color: white,
            textalign: TextAlign.center,
            fontsize: Dimens.text16Size,
            fontweight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget completeButton() {
    return InkWell(
      focusColor: colorPrimary,
      onTap: () async {
        if (updatedStatus == "5") {
          Utils.showToast("Appointment Already Completed");
        } else {
          updatedStatus = "5";
          Utils.showProgress(context, prDialog);
          await chatProvider.updateAppointmentStatusForAnyOrder(
              collectionPath: FirestoreConstants.pathMessageCollection,
              myFireId: currentUserId ?? "",
              toFireId: widget.doctorFirebaseID,
              appointmentStatus: "5");
          await writePrescriptionProvider.updateAppoinmentStatus(
              widget.appointmentID, "5");
          prDialog?.hide();
          if (!mounted) return;
          Navigator.pop(context);
        }
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: Constant.buttonHeight,
        decoration: Utils.primaryDarkButton(),
        alignment: Alignment.center,
        child: MyText(
          text: updatedStatus == "5"
              ? "completed_appointment"
              : "complete_appointment",
          multilanguage: true,
          color: white,
          maxline: 1,
          textalign: TextAlign.center,
          fontsize: Dimens.text14Size,
          fontweight: FontWeight.w600,
        ),
      ),
    );
  }

  void addUpdateAppointment(String symptoms, String diagnosis,
      String laboratoryTest, String type, String medicineNote) async {
    printLog('appointmentID ==>> ${widget.appointmentID}');
    printLog('symptoms ==>> $symptoms');
    printLog('diagnosis ==>> $diagnosis');

    // update_appoinment API call
    Utils.showProgress(context, prDialog);
    final writePrescriptionProvider =
        Provider.of<WritePrescriptionProvider>(context, listen: false);
    await writePrescriptionProvider.addPrescription(
        widget.appointmentID,
        symptoms,
        diagnosis,
        laboratoryTest,
        pillName,
        medicineSize,
        medicineDuration,
        selectedTime,
        medicineNote);

    printLog(
        'addUpdateAppointment loading ==>> ${writePrescriptionProvider.loading}');

    if (!writePrescriptionProvider.loading) {
      prDialog?.hide();
      printLog(
          'addUpdateAppointment status ==>> ${writePrescriptionProvider.successModel.status}');
      printLog(
          'addUpdateAppointment message ==>> ${writePrescriptionProvider.successModel.message}');
      if (writePrescriptionProvider.addPrescriptionModel.status == 200) {
        if (!mounted) return;
        Utils.showToast(
            writePrescriptionProvider.addPrescriptionModel.message ?? "");
        clearTextFormField();
      } else {
        if (!mounted) return;
        Utils.showToast(
            writePrescriptionProvider.addPrescriptionModel.message ?? "");
      }
    }
  }

  void clearTextFormField() {
    strSymptoms = "";
    strDiagnosis = "";
    pillName = "";
    medicineSize = 0;
    medicineDuration = 0;
    selectedTime = 0;

    medicineNote = "";
  }

  void deletePrescriptionItem(String prescriptionId) async {
    printLog('prescriptionId ==>> $prescriptionId');
    final writePrescriptionProvider =
        Provider.of<WritePrescriptionProvider>(context, listen: false);

    // delete_prescription API call
    Utils.showProgress(context, prDialog);
    await writePrescriptionProvider.deletePrescriptionNow(prescriptionId);
    printLog(
        'deletePrescriptionItem loading ==>> ${writePrescriptionProvider.loading}');

    if (!writePrescriptionProvider.loading) {
      prDialog?.hide();
      printLog(
          'deletePrescriptionItem status ==>> ${writePrescriptionProvider.successModel.status}');
      if (writePrescriptionProvider.successModel.status == 200) {
        clearTextFormField();

        // getPrescription API call
        await writePrescriptionProvider.getPrescription(widget.appointmentID);

        if (!mounted) return;
        Utils.showToast(writePrescriptionProvider.successModel.message ?? "");
      } else {
        if (!mounted) return;
        Utils.showToast(writePrescriptionProvider.successModel.message ?? "");
      }
    }
  }

  Widget profileTab() {
    return const Column(
      children: [],
    );
  }
}
