import 'dart:io';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/customtextformfield.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:location/location.dart' as loc;
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:progress_stepper/progress_stepper.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  late ProgressDialog prDialog;
  Speciality? specialityValue;
  String firebasedid = "";
  SharedPre sharePref = SharedPre();
  final _formKey = GlobalKey<FormState>();
  final _kycFormKey = GlobalKey<FormState>();
  late bool _passwordVisible;
  final mFirstNameController = TextEditingController();
  final mEmailController = TextEditingController();
  final mLocationController = TextEditingController();
  final mPractisingTenureController = TextEditingController();
  final mBirthdateController = TextEditingController();
  final mPasswordController = TextEditingController();
  final mMobileController = TextEditingController();
  final mFeesController = TextEditingController();
  dynamic fullName, lastName, userEmail, password, mobile, deviceToken, fees;
  late GeneralProvider generalProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<Widget> stepWidgets;
  String? strDeviceToken, strDeviceType;
  File? licFrontFile;
  File? licBackFile;
  File? bankIDfile;
  final ImagePicker imagePicker = ImagePicker();
  File? degreeDocuments;
  File? pickedImageFile;
  //stepper
  int currentStep = 0;
  String countryCode = "+91";
  String countryName = "India";
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

  //address
  String? latitude, longitude, area, city, state, country;

  @override
  void initState() {
    _passwordVisible = true;
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    EditProfileProvider editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    editProfileProvider.getSpecialities();

    prDialog = ProgressDialog(context);
    _getDeviceToken();
    super.initState();
  }

  String getFileName(String filePath) {
    return filePath
        .split('/')
        .last; // Works for Unix-based file paths (Android/iOS)
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
    //   // Handle errors
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(e.toString())),
    //   );
    // }
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
    clearTextFormField();
    mFirstNameController.dispose();
    mEmailController.dispose();
    mPasswordController.dispose();
    mMobileController.dispose();

    super.dispose();
  }

  Future<void> pickLicFrontImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, // Allow custom file types
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'png', 'jpeg'],
    );

    if (!mounted) return;
    if (result != null) {
      licFrontFile = File(result.files.single.path!);
      generalProvider.notifyListener();
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
      bankIDfile = File(result.files.single.path!);
      generalProvider.notifyListener();
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
      licBackFile = File(result.files.single.path!);
      generalProvider.notifyListener();

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
      degreeDocuments = File(result.files.single.path!);
      generalProvider.notifyListener();
      Utils.showSnackbar(context, "documentselected", true);
    } else {
      Utils.showSnackbar(context, "nofileselected", true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<EditProfileProvider, GeneralProvider>(
        builder: (context, editProfileProvider, generalProvider, child) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        appBar: Utils.myAppBarWithBack(context, "signup", true, true),
        body: Column(
          children: [
            Expanded(
                // child: stepWidgets[currentStep],
                child: currentStep == 0
                    ? personalInfoSteps()
                    : currentStep == 1
                        ? kycInfoSteps()
                        : uploadImageSteps()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      currentStep > 0
                          ? InkWell(
                              onTap: () {
                                if (currentStep > 0) {
                                  currentStep = currentStep - 1;
                                }
                                generalProvider.notifyListener();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: colorPrimaryDark, width: 1)),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 25,
                                  color: colorPrimaryDark,
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                      Expanded(
                        child: InkWell(
                          focusColor: colorPrimary,
                          onTap: () async {
                            if (currentStep == 0) {
                              if (mFirstNameController.text.isNotEmpty &&
                                  mEmailController.text.isNotEmpty &&
                                  mLocationController.text.isNotEmpty &&
                                  mPasswordController.text.isNotEmpty &&
                                  mMobileController.text.isNotEmpty &&
                                  mBirthdateController.text.isNotEmpty &&
                                  mPractisingTenureController.text.isNotEmpty) {
                                await validateFormData();
                              } else {
                                Utils.showSnackbar(
                                    context, "pleasefillallfields", true);
                              }
                            } else if (currentStep == 1) {
                              if (mLICNameController.text.isNotEmpty &&
                                  mLICNumberController.text.isNotEmpty &&
                                  mLICAddressController.text.isNotEmpty &&
                                  mPostalCodeController.text.isNotEmpty &&
                                  mInstitueNameController.text.isNotEmpty &&
                                  mInstitueAddressController.text.isNotEmpty &&
                                  mDegreeController.text.isNotEmpty &&
                                  mClinicNameController.text.isNotEmpty &&
                                  mBatchYearController.text.isNotEmpty &&
                                  mYouRoleController.text.isNotEmpty &&
                                  mClinicAddressController.text.isNotEmpty &&
                                  licFrontFile != null &&
                                  licBackFile != null &&
                                  degreeDocuments != null) {
                                await validateKYCData();
                              } else {
                                Utils.showSnackbar(
                                    context, "pleasefillallfields", true);
                              }
                            } else if (currentStep == 2) {
                              printLog("Signup Clicked ++++++++++++++++");
                              if (!mounted) return;
                              Utils.showProgress(context, prDialog);
                              await firebaseRegister(userEmail, password);

                              // await clearTextFormField();
                            } else {
                              if (!mounted) return;
                              Utils.showSnackbar(
                                  context,
                                  generalProvider.loginRegisterModel.message ??
                                      "",
                                  false);
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            width: MediaQuery.of(context).size.width * 0.85,
                            height: Constant.buttonHeight,
                            decoration: Utils.primaryDarkButton(),
                            alignment: Alignment.center,
                            child: MyText(
                              text: currentStep == 2 ? "signup" : "next",
                              multilanguage: true,
                              color: white,
                              textalign: TextAlign.center,
                              fontsize: 16,
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
                      color: gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
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
                text: "create_account",
                multilanguage: true,
                fontsize: 24,
                fontweight: FontWeight.w600,
                color: colorPrimaryDark,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mFirstNameController,
                labelText: fullNameReq,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mEmailController,
                labelText: emailAddressReq,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mPasswordController,
                labelText: passwordReq,
                keyboardType: TextInputType.visiblePassword,
                obscureText: _passwordVisible,
                suffixIcon: Icon(
                  _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  color: otherColor,
                ),
                onSuffixIconPressed: () {
                  _passwordVisible = !_passwordVisible;
                  generalProvider.notifyListener();
                },
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
                    hintText: "enteryourmobilenumber",
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
              CustomTextFormField(
                readOnly: false,
                controller: mFeesController,
                labelText: feesReq,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              CustomTextFormField(
                readOnly: false,
                controller: mBirthdateController,
                labelText: "Birth Date",
                keyboardType: TextInputType.text,
                suffixIcon: const Icon(Icons.calendar_month,
                    size: 25, color: grayLight),
                onSuffixIconPressed: () {
                  openDatePicker();
                },
              ),
              const SizedBox(height: 20),
              Consumer<EditProfileProvider>(
                builder: (context, editProfileProvider, child) {
                  // Safely retrieve the list of results
                  List<Speciality> resultItems =
                      editProfileProvider.specialityModel.result ?? [];

                  // Ensure specialityValue is either null or in resultItems
                  if (specialityValue != null &&
                      !resultItems.contains(specialityValue)) {
                    specialityValue = null;
                  }

                  if (resultItems.isNotEmpty &&
                      editProfileProvider.specialityModel.status == 200) {
                    return DropdownButtonFormField2(
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide:
                              const BorderSide(color: black, width: 0.5),
                        ),
                      ),
                      value: specialityValue,
                      onChanged: (newValue) {
                        specialityValue = newValue as Speciality;
                        generalProvider.notifyListener();
                      },
                      hint: MyText(
                        text: "speciality",
                        multilanguage: true,
                        fontsize: 16,
                        fontweight: FontWeight.normal,
                        fontstyle: FontStyle.normal,
                        textalign: TextAlign.start,
                        color: black,
                      ),
                      items: resultItems
                          .toSet() // Convert to Set to avoid duplicates
                          .map<DropdownMenuItem<Speciality>>(
                              (Speciality value) {
                        return DropdownMenuItem<Speciality>(
                          value: value,
                          child: MyText(
                            text: value.name ?? "",
                            fontsize: 15,
                            fontweight: FontWeight.normal,
                            fontstyle: FontStyle.normal,
                            textalign: TextAlign.start,
                            color: black,
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const SizedBox();
                  }
                },
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
                        fontsize: 13,
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
              // signUpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget uploadImageSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: MyText(
            text: "upload_picture",
            multilanguage: true,
            fontsize: 24,
            fontweight: FontWeight.w600,
            color: colorPrimaryDark,
          ),
        ),
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
                  child: pickedImageFile != null
                      ? Image.file(
                          pickedImageFile!,
                          fit: BoxFit.cover,
                          height: 350,
                          width: MediaQuery.of(context).size.width,
                        )
                      : Container(
                          margin: const EdgeInsets.all(5),
                          height: 350,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const Icon(
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
                    fontsize: 16,
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
                    fontsize: 14,
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
    );
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
                fontsize: 24,
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
                keyboardType: TextInputType.text,
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
                  "upload_front", 1, licFrontFile),
              const SizedBox(height: 20),
              uploadFiles("upload_back_of_your_lic", "JPG/PNG/PDF Files",
                  "upload_back", 2, licBackFile),
              const SizedBox(height: 20),
              uploadFiles("upload_degree", "JPG/PNG/PDF Files",
                  "upload_document", 3, degreeDocuments),
              const SizedBox(height: 20),
              uploadFiles("upload_bankid", "JPG/PNG/PDF Files", "upload_bankid",
                  4, bankIDfile),
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
          fontsize: 16,
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
          fontsize: 14,
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
              fontsize: 14,
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
        //DateTime.now() - not to allow to choose before today.
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

  Widget signUpButton() {
    return InkWell(
      focusColor: colorPrimary,
      onTap: () => validateFormData(),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.55,
        height: Constant.buttonHeight,
        decoration: Utils.primaryDarkButton(),
        alignment: Alignment.center,
        child: MyText(
          text: "signup",
          multilanguage: true,
          color: white,
          textalign: TextAlign.center,
          fontsize: 16,
          fontweight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget goToLogin() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
      child: RichText(
        text: TextSpan(
          text: alreadyHaveAccount,
          style: GoogleFonts.roboto(
            textStyle: const TextStyle(
              color: otherLightColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          children: <TextSpan>[
            TextSpan(
              text: loginFSpace.toUpperCase(),
              style: GoogleFonts.roboto(
                textStyle: const TextStyle(
                  color: colorPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  clearTextFormField();
                  Navigator.of(context).pop();
                },
            ),
          ],
        ),
      ),
    );
  }

  bool validatePassword(String? value) {
    if (value == null || value.isEmpty || (value.length < 5)) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> validateFormData() async {
    final isValidForm = _formKey.currentState!.validate();
    printLog("isValidForm => $isValidForm");
    // Validate returns true if the form is valid, or false otherwise.
    if (isValidForm) {
      fullName = mFirstNameController.text.toString().trim();
      userEmail = mEmailController.text.toString().trim();
      password = mPasswordController.text.toString().trim();
      mobile = mMobileController.text.toString().trim();
      fees = mFeesController.text.toString().trim();

      if (mFirstNameController.text.isEmpty) {
        Utils.showToast(enterFirstname);
      } else if (mEmailController.text.isEmpty) {
        Utils.showToast(enterEmail);
      } else if (mPasswordController.text.isEmpty) {
        Utils.showToast(enterPassword);
      } else if (mMobileController.text.isEmpty) {
        Utils.showToast(enterMobilenumber);
      } else if (mFeesController.text.isEmpty) {
        Utils.showToast(enterFees);
      } else if (!EmailValidator.validate(mEmailController.text)) {
        Utils.showToast(enterValidEmail);
      } else if (mPasswordController.text.length < 6) {
        Utils.showToast("$enterMinimumCharacters in $password");
      } else {
        // doctor_registration API call
        currentStep++;
        generalProvider.notifyListener();
      }
    }
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
        currentStep++;
        generalProvider.notifyListener(); // doctor_registration API call
      }
    }
  }

  callKycApi(int doctorId) async {
    printLog("Ky Started");
    try {
      await generalProvider.doctorKYC(
          mLICNameController.text.toString(),
          mLICNumberController.text.toString(),
          mLICAddressController.text.toString(),
          mPostalCodeController.text.toString(),
          mYouRoleController.text.toString(),
          mDegreeController.text.toString(),
          mBatchYearController.text.toString(),
          mClinicNameController.text.toString(),
          licFrontFile,
          licBackFile,
          mInstitueNameController.text.toString(),
          mInstitueAddressController.text.toString(),
          mClinicAddressController.text.toString(),
          mBirthdateController.text.toString(),
          mbankNameController.text.toString(),
          mbankcodeController.text.toString(),
          mbankAddressController.text.toString(),
          mifscnoController.text.toString(),
          maccountNoController.text.toString(),
          bankIDfile,
          degreeDocuments,
          doctorId);

      if (generalProvider.kycSuccessModel.status == 200 &&
          generalProvider.kycSuccessModel.result != null) {
        Utils.showToast(generalProvider.kycSuccessModel.message.toString());
      } else {
        Utils.showToast(generalProvider.kycSuccessModel.message.toString());
      }
      prDialog.hide();
    } catch (e) {
      prDialog.hide();
    }
  }

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      printLog('createUserWithEmailAndPassword Error 1 :===> $e');
      if (e.code == 'email-already-in-use') {
        printLog('The account already exists for that email.');
        try {
          UserCredential userCredential =
              await _auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          return userCredential.user;
        } on FirebaseAuthException catch (e) {
          printLog('createUserWithEmailAndPassword Error 2 :===> $e');
          if (e.code == 'email-already-in-use') {
            printLog('The account already exists for that email.');
            Utils.showToast(e.message.toString());
          }
        }
      }
      return null;
    }
  }

  firebaseRegister(String email, String password) async {
    printLog("firebaseRegister email ========> $email");
    printLog("firebaseRegister password =====> $password");
    Utils.showProgress(context, prDialog);
    User? user = await createUserWithEmailAndPassword(email, password);

    if (user != null) {
      try {
        assert(await user.getIdToken() != null);
        printLog("User Name: ${user.displayName}");
        printLog("User Email ${user.email}");
        printLog("User photoUrl ${user.photoURL}");
        printLog("uid ===> ${user.uid}");
        firebasedid = user.uid;
        printLog('firebasedid :===> $firebasedid');

        // Check is already sign up
        final QuerySnapshot result = await FirebaseFirestore.instance
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.userid, isEqualTo: firebasedid)
            .get();

        final List<DocumentSnapshot> documents = result.docs;

        if (documents.isEmpty) {
          // Writing data to server because here is a new user
          FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebasedid)
              .set({
            FirestoreConstants.email: email,
            FirestoreConstants.name: fullName,
            FirestoreConstants.profileurl: Constant.userPlaceholder,
            FirestoreConstants.userid: firebasedid,
            FirestoreConstants.createdAt:
                DateTime.now().millisecondsSinceEpoch.toString(),
            FirestoreConstants.bioData: "",
            FirestoreConstants.username: "",
            FirestoreConstants.mobileNumber: mobile,
            FirestoreConstants.chattingWith: null,
            FirestoreConstants.pushToken: strDeviceToken
          });
        } else {
          printLog('strDeviceToken ....==>> $strDeviceToken');
          printLog('firebasedid ....==>> $firebasedid');
          // Update data to Firestore
          FirebaseFirestore.instance
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebasedid)
              .update({
                FirestoreConstants.email: email,
                FirestoreConstants.name: fullName,
                FirestoreConstants.profileurl: Constant.userPlaceholder,
                FirestoreConstants.userid: firebasedid,
                FirestoreConstants.createdAt:
                    DateTime.now().millisecondsSinceEpoch.toString(),
                FirestoreConstants.bioData: "",
                FirestoreConstants.username: "",
                FirestoreConstants.mobileNumber: mobile,
                FirestoreConstants.chattingWith: null,
                FirestoreConstants.pushToken: strDeviceToken
              })
              .then((value) => printLog("User Updated"))
              .onError((error, stackTrace) {
                printLog("updateDataFirestore error ===> ${error.toString()}");
                printLog(
                    "updateDataFirestore stackTrace ===> ${stackTrace.toString()}");
              });
        }
        normalRegister();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          printLog('The password provided is too weak.');
        } else if (e.code == 'email-already-in-use') {
          Utils.showToast(e.message);
          printLog('The account already exists for that email.');
        }
        await prDialog.hide();
      }
    } else {
      await prDialog.hide();
    }
  }

  normalRegister() async {
    // registration API call

    printLog('firebasedid :===> $firebasedid');
    await generalProvider.registerDoctor(
        fullName,
        userEmail,
        password,
        mobile,
        fees,
        firebasedid,
        strDeviceToken,
        strDeviceType,
        mLocationController.text.toString(),
        specialityValue?.id,
        mPractisingTenureController.text.toString(),
        mBirthdateController.text.toString(),
        latitude,
        longitude,
        area,
        city,
        state,
        country,
        countryCode,
        countryName,
        pickedImageFile ?? File(""));

    if (!mounted) return;
    await Utils.updateGeneralSettingData(context, generalProvider);
    checkAndNavigate();
  }

  Future<void> checkAndNavigate() async {
    printLog('firebasedid :===> $firebasedid');
    printLog('checkAndNavigate loading ==>> ${generalProvider.loading}');
    if (!generalProvider.loading) {
      // Hide Progress Dialog

      if (generalProvider.loginRegisterModel.status == 200 &&
          generalProvider.loginRegisterModel.result != null) {
        printLog(
            'loginRegisterModel ==>> ${generalProvider.loginRegisterModel.toString()}');
        printLog('Registration Successfull!');
        Utils.saveUserCreds(
          userID: generalProvider.loginRegisterModel.result?[0].id.toString(),
          userName:
              generalProvider.loginRegisterModel.result?[0].fullName.toString(),
          userEmail:
              generalProvider.loginRegisterModel.result?[0].email.toString(),
          userMobile: generalProvider.loginRegisterModel.result?[0].mobileNumber
              .toString(),
          userImage: generalProvider.loginRegisterModel.result?[0].profileImg
              .toString(),
          userPremium: '',
          userType:
              generalProvider.loginRegisterModel.result?[0].type.toString(),
          userFirebaseId: generalProvider
              .loginRegisterModel.result?[0].firebaseId
              .toString(),
        );

        // Set UserID for Next
        Constant.userID =
            generalProvider.loginRegisterModel.result?[0].id.toString() ?? "";
        await callKycApi(generalProvider.loginRegisterModel.result?[0].id ?? 0);
        await sharePref.save("isEdit", "1");
        printLog('Constant userID ==>> ${Constant.userID}');
        await prDialog.hide();
        if (!mounted) return;
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
    } else {
      await prDialog.hide();
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
                  fontsize: 18,
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
                fontsize: 18,
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
                fontsize: 18,
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
                fontsize: 18,
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
  void getFromGallery() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      pickedImageFile = File(pickedFile.path);
      printLog("Gallery pickedImageFile ==> ${pickedImageFile!.path}");
      generalProvider.notifyListener();
    }
  }

  /// Get from Camera
  void getFromCamera() async {
    final XFile? pickedFile = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 100,
    );
    if (pickedFile != null) {
      pickedImageFile = File(pickedFile.path);
      printLog("Camera pickedImageFile ==> ${pickedImageFile!.path}");
      generalProvider.notifyListener();
    }
  }
}
