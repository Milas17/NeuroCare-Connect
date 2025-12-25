import 'dart:io';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/customtextformfield.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:progress_stepper/progress_stepper.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FullEditProfile extends StatefulWidget {
  const FullEditProfile({super.key});

  @override
  State<FullEditProfile> createState() => _FullEditProfileState();
}

class _FullEditProfileState extends State<FullEditProfile> {
  late ProgressDialog prDialog;
  Speciality specialityValue = Speciality();
  String firebasedid = "";
  SharedPre sharePref = SharedPre();
  final _formKey = GlobalKey<FormState>();
  final _kycFormKey = GlobalKey<FormState>();
  late EditProfileProvider editProfileProvider;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final mFirstNameController = TextEditingController();
  final mEmailController = TextEditingController();
  final mLocationController = TextEditingController();
  final mPractisingTenureController = TextEditingController();
  final mBirthdateController = TextEditingController();
  final mPasswordController = TextEditingController();
  final mMobileController = TextEditingController();
  dynamic fullName, lastName, userEmail, password, mobile, deviceToken;
  late GeneralProvider generalProvider;
  String? strDeviceToken, strDeviceType;
  String? latitude, longitude, area, city, state, country;
  final ImagePicker imagePicker = ImagePicker();
  int currentStep = 1;

  //Profile Details
  var mAddressController = TextEditingController();
  var mAboutUsController = TextEditingController();
  var mServiceController = TextEditingController();
  var mHealthCareController = TextEditingController();
  var mInstaController = TextEditingController();
  var mFacebookController = TextEditingController();
  var mTwitterController = TextEditingController();
  String countryCode = "+91";
  String countryName = "India";
  String location = "Search Location",
      strLongitude = "",
      strLatitude = "",
      strWorkingTime = "",
      strAddress = "",
      currentUserFId = "";
  // File? bankIDfile;

  //KYC Stepper
  final mLICNameController = TextEditingController();
  final mLICNumberController = TextEditingController();
  final mLICAddressController = TextEditingController();
  final mPostalCodeController = TextEditingController();
  final mInstitueNameController = TextEditingController();
  final mInstitueAddressController = TextEditingController();
  final mDegreeController = TextEditingController();
  final mBatchYearController = TextEditingController();
  final mClinicNameController = TextEditingController();
  final mYouRoleController = TextEditingController();
  final mClinicAddressController = TextEditingController();
  final mbankNameController = TextEditingController();
  final mbankcodeController = TextEditingController();
  final mbankAddressController = TextEditingController();
  final mifscnoController = TextEditingController();
  final maccountNoController = TextEditingController();

  Future<void> updatedata() async {
    await editProfileProvider.getDoctorDetails();
    await FirebaseFirestore.instance
        .collection(FirestoreConstants.pathUserCollection)
        .doc(auth.currentUser?.uid)
        .update({
      FirestoreConstants.bioData:
          editProfileProvider.doctorProfileModel.result?[0].bio,
      FirestoreConstants.chattingWith: "",
      FirestoreConstants.createdAt:
          DateTime.now().millisecondsSinceEpoch.toString(),
      FirestoreConstants.email:
          editProfileProvider.doctorProfileModel.result?[0].email,
      FirestoreConstants.name:
          editProfileProvider.doctorProfileModel.result?[0].fullName ?? "",
      FirestoreConstants.profileurl:
          editProfileProvider.doctorProfileModel.result?[0].image,
      FirestoreConstants.username: "",
      FirestoreConstants.mobileNumber:
          editProfileProvider.doctorProfileModel.result?[0].mobileNumber,
    });
  }

  @override
  void initState() {
    // _passwordVisible = false;
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    editProfileProvider.getSpecialities();
    editProfileProvider.getDoctorDetails();
    prDialog = ProgressDialog(context);
    _getDeviceToken();
    super.initState();
  }

  String getFileName(String filePath) {
    return filePath
        .split('/')
        .last; // Works for Unix-based file paths (Android/iOS)
  }

  _getDeviceToken() async {
    strDeviceToken = OneSignal.User.pushSubscription.id;
    if (Platform.isAndroid) {
      strDeviceType = "1";
    } else {
      strDeviceType = "2";
    }
    printLog("===>strDeviceToken $strDeviceToken");
    printLog("===>deviceType $strDeviceType");
  }

  @override
  void dispose() {
    mFirstNameController.dispose();
    mEmailController.dispose();
    mPasswordController.dispose();
    mMobileController.dispose();
    editProfileProvider.allDataclearProvider();
    super.dispose();
  }

  Future<void> pickLicFrontImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allow custom file types
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );
    if (!mounted) return;
    if (result != null) {
      // setState(() {
      //   licFrontFile = File(result.files.single.path!);
      // });
      editProfileProvider
          .setLICFrontImage(File(result.files.single.path ?? ""));

      Utils.showSnackbar(context, "documentselected", true);
    } else {
      Utils.showSnackbar(context, "nofileselected", true);
    }
  }

  Future<void> pickBankId() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allow custom file types
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );
    if (!mounted) return;
    if (result != null) {
      // setState(() {
      //   bankIDfile = File(result.files.single.path!);
      // });
      editProfileProvider.setBankIDImage(File(result.files.single.path ?? ""));

      Utils.showSnackbar(context, "documentselected", true);
    } else {
      Utils.showSnackbar(context, "nofileselected", true);
    }
  }

  Future<void> pickLicBackImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allow custom file types
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );
    if (!mounted) return;
    if (result != null) {
      // setState(() {
      //   licBackFile = File(result.files.single.path!);
      // });
      editProfileProvider.setLICBackImage(File(result.files.single.path ?? ""));

      Utils.showSnackbar(context, "documentselected", true);
    } else {
      Utils.showSnackbar(context, "nofileselected", true);
    }
  }

  Future<void> pickDegreeDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allow custom file types
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );
    if (!mounted) return;
    if (result != null) {
      // setState(() {
      //   degreeDocuments = File(result.files.single.path!);
      // });
      editProfileProvider
          .setDegreeDocImage(File(result.files.single.path ?? ""));

      Utils.showSnackbar(context, "documentselected", true);
    } else {
            Utils.showSnackbar(context, "nofileselected", true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "edit_profile", true, false),
      body: Consumer2<EditProfileProvider, GeneralProvider>(
        builder: (context, editprofileprovider, generalProvider, child) {
          if (editprofileprovider.loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            mFirstNameController.text = mFirstNameController.text == ""
                ? (editProfileProvider.doctorProfileModel.result?[0].fullName ??
                    "")
                : mFirstNameController.text;
            mEmailController.text =
                editProfileProvider.doctorProfileModel.result?[0].email ?? "";
            mMobileController.text = editProfileProvider
                    .doctorProfileModel.result?[0].mobileNumber ??
                "";
            mLocationController.text =
                editProfileProvider.doctorProfileModel.result?[0].address ?? "";

            return Column(
              children: [
                Expanded(
                    child: currentStep == 1
                        ? personalInfoSteps()
                        : currentStep == 2
                            ? kycInfoSteps()
                            : uploadImageSteps()),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              focusColor: colorPrimary,
                              onTap: () async {
                                if (currentStep == 1) {
                                  if (mFirstNameController.text.isNotEmpty &&
                                      mEmailController.text.isNotEmpty &&
                                      mLocationController.text.isNotEmpty &&
                                      mMobileController.text.isNotEmpty &&
                                      mBirthdateController.text.isNotEmpty &&
                                      mPractisingTenureController
                                          .text.isNotEmpty) {
                                    validateAndUpdate();
                                  } else {
                                    Utils.showSnackbar(
                                        context,
                                        "pleasefillallfields",
                                        true);
                                  }
                                } else if (currentStep == 2) {
                                  if (mLICNameController.text.isNotEmpty &&
                                      mLICNumberController.text.isNotEmpty &&
                                      mLICAddressController.text.isNotEmpty &&
                                      mPostalCodeController.text.isNotEmpty &&
                                      mInstitueNameController.text.isNotEmpty &&
                                      mInstitueAddressController
                                          .text.isNotEmpty &&
                                      mDegreeController.text.isNotEmpty &&
                                      mClinicNameController.text.isNotEmpty &&
                                      mBatchYearController.text.isNotEmpty &&
                                      mYouRoleController.text.isNotEmpty &&
                                      mClinicAddressController
                                          .text.isNotEmpty &&
                                      editProfileProvider.licFrontFile !=
                                          null &&
                                      editProfileProvider.licBackFile != null &&
                                      editProfileProvider.degreeDocuments !=
                                          null) {
                                    await validateKYCData();
                                  } else {
                                    if (!mounted) return;
                                    Utils.showSnackbar(
                                        context,
                                        "pleasefillallfields",
                                        true);
                                  }
                                } else if (currentStep == 3) {
                                  await sharePref.save("isEdit", "1");
                                  await clearTextFormField();
                                  if (!context.mounted) return;
                                  await Navigator.pushAndRemoveUntil<void>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return const BottomBar();
                                      },
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                width: MediaQuery.of(context).size.width * 0.85,
                                height: Constant.buttonHeight,
                                decoration: Utils.primaryDarkButton(),
                                alignment: Alignment.center,
                                child: MyText(
                                  text: "next",
                                  multilanguage: true,
                                  color: white,
                                  textalign: TextAlign.center,
                                  fontsize: Dimens.text16Size,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ProgressStepper(
                          bluntTail: true,
                          width: MediaQuery.of(context).size.width * 0.85,
                          currentStep: currentStep,
                          stepCount: 3,
                          progressColor: colorPrimary,
                          // stepColor: Colors.grey.shade300,
                          // lineColor: Colors.blue,
                          color: gray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget personalInfoSteps() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyText(
                text: "edit_profile",
                multilanguage: true,
                fontsize: Dimens.text24Size,
                fontweight: FontWeight.w600,
                color: colorPrimaryDark,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                controller: mFirstNameController,
                labelText: fullNameReq,
                keyboardType: TextInputType.text,
                readOnly: false,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly:
                    editProfileProvider.doctorProfileModel.result?[0].type ==
                                2 ||
                            editProfileProvider
                                    .doctorProfileModel.result?[0].type ==
                                3
                        ? true
                        : false,
                controller: mEmailController,
                labelText: emailAddressReq,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 55,
                child: IntlPhoneField(
                  disableLengthCheck: true,
                  textAlignVertical: TextAlignVertical.center,
                  autovalidateMode: AutovalidateMode.disabled,
                  controller: mMobileController,
                  style: Utils.googleFontStyle(
                      1, 16, FontStyle.normal, black, FontWeight.w500),
                  showCountryFlag: false,
                  showDropdownIcon: false,
                  initialCountryCode: "IN",
                  dropdownTextStyle: Utils.googleFontStyle(
                      1, 16, FontStyle.normal, black, FontWeight.w500),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: white,
                    border: InputBorder.none,
                    labelStyle: Utils.googleFontStyle(
                      1,
                      14,
                      FontStyle.normal,
                      black,
                      FontWeight.w500,
                    ),
                    hintText: Locales.string(context, "enteryourmobilenumber"),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: grayDark, width: 1),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      borderSide: BorderSide(color: grayDark, width: 1),
                    ),
                  ),
                  onChanged: (phone) {
                    printLog('phone===> ${phone.completeNumber}');
                    printLog('number===> ${mMobileController.text}');
                  },
                  onCountryChanged: (country) {
                    countryCode = "+${country.dialCode.toString()}";
                    countryName = country.name.toString();
                    printLog('countrycode===> $countryCode');
                  },
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onTap: () {
                  openDatePicker();
                },
                controller: mBirthdateController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                obscureText: false,
                maxLines: 1,
                readOnly: true,
                decoration: InputDecoration(
                  suffix: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.calendar_month,
                      size: 25,
                      color: gray,
                    ),
                  ),
                  labelText: "Birth Date",
                  contentPadding: const EdgeInsets.only(left: 10),
                  labelStyle: GoogleFonts.roboto(
                    fontSize: 16,
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: black, width: 0.5)),
                ),
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 18,
                    color: black,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      readOnly: false,
                      controller: mLocationController,
                      labelText: address,
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      getCurrentLocation();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: colorPrimaryDark),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: MyText(
                        text: "current_location",
                        multilanguage: true,
                        fontsize: Dimens.text13Size,
                        fontweight: FontWeight.w400,
                        color: white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mPractisingTenureController,
                labelText: practisingTenure,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> validateKYCData() async {
    final isValidForm = _kycFormKey.currentState!.validate();
    printLog("isValidForm => $isValidForm");
    // Validate returns true if the form is valid, or false otherwise.
    if (isValidForm) {
      if (mLICNameController.text.isEmpty) {
        Utils.showToast(licName);
      } else if (mLICNumberController.text.isEmpty) {
        Utils.showToast(addLicNumber);
      } else if (mLICAddressController.text.isEmpty) {
        Utils.showToast(licAddress);
      } else if (mPostalCodeController.text.isEmpty) {
        Utils.showToast(addPostalCode);
      } else if (mInstitueNameController.text.isEmpty) {
        Utils.showToast(addInstitueName);
      } else if (mDegreeController.text.isEmpty) {
        Utils.showToast(addInstitueAddress);
      } else if (mInstitueAddressController.text.isEmpty) {
        Utils.showToast(addInstitueAddress);
      } else if (mClinicNameController.text.isEmpty) {
        Utils.showToast(addClinicName);
      } else if (mBatchYearController.text.isEmpty) {
        Utils.showToast("$addBatchYear ");
      } else if (mYouRoleController.text.isEmpty) {
        Utils.showToast("$addRole ");
      } else if (mClinicAddressController.text.isEmpty) {
        Utils.showToast(addclinicAddress);
      } else if (mbankNameController.text.isEmpty) {
        Utils.showToast(addBankName);
      } else if (mbankcodeController.text.isEmpty) {
        Utils.showToast(addBankCode);
      } else if (mbankAddressController.text.isEmpty) {
        Utils.showToast(addBankAddress);
      } else if (mifscnoController.text.isEmpty) {
        Utils.showToast(addifscNo);
      } else if (maccountNoController.text.isEmpty) {
        Utils.showToast(addbankAccountNumber);
      } else {
        // doctor_registration API call
        if (!mounted) return;
        Utils.showProgress(context, prDialog);
        await generalProvider.doctorKYC(
            mLICNameController.text.toString(),
            mLICNumberController.text.toString(),
            mLICAddressController.text.toString(),
            mPostalCodeController.text.toString(),
            mYouRoleController.text.toString(),
            mDegreeController.text.toString(),
            mBatchYearController.text.toString(),
            mClinicNameController.text.toString(),
            editProfileProvider.licFrontFile,
            editProfileProvider.licBackFile,
            mInstitueNameController.text.toString(),
            mInstitueAddressController.text.toString(),
            mClinicAddressController.text.toString(),
            mBirthdateController.text.toString(),
            mbankNameController.text.toString(),
            mbankcodeController.text.toString(),
            mbankAddressController.text.toString(),
            mifscnoController.text.toString(),
            maccountNoController.text.toString(),
            editProfileProvider.bankIDfile,
            editProfileProvider.degreeDocuments,
            Constant.userID);
        prDialog.hide();
        if (generalProvider.kycSuccessModel.status == 200 &&
            generalProvider.kycSuccessModel.result != null) {
          Utils.showToast(generalProvider.kycSuccessModel.message.toString());
          currentStep++;
          generalProvider.notifyListener();
        } else {
          Utils.showToast(generalProvider.kycSuccessModel.message.toString());
        }
      }
    }
  }

  Widget uploadImageSteps() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: MyText(
              text: "upload_picture",
              multilanguage: true,
              fontsize: Dimens.text24Size,
              fontweight: FontWeight.w600,
              color: colorPrimaryDark,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: DottedBorder(
              options: const RoundedRectDottedBorderOptions(
                radius: Radius.circular(10),
                color: colorPrimaryDark,
                dashPattern: [2, 2],
                strokeWidth: 2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      imagePickDialog();
                    },
                    child: Container(
                      margin: const EdgeInsets.all(5),
                      height: 350,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: colorAccent,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: editProfileProvider.pickedImageFile != null
                          ? Image.file(
                              editProfileProvider.pickedImageFile!,
                              fit: BoxFit.cover,
                              height: 70,
                              width: 70,
                            )
                          : const Icon(
                              Icons.camera_alt_outlined,
                              size: 50,
                              color: grayDark,
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: MyText(
                      text: "upload_profile_picture",
                      multilanguage: true,
                      fontsize: Dimens.text16Size,
                      fontweight: FontWeight.w500,
                      color: textTitleColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: MyText(
                      text: "JPG/PNG/PDF Files",
                      multilanguage: false,
                      fontsize: Dimens.text14Size,
                      fontweight: FontWeight.w500,
                      color: grayDark,
                    ),
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget editProfileSHimmer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: <Widget>[
              Row(
                children: [
                  const CustomWidget.circular(
                    height: 65,
                    width: 65,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                      child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    decoration: BoxDecoration(
                        color: white,
                        border: Border.all(color: colorPrimaryDark, width: 1),
                        borderRadius: BorderRadius.circular(10)),
                    child: CustomWidget.roundcorner(
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      height: 20,
                      width: 65,
                    ),
                  ))
                ],
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: <Widget>[
                    CustomWidget.roundcorner(
                      height: 50,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      width: MediaQuery.of(context).size.width,
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                    CustomWidget.roundcorner(
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Future<void> getCurrentLocation() async {
    try {
      loc.Location location = loc.Location();

      // Check if service is enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      // Check permissions
      loc.PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          throw Exception('Location permissions are denied.');
        }
      }

      // Get current location
      loc.LocationData locData = await location.getLocation();

      // Convert latitude/longitude to address
      List<Placemark> placemarks = await placemarkFromCoordinates(
        locData.latitude!,
        locData.longitude!,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        String address = [
          place.name,
          place.subLocality,
          place.locality,
          place.administrativeArea,
          place.country,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        mLocationController.clear();
        mLocationController.text = address;

        area = place.subLocality;
        city = place.locality;
        latitude = locData.latitude.toString();
        longitude = locData.longitude.toString();
        state = place.administrativeArea;
        country = place.country;
      } else {
        throw Exception('Failed to get address from coordinates.');
      }
    } catch (e) {
      if (!mounted) return;

      Utils.showSnackbar(context, e.toString(), false);
    }
    // try {
    //   // Check if location service is enabled
    //   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    //   if (!serviceEnabled) {
    //     // Open location settings if disabled
    //     await Geolocator.openLocationSettings();
    //     return;
    //   }

    //   // Check location permission
    //   LocationPermission permission = await Geolocator.checkPermission();
    //   if (permission == LocationPermission.denied) {
    //     permission = await Geolocator.requestPermission();
    //     if (permission == LocationPermission.denied) {
    //       throw Exception('Location permissions are denied.');
    //     }
    //   }

    //   if (permission == LocationPermission.deniedForever) {
    //     throw Exception('Location permissions are permanently denied.');
    //   }

    //   // Get current location
    //   Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high,
    //   );

    //   // Convert latitude and longitude to address
    //   List<Placemark> placemarks = await placemarkFromCoordinates(
    //     position.latitude,
    //     position.longitude,
    //   );

    //   if (placemarks.isNotEmpty) {
    //     Placemark place = placemarks.first;

    //     // Format the address
    //     String address = [
    //       place.name, // Society/Flat name
    //       // place.subThoroughfare, // Flat/Building number
    //       // place.thoroughfare, // Street
    //       place.subLocality, // Area
    //       place.locality, // City
    //       place.administrativeArea, // State
    //       place.country, // Country
    //       place.postalCode // Pincode
    //     ].where((element) => element != null && element.isNotEmpty).join(', ');
    //     mLocationController.clear();
    //     printLog("address== $address");
    //     // Set the formatted address in the text controller
    //     mLocationController.text = address;
    //     area = place.subLocality;
    //     city = place.locality;
    //     latitude = position.latitude.toString();
    //     longitude = position.longitude.toString();
    //     state = place.administrativeArea;
    //     country = place.country;
    //   } else {
    //     throw Exception('Failed to get address from coordinates.');
    //   }
    // } catch (e) {
    //   if (!mounted) return;
    //   // Handle errors
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.toString())),
    //   );
    // }
  }

  void validateAndUpdate() async {
    String fullName = mFirstNameController.text.toString().trim();
    String email = mEmailController.text.toString().trim();
    String password = mPasswordController.text.toString();
    String mobile = mMobileController.text.toString().trim();

    if (mFirstNameController.text.isEmpty) {
      Utils.showToast(enterFirstname);
    } else if (mEmailController.text.isEmpty) {
      Utils.showToast(enterEmail);
    } else if (!EmailValidator.validate(mEmailController.text)) {
      Utils.showToast(enterValidEmail);
    } else if (mMobileController.text.isEmpty) {
      Utils.showToast(enterMobilenumber);
    } else {
      // doctor_updateprofile API call
      Utils.showProgress(context, prDialog);
      await editProfileProvider.getDoctorFullUpdateProfile(
          email,
          password,
          fullName,
          countryCode,
          countryName,
          mobile,
          strAddress,
          latitude,
          longitude,
          area,
          city,
          state,
          country,
          editProfileProvider.pickedImageFile);
      await updatedata();

      printLog(
          'DoctorUpdateProfile loading ==>> ${editProfileProvider.loading}');
      if (!editProfileProvider.editloading) {
        // Hide Progress Dialog
        prDialog.hide();

        if (editProfileProvider.successModel.status == 200) {
          currentStep++;
          generalProvider.notifyListener();
        }
        if (!mounted) return;
        Utils.showSnackbar(
            context, "${editProfileProvider.successModel.message}", false);
      }
    }
  }

  Widget kycInfoSteps() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: Form(
        key: _kycFormKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MyText(
                text: "kyc_info",
                multilanguage: true,
                fontsize: Dimens.text24Size,
                fontweight: FontWeight.w600,
                color: colorPrimaryDark,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mLICNameController,
                labelText: nameOnLIC,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mLICNumberController,
                labelText: licNumber,
                keyboardType: const TextInputType.numberWithOptions(),
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mLICAddressController,
                labelText: addressONLIC,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mPostalCodeController,
                labelText: postalCode,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mInstitueNameController,
                labelText: institueName,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mInstitueAddressController,
                labelText: institueAddress,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mDegreeController,
                labelText: degree,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mBatchYearController,
                labelText: batchYear,
                keyboardType: const TextInputType.numberWithOptions(),
              ),

              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mbankNameController,
                labelText: bankName,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mbankcodeController,
                labelText: bankCode,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mbankAddressController,
                labelText: bankAddress,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mifscnoController,
                labelText: ifscno,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: maccountNoController,
                labelText: accountnumber,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mClinicNameController,
                labelText: clinicName,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mYouRoleController,
                labelText: yourRole,
                keyboardType: TextInputType.text,
              ),

              const SizedBox(height: 20),

              CustomTextFormField(
                readOnly: false,
                controller: mClinicAddressController,
                labelText: clinicAddress,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              uploadFiles("upload_front_of_your_lic", "JPG/PNG/PDF Files",
                  "upload_front", 1, editProfileProvider.licFrontFile),
              const SizedBox(height: 20),
              uploadFiles("upload_back_of_your_lic", "JPG/PNG/PDF Files",
                  "upload_back", 2, editProfileProvider.licBackFile),
              const SizedBox(height: 20),
              uploadFiles("upload_degree", "JPG/PNG/PDF Files",
                  "upload_document", 3, editProfileProvider.degreeDocuments),
              const SizedBox(height: 20),
              uploadFiles("upload_bankid", "JPG/PNG/PDF Files", "upload_bankid",
                  4, editProfileProvider.bankIDfile),
              const SizedBox(height: 25),
              // signUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadFiles(
    title,
    subTitle,
    fileSelcteTitle,
    index,
    File? file,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: title,
          multilanguage: true,
          fontsize: Dimens.text16Size,
          color: textTitleColor,
          fontweight: FontWeight.w600,
        ),
        const SizedBox(
          height: 10,
        ),
        MyText(
          text: subTitle,
          multilanguage: false,
          color: grayDark,
          fontsize: Dimens.text14Size,
          fontweight: FontWeight.w400,
        ),
        const SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            switch (index) {
              case 1:
                pickLicFrontImage(); // Call the function for license front image
                break;
              case 2:
                pickLicBackImage(); // Call the function for license back image
                break;
              case 3:
                pickDegreeDocument(); // Call the function for degree document
                break;
              case 4:
                pickBankId(); // Call the function for degree document
                break;
              default:
                // Handle any other cases if necessary
                break;
            }
          },
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 0.5, color: colorPrimary)),
            child: MyText(
              text: fileSelcteTitle,
              color: colorPrimary,
              fontsize: Dimens.text14Size,
              multilanguage: true,
              fontweight: FontWeight.w400,
            ),
          ),
        ),
        file == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: MyText(
                  text: getFileName(file.path), // Use the manual method
                  color: black,
                  fontsize: 14,
                  fontweight: FontWeight.w500,
                ),
              ),
      ],
    );
  }

  void openDatePicker() async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1950),
        lastDate: DateTime(2100));

    if (pickedDate != null) {
      printLog(
          '$pickedDate'); //pickedDate output format => 2021-03-10 00:00:00.000
      String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
      printLog(
          formattedDate); //formatted date output using intl package =>  2021-03-16
      mBirthdateController.text =
          formattedDate; //set output date to TextField value.
      generalProvider.notifyListener();
    }
  }

  clearTextFormField() {
    mFirstNameController.clear();
    mEmailController.clear();
    mPasswordController.clear();
    mMobileController.clear();
  }

  bool validatePassword(String? value) {
    if (value == null || value.isEmpty || (value.length < 5)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> imagePickDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                MyText(
                  text: "pick_image_note",
                  multilanguage: true,
                  color: black,
                  fontsize: Dimens.text18Size,
                  fontweight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: MyText(
                text: "pick_from_gallery",
                multilanguage: true,
                color: colorPrimaryDark,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.bold,
                textalign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                getFromGallery();
              },
            ),
            TextButton(
              child: MyText(
                text: "capture_by_camera",
                multilanguage: true,
                color: colorPrimaryDark,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.bold,
                textalign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop();
                getFromCamera();
              },
            ),
            TextButton(
              child: MyText(
                text: "cancel",
                multilanguage: true,
                color: black,
                fontsize: Dimens.text18Size,
                fontstyle: FontStyle.normal,
                fontweight: FontWeight.normal,
                textalign: TextAlign.center,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  /// Get from gallery
  getFromGallery() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      editProfileProvider.setPickedImage(File(pickedFile.path));
    }
  }

  /// Get from Camera
  getFromCamera() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      editProfileProvider.setPickedImage(File(pickedFile.path));
    }
  }
}
