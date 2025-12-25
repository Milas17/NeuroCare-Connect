import 'package:yourappname/model/getmedicinelistmodel.dart';
import 'package:yourappname/provider/writeprescriptionprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/mytextformfield.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/dashicons.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class AddMedicine extends StatefulWidget {
  final String appointmentID;
  const AddMedicine(this.appointmentID, {super.key});

  @override
  State<AddMedicine> createState() => _AddMedicineState();
}

class _AddMedicineState extends State<AddMedicine> {
  ProgressDialog? prDialog;
  final _formKey = GlobalKey<FormState>();
  final mPillNameController = TextEditingController();
  final mHowManyController = TextEditingController();
  final mDaysController = TextEditingController();
  final mNoteController = TextEditingController();
  String? dropdownValue;
  int? selectedTime;
  TextEditingController searchController = TextEditingController();
  Result? selectedMedicine;
  List<Result> filteredMedicines = [];
  List<Result> allMedicines = [];
  late WritePrescriptionProvider medicineaddprovider;
  bool isDropdownVisible = false;

  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    medicineaddprovider =
        Provider.of<WritePrescriptionProvider>(context, listen: false);

    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await medicineaddprovider.getMedicinesList();

      if (!mounted) return;
      final medicines =
          context.read<WritePrescriptionProvider>().getMedicineListModel.result;

      if (mounted) {
        setState(() {
          allMedicines = medicines ?? [];
          filteredMedicines = allMedicines;
        });
      }
    });

    _focusNode.addListener(() => setState(() {}));
    mPillNameController.addListener(() {
      filterMedicines(mPillNameController.text);
    });

    selectedTime = 0;
    dropdownValue = "Tablet";
    prDialog = ProgressDialog(context);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    mPillNameController.dispose();
    mHowManyController.dispose();
    mDaysController.dispose();
    mNoteController.dispose();
    super.dispose();
  }

  void filterMedicines(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMedicines = allMedicines;
      } else {
        filteredMedicines = allMedicines
            .where((medicine) =>
                medicine.pillName
                    ?.toLowerCase()
                    .contains(query.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "add_medicine", true, true),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: white,
              margin: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    /* Pill Name */
                    MyText(
                      text: "pillname",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 4),
                    Consumer<WritePrescriptionProvider>(
                      builder: (context, medicineAddProvider, child) {
                        final hasSuggestions = !medicineAddProvider.loading &&
                            medicineAddProvider.getMedicineListModel.status ==
                                200 &&
                            (filteredMedicines.isNotEmpty);

                        final showSuggestions = _focusNode.hasFocus &&
                            hasSuggestions &&
                            mPillNameController.text.isEmpty;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Text Field
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              decoration: Utils.textFieldBGWithBorderMedicine(),
                              child: MyTextFormField(
                                mHint: "Add Medicine",
                                mMaxLine: 1,
                                mController: mPillNameController,
                                mObscureText: false,
                                mHintTextColor: textHintColor,
                                mTextColor: textTitleColor,
                                mkeyboardType: TextInputType.text,
                                mTextInputAction: TextInputAction.next,
                                mInputBorder: InputBorder.none,
                                mFocusNode: _focusNode, // persistent focus node
                                onChanged: (value) =>
                                    filterMedicines(value), // 👈 live filtering
                              ),
                            ),

                            // 🔹 Suggestions (only if focused & text is empty)
                            if (showSuggestions)
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: lightGrey,
                                      blurRadius: 5,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                constraints:
                                    const BoxConstraints(maxHeight: 90),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: filteredMedicines.length,
                                  itemBuilder: (context, index) {
                                    final medicine = filteredMedicines[index];
                                    return InkWell(
                                      onTap: () {
                                        mPillNameController.text =
                                            medicine.pillName ?? "";
                                        _focusNode
                                            .unfocus(); // hide suggestions
                                        printLog(
                                            "Selected Medicine: ${medicine.pillName}");
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        color: transparent,
                                        padding: const EdgeInsets.all(8),
                                        child: MyText(
                                          text: medicine.pillName ?? "No name",
                                          fontsize: 15,
                                          multilanguage: false,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    /* How Many */
                    MyText(
                      text: "how_many",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: Constant.textFieldHeight,
                            padding: const EdgeInsets.only(
                                left: 15, right: 12, top: 5),
                            decoration: Utils.textFieldBGWithBorderMedicine(),
                            child: MyTextFormField(
                              mHint: count,
                              mController: mHowManyController,
                              mInputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textHintColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.number,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Container(
                            height: Constant.textFieldHeight,
                            padding: const EdgeInsets.only(
                                left: 15, right: 12, top: 5),
                            decoration: Utils.textFieldBGWithBorderMedicine(),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButtonFormField2(
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                                value: dropdownValue,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                hint: MyText(
                                  text: "medicine_type",
                                  multilanguage: true,
                                  fontsize: Dimens.text14Size,
                                  fontweight: FontWeight.normal,
                                  fontstyle: FontStyle.normal,
                                  textalign: TextAlign.start,
                                  color: textHintColor,
                                ),
                                items: <String>[
                                  'Tablet',
                                  'Syrup',
                                  'Tube',
                                  'Capsules'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: MyText(
                                      text: value,
                                      fontsize: Dimens.text14Size,
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
                      ],
                    ),
                    const SizedBox(height: 14),

                    /* How Long */
                    MyText(
                      text: "how_long",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: Constant.textFieldHeight,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      decoration: Utils.textFieldBGWithBorderMedicine(),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: MyTextFormField(
                              mHint: enterDays,
                              mController: mDaysController,
                              mInputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textHintColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.number,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    /* When To Take */
                    MyText(
                      text: "when_to_take",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedTime = 1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: selectedTime == 1
                                  ? Utils.r4DarkBGWithBorder()
                                  : Utils.r4BGWithBorder(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: selectedTime == 1
                                                  ? white
                                                  : colorPrimary,
                                              width: 1)),
                                      child: Iconify(
                                        Dashicons.food,
                                        size: 20,
                                        color: selectedTime == 1
                                            ? white
                                            : colorPrimary,
                                      )),
                                  Expanded(
                                    child: MyText(
                                      text: "before_food",
                                      multilanguage: true,
                                      fontsize: Dimens.text15Size,
                                      fontweight: FontWeight.w500,
                                      fontstyle: FontStyle.normal,
                                      textalign: TextAlign.center,
                                      color: selectedTime == 1
                                          ? white
                                          : colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                selectedTime = 2;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: selectedTime == 2
                                  ? Utils.r4DarkBGWithBorder()
                                  : Utils.r4BGWithBorder(),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Container(
                                      height: 30,
                                      width: 30,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border: Border.all(
                                              color: selectedTime == 2
                                                  ? white
                                                  : colorPrimary,
                                              width: 1)),
                                      child: Iconify(
                                        Dashicons.food,
                                        size: 20,
                                        color: selectedTime == 2
                                            ? white
                                            : colorPrimary,
                                      )),
                                  Expanded(
                                    child: MyText(
                                      text: "after_food",
                                      multilanguage: true,
                                      fontsize: Dimens.text15Size,
                                      fontweight: FontWeight.w500,
                                      fontstyle: FontStyle.normal,
                                      textalign: TextAlign.center,
                                      color: selectedTime == 2
                                          ? white
                                          : colorPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    /* Additional Note */
                    MyText(
                      text: "additional_note",
                      multilanguage: true,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.bold,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: textTitleColor,
                    ),
                    const SizedBox(height: 4),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 140,
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(left: 15, right: 15),
                        decoration: Utils.textFieldBGWithBorderMedicine(),
                        child: MyTextFormField(
                          mHint: textHere,
                          mController: mNoteController,
                          mObscureText: false,
                          mHintTextColor: textHintColor,
                          mTextColor: textTitleColor,
                          mkeyboardType: TextInputType.multiline,
                          mTextInputAction: TextInputAction.done,
                          mInputBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(4),
                        onTap: () {
                          checkAndAddPrescription();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.45,
                          height: Constant.buttonHeight,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorPrimaryDark,
                            borderRadius: BorderRadius.circular(4),
                            shape: BoxShape.rectangle,
                          ),
                          child: MyText(
                            text: "save",
                            multilanguage: true,
                            fontsize: Dimens.text16Size,
                            fontstyle: FontStyle.normal,
                            fontweight: FontWeight.normal,
                            maxline: 1,
                            textalign: TextAlign.center,
                            color: white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkAndAddPrescription() async {
    int medicineSize = int.parse(mHowManyController.text.toString().trim());
    int medicineDuration = int.parse(mDaysController.text.toString().trim());
    String medicineNote = mNoteController.text.toString().trim();
    Navigator.of(context).pop({
      'pillName': mPillNameController.text.toString(),
      'medicineSize': medicineSize,
      'medicineDuration': medicineDuration,
      'selectedTime': selectedTime ?? 0,
      'medicineNote': medicineNote,
    });

    clearTextFormField();
  }

  void clearTextFormField() {
    selectedTime = 0;
    mPillNameController.clear();
    mHowManyController.clear();
    mDaysController.clear();
    mNoteController.clear();
  }
}
