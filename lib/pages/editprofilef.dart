import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yourappname/model/attachmentuploadmodel.dart';
import 'package:yourappname/model/specialitymodel.dart';
import 'package:yourappname/pages/addworkslot.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/firebaseconstant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/strings.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:yourappname/widgets/mytextformfield.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

class EditProfileF extends StatefulWidget {
  const EditProfileF({super.key});

  @override
  State<EditProfileF> createState() => _EditProfileFState();
}

class _EditProfileFState extends State<EditProfileF> {
  late EditProfileProvider editProfileProvider;
  late ProgressDialog prDialog;
  SharedPre sharedPref = SharedPre();
  // File? pickedImageFile;
  final ImagePicker imagePicker = ImagePicker();
  List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Speciality specialityValue = Speciality();
  bool _passwordVisible = true, visiblePrev = false;
  // THE FOLLOWING TWO VARIABLES ARE REQUIRED TO CONTROL THE STEPPER.
  int activeStep = 0; // Initial step set to 0.
  int upperBound = 2; // upperBound = (total number of Step) - 1.

  ValueNotifier<bool> refreshDegreeDocument = ValueNotifier(false);
  ValueNotifier<bool> refreshCaseStudiesDocument = ValueNotifier(false);
  ValueNotifier<bool> refreshCountryCodeWidget = ValueNotifier(false);
  List<String> serviceChipList = [], healthCareChipList = [];
  final _formKey = GlobalKey<FormState>();
  var mFirstNameController = TextEditingController();
  var mEmailController = TextEditingController();
  var mPasswordController = TextEditingController();
  var mMobileController = TextEditingController();
  var mAddressController = TextEditingController();
  var mAboutUsController = TextEditingController();
  var mServiceController = TextEditingController();
  var mHealthCareController = TextEditingController();
  var mPractisingTenureController = TextEditingController();
  var mInstaController = TextEditingController();
  var mFacebookController = TextEditingController();
  var mTwitterController = TextEditingController();
  String countryCode = "+91";
  String countryName = "India";
  GoogleMapController? mapController; //controller for Google map
  final FirebaseAuth auth = FirebaseAuth.instance;
  CameraPosition? cameraPosition;
  late LatLng startLocation;
  String location = "Search Location",
      strLongitude = "",
      strLatitude = "",
      strWorkingTime = "",
      strAddress = "",
      currentUserFId = "";
  MapType currentMapType = MapType.normal;
  String degreeDocument = "";
  String caseStudies = "";

  String degreeDocumentPath = "";
  String caseStudiesPath = "";
  String isoCode = "IN";
  // final Map<String, Marker> _markers = {};

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

  Future<void> getCurrentLocation(GoogleMapController controller) async {
    if (!editProfileProvider.loading) {
      if (editProfileProvider.doctorProfileModel.status == 200) {
        if (editProfileProvider.doctorProfileModel.result != null) {
          if ((editProfileProvider.doctorProfileModel.result?[0].latitude ?? "")
                  .isEmpty &&
              (editProfileProvider.doctorProfileModel.result?[0].longitude ??
                      "")
                  .isEmpty) {
            // Position position = await determinePosition();
            loc.LocationData position = await determinePosition();
            List<Placemark> newPlace = await placemarkFromCoordinates(
                position.latitude ?? 0.0, position.longitude ?? 0.0);

            Placemark placeMark = newPlace[0];
            strLongitude = position.longitude.toString();
            strLatitude = position.latitude.toString();
            strAddress =
                "${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
            printLog("strLongitude ==if==> $strLongitude");
            printLog("strLatitude ==if==> $strLatitude");
            printLog("strAddress ==if==> $strAddress");

            printLog(
                "${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}");

            mapController = controller;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(
                        position.latitude ?? 0.0, position.longitude ?? 0.0),
                    zoom: 16),
              ),
            );
          } else {
            List<Placemark> newPlace = await placemarkFromCoordinates(
                double.parse(editProfileProvider
                        .doctorProfileModel.result?[0].latitude ??
                    "${Constant.defaultLatitude}"),
                double.parse(editProfileProvider
                        .doctorProfileModel.result?[0].longitude ??
                    "${Constant.defaultLongitude}"));
            // this is all you need
            Placemark placeMark = newPlace[0];
            strLongitude =
                editProfileProvider.doctorProfileModel.result?[0].longitude ??
                    "${Constant.defaultLongitude}";
            strLatitude =
                editProfileProvider.doctorProfileModel.result?[0].latitude ??
                    "${Constant.defaultLatitude}";
            strAddress =
                "${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
            printLog("strLongitude ==else==> $strLongitude");
            printLog("strLatitude ==else==> $strLatitude");
            printLog(
                "Longitude ==else==> ${editProfileProvider.doctorProfileModel.result?[0].longitude ?? "default : ${Constant.defaultLongitude}"}");
            printLog(
                "Latitude ==else==> ${editProfileProvider.doctorProfileModel.result?[0].latitude ?? "default : ${Constant.defaultLatitude}"}");
            printLog("strAddress ==else==> $strAddress");
            printLog(
                "${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}");

            mapController = controller;
            controller.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(
                    target: LatLng(
                        double.parse(editProfileProvider
                                .doctorProfileModel.result?[0].latitude ??
                            "${Constant.defaultLatitude}"),
                        double.parse(editProfileProvider
                                .doctorProfileModel.result?[0].longitude ??
                            "${Constant.defaultLongitude}")),
                    zoom: 16),
              ),
            );
          }
        }
      }
    }
  }

  // Future<Position> determinePosition() async {
  //   loc.Location location = loc.Location();
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //   if (!await location.serviceEnabled()) {
  //     location.requestService();
  //   }

  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     return Future.error('Location services are disabled.');
  //   }

  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }

  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }

  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   return await Geolocator.getCurrentPosition();
  // }

  Future<loc.LocationData> determinePosition() async {
    loc.Location location = loc.Location();

    // Check if service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return Future.error('Location services are disabled.');
      }
    }

    // Check permissions
    loc.PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permissionGranted == loc.PermissionStatus.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, cannot request.');
    }

    // When permissions are granted → get location
    return await location.getLocation();
  }

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    callApi();
    // editProfileProvider.getWorkingSlots();
    _getData();
    // determinePosition();
    super.initState();
  }

  _getData() async {
    currentUserFId = await sharedPref.read("firebaseid");
    printLog("firebaseid ==> $currentUserFId");
  }

  callApi() async {
    await editProfileProvider.getSpecialities();
    await editProfileProvider.getDoctorDetails();
    updateCountryCode();
  }

  void updateCountryCode() {
    countryCode = (editProfileProvider.doctorProfileModel.result?[0].countryCode
                        .toString() ??
                    "")
                .isEmpty ||
            editProfileProvider.doctorProfileModel.result?[0].countryCode
                    .toString() ==
                "null"
        ? "+91"
        : editProfileProvider.doctorProfileModel.result?[0].countryCode ?? "";
    isoCode = getIsoFromDialCode(countryCode);
    countryName = (editProfileProvider.doctorProfileModel.result?[0].countryName
                        .toString() ??
                    "")
                .isEmpty ||
            editProfileProvider.doctorProfileModel.result?[0].countryName
                    .toString() ==
                "null"
        ? "India"
        : editProfileProvider.doctorProfileModel.result?[0].countryName ?? "";
  }

  @override
  void dispose() {
    mFirstNameController.dispose();
    mEmailController.dispose();
    mPasswordController.dispose();
    mMobileController.dispose();
    mAddressController.dispose();
    mPractisingTenureController.dispose();
    mAboutUsController.dispose();
    mServiceController.dispose();
    mHealthCareController.dispose();
    mInstaController.dispose();
    mFacebookController.dispose();
    mTwitterController.dispose();
    editProfileProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileProvider>(
        builder: (context, editProfileProvider, child) {
      return Scaffold(
        backgroundColor: white,
        appBar: Utils.myAppBarWithBack(context, "account_settings", true, true),
        body: SafeArea(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              doctorDetailsEditPage(),
              Positioned(
                bottom: 20,
                child: nextPreviousButton(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget createPageOnClick() {
    if (activeStep == 0) {
      return doctorDetailsEditPage();
    } else if (activeStep == 1) {
      return doctorDetailsEditPage();
    } else if (activeStep == 2) {
      return workHourEditPage();
    } else {
      return doctorDetailsEditPage();
    }
  }

  // Widget buildStepper() {
  //   return NumberStepper(
  //     stepColor: inActiveColor,
  //     lineColor: inActiveColor,
  //     activeStepColor: colorAccent,
  //     numberStyle: const TextStyle(
  //       color: white,
  //     ),
  //     enableNextPreviousButtons: false,
  //     numbers: const [
  //       1,
  //       2,
  //       3,
  //     ],
  //     // activeStep property set to activeStep variable defined above.
  //     activeStep: activeStep,
  //     // This ensures step-tapping updates the activeStep.
  //     onStepReached: (index) {
  //       setState(() {
  //         activeStep = index;
  //       });
  //     },
  //   );
  // }

  Widget nextPreviousButton() {
    return SizedBox(
      height: Constant.buttonHeight,
      width: MediaQuery.of(context).size.width,
      child: InkWell(
        onTap: () {
          validateAndUpdate();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          alignment: Alignment.center,
          decoration: Utils.primaryDarkButton(),
          child: MyText(
            text: "save_change",
            multilanguage: true,
            fontsize: Dimens.text16Size,
            fontstyle: FontStyle.normal,
            fontweight: FontWeight.normal,
            textalign: TextAlign.center,
            color: white,
          ),
        ),
      ),
    );
  }

  // ====== Doctor Details Edit layout START ====== //
  Widget doctorDetailsEditPage() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Consumer<EditProfileProvider>(
        builder: (context, editProfileProvider, child) {
          if (!editProfileProvider.loading) {
            if (editProfileProvider.doctorProfileModel.status == 200 &&
                editProfileProvider.doctorProfileModel.result != null) {
              if (editProfileProvider.doctorProfileModel.result != null &&
                  (editProfileProvider.doctorProfileModel.result?.length ?? 0) >
                      0) {
                printLog(
                    "${editProfileProvider.doctorProfileModel.result?.length}");
                mFirstNameController.text = mFirstNameController.text == ""
                    ? (editProfileProvider
                            .doctorProfileModel.result?[0].fullName ??
                        "")
                    : mFirstNameController.text;
                mEmailController.text =
                    editProfileProvider.doctorProfileModel.result?[0].email ??
                        "";
                mMobileController.text = editProfileProvider
                        .doctorProfileModel.result?[0].mobileNumber ??
                    "";
                mAddressController.text =
                    editProfileProvider.doctorProfileModel.result?[0].address ??
                        "";
                mPractisingTenureController.text = editProfileProvider
                        .doctorProfileModel.result?[0].practicingTenure ??
                    "";
                strAddress =
                    editProfileProvider.doctorProfileModel.result?[0].address ??
                        "";
                // countryCode = (editProfileProvider
                //                     .doctorProfileModel.result?[0].countryCode
                //                     .toString() ??
                //                 "")
                //             .isEmpty ||
                //         editProfileProvider
                //                 .doctorProfileModel.result?[0].countryCode
                //                 .toString() ==
                //             "null"
                //     ? "+91"
                //     : editProfileProvider
                //             .doctorProfileModel.result?[0].countryCode ??
                //         "";
                // isoCode = getIsoFromDialCode(countryCode);
                // countryName = (editProfileProvider
                //                     .doctorProfileModel.result?[0].countryName
                //                     .toString() ??
                //                 "")
                //             .isEmpty ||
                //         editProfileProvider
                //                 .doctorProfileModel.result?[0].countryName
                //                 .toString() ==
                //             "null"
                //     ? "India"
                //     : editProfileProvider
                //             .doctorProfileModel.result?[0].countryName ??
                //         "";

                printLog('strAddress =====> $strAddress');
                strWorkingTime = editProfileProvider
                        .doctorProfileModel.result?[0].workingTime ??
                    "";
                printLog('strWorkingTime ==> $strWorkingTime');

                if (editProfileProvider.specialityModel.status == 200) {
                  for (var item
                      in (editProfileProvider.specialityModel.result ?? [])) {
                    // if (editProfileProvider.doctorProfileModel.result
                    //         ?[0]
                    //         .specialtiesId ==
                    //     item.id) {
                    specialityValue = item;
                    printLog('specialityValue ==> ${specialityValue.name}');
                    printLog('specialityID ==> ${specialityValue.id}');
                    // }
                  }
                }

                mAboutUsController.text = mAboutUsController.text == ""
                    ? (editProfileProvider.doctorProfileModel.result?[0].bio ??
                        "")
                    : mAboutUsController.text;

                // if (serviceChipList.isEmpty) {
                //   splitStoreAndMake(
                //       "Services",
                //       editProfileProvider
                //               .doctorProfileModel.result?[0].services ??
                //           "");
                // }
                // if (healthCareChipList.isEmpty) {
                //   splitStoreAndMake(
                //       "HealthCare",
                //       editProfileProvider
                //               .doctorProfileModel.result?[0].healthCare ??
                //           "");
                // }

                mInstaController.value = TextEditingValue(
                    text: editProfileProvider
                            .doctorProfileModel.result?[0].instagramUrl
                            .toString() ??
                        "");

                degreeDocument = editProfileProvider
                        .doctorProfileModel.result?[0].degreeDocument ??
                    "";
                caseStudies = editProfileProvider
                        .doctorProfileModel.result?[0].caseStudies ??
                    "";

                degreeDocumentPath = degreeDocument;

                caseStudiesPath = caseStudies;

                // mFacebookController.text = editProfileProvider
                //         .doctorProfileModel.result
                //         ?[0]
                //         .facebookUrl ??
                //     "";
                // mTwitterController.text = editProfileProvider
                //         .doctorProfileModel.result
                //         ?[0]
                //         .twitterUrl ??
                //     "";

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            clipBehavior: Clip.antiAlias,
                            child: editProfileProvider.pickedImageFile != null
                                ? Image.file(
                                    editProfileProvider.pickedImageFile!,
                                    fit: BoxFit.cover,
                                    height: 70,
                                    width: 70,
                                  )
                                : MyNetworkImage(
                                    imageUrl: !editProfileProvider.loading
                                        ? (editProfileProvider
                                                    .doctorProfileModel
                                                    .status ==
                                                200
                                            ? (editProfileProvider
                                                    .doctorProfileModel
                                                    .result?[0]
                                                    .image ??
                                                Constant.userPlaceholder)
                                            : Constant.userPlaceholder)
                                        : Constant.userPlaceholder,
                                    fit: BoxFit.cover,
                                    imgHeight: 65,
                                    imgWidth: 65,
                                  ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Expanded(
                              child: InkWell(
                            onTap: () {
                              imagePickDialog();
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(
                                      color: colorPrimaryDark, width: 1),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.camera_alt_outlined,
                                    color: colorPrimaryDark,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: MyText(
                                      text: "change_profile_picture",
                                      color: colorPrimaryDark,
                                      fontsize: Dimens.text15Size,
                                      multilanguage: true,
                                      fontweight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ))
                        ],
                      ),
                    ),
                    editProfileProvider.doctorProfileModel.result?[0].isKyc == 1
                        ? Container(
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                            alignment: Alignment.topLeft,
                            decoration: BoxDecoration(
                                color: lightBlue,
                                borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: [
                                const Iconify(
                                  MaterialSymbols.verified_user,
                                  color: tabDefaultColor,
                                  size: 25,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: MyText(
                                    text: "you_passed_keyc",
                                    fontsize: Dimens.text15Size,
                                    overflow: TextOverflow.ellipsis,
                                    maxline: 1,
                                    multilanguage: true,
                                    fontweight: FontWeight.w500,
                                    textalign: TextAlign.start,
                                    color: tabDefaultColor,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            //===== FullName =====//
                            MyTextFormField(
                              mHint: fullNameReq,
                              mController: mFirstNameController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mReadOnly: false,
                              mHintTextColor: textTitleColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(height: 14),
                            //===== Email =====//
                            MyTextFormField(
                              mHint: emailAddressReq,
                              mController: mEmailController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textTitleColor,
                              mReadOnly: editProfileProvider.doctorProfileModel
                                              .result?[0].type ==
                                          4 ||
                                      editProfileProvider.doctorProfileModel
                                              .result?[0].type ==
                                          2 ||
                                      editProfileProvider.doctorProfileModel
                                              .result?[0].type ==
                                          3
                                  ? true
                                  : false,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(height: 14),
                            //===== Password =====//
                            TextFormField(
                              controller: mPasswordController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              obscureText: _passwordVisible,
                              maxLines: 1,
                              readOnly: false,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    _passwordVisible = !_passwordVisible;
                                    editProfileProvider.notifyListener();
                                  },
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: otherColor,
                                  ),
                                ),
                                hintText: password,
                                hintStyle: GoogleFonts.roboto(
                                  fontSize: 16,
                                  color: textTitleColor,
                                  fontWeight: FontWeight.normal,
                                  fontStyle: FontStyle.normal,
                                ),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                        color: black, width: 0.5)),
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
                            const SizedBox(
                              height: 14,
                            ),
                            //===== Phone Number =====//
                            // MyTextFormField(
                            //   mHint: phoneNumberReq,
                            //   mController: mMobileController,
                            //   mObscureText: false,
                            //   mMaxLine: 1,
                            //   mReadOnly: editProfileProvider
                            //               .doctorProfileModel.result?[0].type ==
                            //           1
                            //       ? true
                            //       : false,
                            //   mHintTextColor: textTitleColor,
                            //   mTextColor: textTitleColor,
                            //   mkeyboardType: TextInputType.text,
                            //   mTextInputAction: TextInputAction.next,
                            //   mInputFormatters: [
                            //     FilteringTextInputFormatter.digitsOnly
                            //   ],
                            //   mInputBorder: OutlineInputBorder(
                            //       borderRadius: BorderRadius.circular(4),
                            //       borderSide: const BorderSide(
                            //           color: black, width: 0.5)),
                            // ),
                            ValueListenableBuilder(
                              valueListenable: refreshCountryCodeWidget,
                              builder: (context, value, child) => SizedBox(
                                height: 55,
                                child: IntlPhoneField(
                                  disableLengthCheck: true,
                                  textAlignVertical: TextAlignVertical.center,
                                  autovalidateMode: AutovalidateMode.disabled,
                                  controller: mMobileController,
                                  style: Utils.googleFontStyle(1, 16,
                                      FontStyle.normal, black, FontWeight.w500),
                                  showCountryFlag: false,
                                  showDropdownIcon: false,
                                  initialCountryCode: isoCode,
                                  dropdownTextStyle: Utils.googleFontStyle(
                                      1,
                                      16,
                                      FontStyle.normal,
                                      black,
                                      FontWeight.w500),
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
                                    hintText: Locales.string(
                                        context, "enteryourmobilenumber"),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)),
                                      borderSide:
                                          BorderSide(color: black, width: 1),
                                    ),
                                    focusedBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7.0)),
                                      borderSide:
                                          BorderSide(color: black, width: 1),
                                    ),
                                  ),
                                  onChanged: (phone) {
                                    printLog(
                                        'phone===> ${phone.completeNumber}');
                                    printLog(
                                        'number===> ${mMobileController.text}');
                                  },
                                  onCountryChanged: (country) {
                                    countryCode =
                                        "+${country.dialCode.toString()}";
                                    countryName = country.name.toString();

                                    isoCode = getIsoFromDialCode(countryCode);
                                    // refreshCountryCodeWidget.value =
                                    //     !refreshCountryCodeWidget.value;
                                    printLog(
                                        'countrycode===> $countryCode, $country');
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            //===== Address =====//
                            MyText(
                              text: "address",
                              multilanguage: true,
                              fontsize: Dimens.text18Size,
                              fontweight: FontWeight.bold,
                              fontstyle: FontStyle.normal,
                              textalign: TextAlign.start,
                              color: textTitleColor,
                            ),
                            const SizedBox(height: 5),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: Constant.textFieldHeight,
                                minWidth: MediaQuery.of(context).size.width,
                              ),
                              child: Container(
                                alignment: Alignment.centerLeft,
                                child: MyTextFormField(
                                  mHint: address,
                                  mController: mAddressController,
                                  mObscureText: false,
                                  mMaxLine: 3,
                                  mHintTextColor: textTitleColor,
                                  mTextColor: textTitleColor,
                                  mReadOnly: true,
                                  mInputBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                          color: black, width: 0.5)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            //===== Address =====//
                            MyText(
                              text: "practicing_tenure",
                              multilanguage: true,
                              fontsize: Dimens.text18Size,
                              fontweight: FontWeight.bold,
                              fontstyle: FontStyle.normal,
                              textalign: TextAlign.start,
                              color: textTitleColor,
                            ),
                            const SizedBox(height: 5),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: MyTextFormField(
                                mHint: practicingtenure,
                                mController: mPractisingTenureController,
                                mObscureText: false,
                                mMaxLine: 1,
                                mHintTextColor: textTitleColor,
                                mTextColor: textTitleColor,
                                mReadOnly: true,
                                mInputBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(4),
                                    borderSide: const BorderSide(
                                        color: black, width: 0.5)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            //===== Speciality =====//
                            MyText(
                              text: "speciality",
                              multilanguage: true,
                              fontsize: Dimens.text18Size,
                              fontweight: FontWeight.bold,
                              fontstyle: FontStyle.normal,
                              textalign: TextAlign.start,
                              color: textTitleColor,
                            ),
                            const SizedBox(height: 5),
                            DropdownButtonFormField2(
                              isExpanded: true,
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      borderSide: const BorderSide(
                                          color: black, width: 0.5))),
                              value: specialityValue,
                              onChanged: (newValue) {
                                printLog('newValue ==> $newValue');
                                specialityValue = newValue as Speciality;
                                printLog(
                                    'specialityValue ==> ${specialityValue.name}');
                                printLog(
                                    "==== .....  ${mAboutUsController.text}");
                              },
                              hint: MyText(
                                text: "speciality",
                                multilanguage: true,
                                fontsize: Dimens.text16Size,
                                fontweight: FontWeight.normal,
                                fontstyle: FontStyle.normal,
                                textalign: TextAlign.start,
                                color: textTitleColor,
                              ),
                              items: editProfileProvider.specialityModel.result
                                  ?.map<DropdownMenuItem<Speciality>>(
                                      (Speciality value) {
                                return DropdownMenuItem<Speciality>(
                                  value: value,
                                  child: MyText(
                                    text: value.name ?? "",
                                    fontsize: Dimens.text15Size,
                                    fontweight: FontWeight.normal,
                                    fontstyle: FontStyle.normal,
                                    textalign: TextAlign.start,
                                    color: textTitleColor,
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 14,
                            ),
                            //===== About Us =====//
                            MyText(
                              text: "about_us",
                              multilanguage: true,
                              fontsize: Dimens.text18Size,
                              fontweight: FontWeight.bold,
                              fontstyle: FontStyle.normal,
                              textalign: TextAlign.start,
                              color: textTitleColor,
                            ),
                            const SizedBox(height: 5),
                            MyTextFormField(
                              mHint: aboutUs,
                              mController: mAboutUsController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textTitleColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            // //===== Services =====//
                            // MyText(
                            //   text: "services",
                            //   multilanguage: true,
                            //   fontsize: Dimens.text18Size,
                            //   fontweight: FontWeight.bold,
                            //   fontstyle: FontStyle.normal,
                            //   textalign: TextAlign.start,
                            //   color: textTitleColor,
                            // ),
                            // const SizedBox(height: 5),
                            // ConstrainedBox(
                            //   constraints: BoxConstraints(
                            //     minHeight: Constant.textFieldHeight,
                            //     minWidth: MediaQuery.of(context).size.width,
                            //   ),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       TextFormField(
                            //         keyboardType: TextInputType.text,
                            //         textInputAction: TextInputAction.next,
                            //         controller: mServiceController,
                            //         obscureText: false,
                            //         maxLines: 1,
                            //         onEditingComplete: () {
                            //           printLog(mServiceController.text);
                            //         },
                            //         onFieldSubmitted: (vService) {
                            //           printLog(vService);
                            //           if (vService.isNotEmpty) {
                            //             serviceChipList.add(vService);
                            //             printLog(
                            //                 'serviceChipList ==> ${serviceChipList.length}');
                            //             mServiceController.clear();
                            //             setState(() {
                            //               addServiceChips();
                            //             });
                            //           }
                            //         },
                            //         decoration: InputDecoration(
                            //           hintText: servicesHint,
                            //           hintStyle: GoogleFonts.roboto(
                            //             fontSize: 16,
                            //             color: textTitleColor,
                            //             fontWeight: FontWeight.normal,
                            //             fontStyle: FontStyle.normal,
                            //           ),
                            //           border: OutlineInputBorder(
                            //               borderRadius:
                            //                   BorderRadius.circular(4),
                            //               borderSide: const BorderSide(
                            //                   color: black, width: 0.5)),
                            //         ),
                            //         style: GoogleFonts.roboto(
                            //           textStyle: const TextStyle(
                            //             fontSize: 16,
                            //             color: textTitleColor,
                            //             fontWeight: FontWeight.normal,
                            //             fontStyle: FontStyle.normal,
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(
                            //         height: 3,
                            //       ),
                            //       addServiceChips(),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(
                            //   height: 14,
                            // ),
                            // //===== Health Care =====//
                            // MyText(
                            //   text: "health_care",
                            //   multilanguage: true,
                            //   fontsize: Dimens.text18Size,
                            //   fontweight: FontWeight.bold,
                            //   fontstyle: FontStyle.normal,
                            //   textalign: TextAlign.start,
                            //   color: textTitleColor,
                            // ),
                            // const SizedBox(
                            //   height: 5,
                            // ),
                            // ConstrainedBox(
                            //   constraints: BoxConstraints(
                            //     minHeight: 55,
                            //     minWidth: MediaQuery.of(context).size.width,
                            //   ),
                            //   child: Column(
                            //     mainAxisAlignment: MainAxisAlignment.start,
                            //     crossAxisAlignment: CrossAxisAlignment.start,
                            //     children: [
                            //       TextFormField(
                            //         keyboardType: TextInputType.text,
                            //         textInputAction: TextInputAction.next,
                            //         controller: mHealthCareController,
                            //         obscureText: false,
                            //         maxLines: 1,
                            //         onEditingComplete: () {},
                            //         onFieldSubmitted: (vHealthCare) {
                            //           if (vHealthCare.isNotEmpty) {
                            //             healthCareChipList.add(vHealthCare);
                            //             printLog(
                            //                 'healthCareChipList ==> ${healthCareChipList.length}');
                            //             mHealthCareController.clear();
                            //             setState(() {
                            //               addHealthCareChips();
                            //             });
                            //           }
                            //         },
                            //         decoration: InputDecoration(
                            //           hintText: healthCareHint,
                            //           hintStyle: GoogleFonts.roboto(
                            //             fontSize: 16,
                            //             color: textTitleColor,
                            //             fontWeight: FontWeight.normal,
                            //             fontStyle: FontStyle.normal,
                            //           ),
                            //           border: OutlineInputBorder(
                            //               borderRadius:
                            //                   BorderRadius.circular(4),
                            //               borderSide: const BorderSide(
                            //                   color: black, width: 0.5)),
                            //         ),
                            //         style: GoogleFonts.roboto(
                            //           textStyle: const TextStyle(
                            //             fontSize: 16,
                            //             color: textTitleColor,
                            //             fontWeight: FontWeight.normal,
                            //             fontStyle: FontStyle.normal,
                            //           ),
                            //         ),
                            //       ),
                            //       const SizedBox(height: 5),
                            //       addHealthCareChips(),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(height: 14),
                            // //===== Social Info =====//
                            // Insta URL //
                            MyText(
                              text: "social_info",
                              multilanguage: true,
                              fontsize: Dimens.text18Size,
                              fontweight: FontWeight.bold,
                              fontstyle: FontStyle.normal,
                              textalign: TextAlign.start,
                              color: textTitleColor,
                            ),
                            const SizedBox(height: 5),
                            MyTextFormField(
                              mHint: instagramURL,
                              mController: mInstaController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textTitleColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(height: 14),
                            // Fb URL //
                            MyTextFormField(
                              mHint: facebookURL,
                              mController: mFacebookController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textTitleColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(height: 14),
                            // Twitter URL //
                            MyTextFormField(
                              mHint: twitterURL,
                              mController: mTwitterController,
                              mObscureText: false,
                              mMaxLine: 1,
                              mHintTextColor: textTitleColor,
                              mTextColor: textTitleColor,
                              mkeyboardType: TextInputType.text,
                              mTextInputAction: TextInputAction.next,
                              mInputBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4),
                                  borderSide: const BorderSide(
                                      color: black, width: 0.5)),
                            ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder(
                              valueListenable: refreshDegreeDocument,
                              builder: (context, value, child) => uploadFiles(
                                  "upload_document",
                                  "JPG/PNG/PDF Files",
                                  "upload_degree",
                                  1,
                                  degreeDocument),
                            ),
                            const SizedBox(height: 20),
                            ValueListenableBuilder(
                              valueListenable: refreshCaseStudiesDocument,
                              builder: (context, value, child) => uploadFiles(
                                  "upload_your_expirence",
                                  "JPG/PNG/PDF Files",
                                  "upload_your_expirence",
                                  2,
                                  caseStudies),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return const NoData(text: '');
              }
            } else {
              return const NoData(text: '');
            }
          } else {
            return editProfileSHimmer();
          }
        },
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

  Widget uploadFiles(title, subTitle, fileSelcteTitle, type, String files) {
    List<String> uploadedFiles = [];
    if (files != "") {
      uploadedFiles = files.split(",");
    }
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
            Utils.imagePickDialog(context, (File filepath) async {
              if (filepath.path != "") {
                await prDialog.show();
                try {
                  AttachmentUploadModel result = await editProfileProvider
                      .uploadAttachmentApi(filepath.path);
                  await prDialog.hide();
                  if (type == 1) {
                    if (degreeDocument != "") {
                      degreeDocument = "$degreeDocument,${result.result}";
                      degreeDocumentPath =
                          "$degreeDocumentPath,${filepath.path}";
                    } else {
                      degreeDocument = result.result ?? "";
                    }

                    refreshDegreeDocument.value = !refreshDegreeDocument.value;
                  } else {
                    if (caseStudies != "") {
                      caseStudies = "$caseStudies,${result.result}";
                      caseStudiesPath = "$caseStudiesPath,${filepath.path}";
                    } else {
                      caseStudies = result.result ?? "";
                    }

                    refreshCaseStudiesDocument.value =
                        !refreshCaseStudiesDocument.value;
                  }
                } catch (e) {
                  await prDialog.hide();
                }
              }
            });
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
        if (uploadedFiles.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: uploadedFiles.length,
              padding: const EdgeInsets.only(top: 10),
              separatorBuilder: (context, index) => const SizedBox(
                width: 15,
              ),
              itemBuilder: (context, index) => Stack(
                alignment: Alignment.topRight,
                children: [
                  Utils.isImageFromHttp(uploadedFiles[index])
                      ? MyNetworkImage(
                          imageUrl: uploadedFiles[index],
                          imgWidth: 100,
                          imgHeight: 100,
                          fit: BoxFit.fill,
                        )
                      : Image.file(
                          File(uploadedFiles[index]),
                          width: 100,
                          height: 100,
                          fit: BoxFit.fill,
                        ),
                  // Positioned(
                  //     top: 0,
                  //     child: GestureDetector(
                  //       onTap: () {
                  //         String deletePath = uploadedFiles[index];
                  //         uploadedFiles.removeWhere((e) => e == deletePath);
                  //         if (type == 1) {
                  //           degreeDocument = uploadedFiles.join(",").toString();
                  //           refreshDegreeDocument.value =
                  //               !refreshDegreeDocument.value;
                  //           print("Defree doc :- ${degreeDocument}");
                  //         } else {
                  //           caseStudies = uploadedFiles.join(",").toString();
                  //           refreshCaseStudiesDocument.value =
                  //               !refreshCaseStudiesDocument.value;
                  //           print("Case studies doc :- ${caseStudies}");
                  //         }
                  //       },
                  //       child: const CircleAvatar(
                  //         radius: 15,
                  //         backgroundColor: colorPrimary,
                  //         child: Center(
                  //           child: Icon(
                  //             Icons.close,
                  //             color: white,
                  //           ),
                  //         ),
                  //       ),
                  //     ))
                ],
              ),
            ),
          ),
      ],
    );
  }

  String getFileName(String filePath) {
    return filePath
        .split('/')
        .last; // Works for Unix-based file paths (Android/iOS)
  }

  // void splitStoreAndMake(String itemType, String uppendString) {
  //   printLog("itemType ==> $itemType");
  //   printLog("uppendString ==> $uppendString");
  //   final splitNames = uppendString.split(',');
  //   List<String> splitList = <String>[];
  //   for (int i = 0; i < splitNames.length; i++) {
  //     splitList.add(splitNames[i]);
  //   }
  //   if (itemType == "Services") {
  //     serviceChipList = splitList;
  //     if (uppendString.isNotEmpty) {
  //       addServiceChips();
  //     }
  //   } else if (itemType == "HealthCare") {
  //     healthCareChipList = splitList;
  //     if (uppendString.isNotEmpty) {
  //       addHealthCareChips();
  //     }
  //   }
  // }

  // Widget addServiceChips() {
  //   return Container(
  //     constraints: const BoxConstraints(
  //       minHeight: 0,
  //       maxHeight: 50,
  //     ),
  //     child: serviceChipList.isNotEmpty
  //         ? ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             shrinkWrap: true,
  //             itemCount: serviceChipList.length,
  //             itemBuilder: (BuildContext context, int position) {
  //               return serviceChipList[position].toString().isNotEmpty
  //                   ? buildChips(
  //                       serviceChipList[position],
  //                       position,
  //                     )
  //                   : const SizedBox();
  //             },
  //           )
  //         : Container(),
  //   );
  // }

  // Widget addHealthCareChips() {
  //   return Container(
  //     constraints: const BoxConstraints(
  //       minHeight: 0,
  //       maxHeight: 50,
  //     ),
  //     child: healthCareChipList.isNotEmpty
  //         ? ListView.builder(
  //             scrollDirection: Axis.horizontal,
  //             shrinkWrap: true,
  //             itemCount: healthCareChipList.length,
  //             itemBuilder: (BuildContext context, int position) {
  //               return healthCareChipList[position].toString().isNotEmpty
  //                   ? buildChips(
  //                       healthCareChipList[position],
  //                       position,
  //                     )
  //                   : const SizedBox();
  //             },
  //           )
  //         : Container(),
  //   );
  // }

  // Widget buildChips(String chipTitle, int index) {
  //   return chipTitle.isNotEmpty
  //       ? Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: InputChip(
  //             padding: const EdgeInsets.all(2),
  //             backgroundColor: chipColor,
  //             shape: const RoundedRectangleBorder(
  //               borderRadius: BorderRadius.all(
  //                 Radius.circular(4),
  //               ),
  //             ),
  //             deleteIcon: const Icon(
  //               Icons.close,
  //               size: 15,
  //               color: black,
  //             ),
  //             label: MyText(
  //               text: chipTitle,
  //               fontsize: Dimens.text11Size,
  //               fontweight: FontWeight.w400,
  //               fontstyle: FontStyle.normal,
  //               textalign: TextAlign.center,
  //               maxline: 1,
  //               overflow: TextOverflow.ellipsis,
  //               color: textTitleColor,
  //             ),
  //             onDeleted: () {
  //               printLog(chipTitle);
  //               printLog('index ==> $index');

  //               if (serviceChipList.contains(chipTitle)) {
  //                 serviceChipList.removeAt(index);
  //               } else if (healthCareChipList.contains(chipTitle)) {
  //                 healthCareChipList.removeAt(index);
  //               }
  //               setState(() {});
  //             },
  //           ),
  //         )
  //       : const SizedBox();
  // }

  Future<void> imagePickDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
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
      // setState(() {
      // pickedImageFile = File(pickedFile.path);
      // });
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
      // setState(() {
      //   pickedImageFile = File(pickedFile.path);
      // });
      editProfileProvider.setPickedImage(File(pickedFile.path));
    }
  }

  // ====== Doctor Details Edit layout END ====== //

  // ====== Clinic Location layout START ====== //
  // Widget locationEditPage() {
  //   return Consumer<EditProfileProvider>(
  //     builder: (context, editProfileProvider, child) {
  //       return !editProfileProvider.loading
  //           ? (editProfileProvider.doctorProfileModel.status == 200
  //               ? Stack(
  //                   children: [
  //                     GoogleMap(
  //                       zoomGesturesEnabled: true,
  //                       zoomControlsEnabled: false,
  //                       onMapCreated: getCurrentLocation,
  //                       mapType: currentMapType,
  //                       initialCameraPosition: CameraPosition(
  //                         target: editProfileProvider.doctorProfileModel.result != null
  //                             ? (LatLng(
  //                                 (editProfileProvider.doctorProfileModel.result?[0].latitude ?? "")
  //                                         .isNotEmpty
  //                                     ? (double.parse(editProfileProvider
  //                                             .doctorProfileModel
  //                                             .result?[0]
  //                                             .latitude
  //                                             .toString() ??
  //                                         strLatitude))
  //                                     : Constant.defaultLatitude,
  //                                 (editProfileProvider.doctorProfileModel
  //                                                 .result?[0].latitude ??
  //                                             "")
  //                                         .isNotEmpty
  //                                     ? (double.parse(editProfileProvider
  //                                             .doctorProfileModel
  //                                             .result?[0]
  //                                             .longitude
  //                                             .toString() ??
  //                                         strLongitude))
  //                                     : Constant.defaultLongitude))
  //                             : Constant.defaultLocation,
  //                         zoom: 14,
  //                       ),
  //                       markers: _markers.values.toSet(),
  //                     ),
  //                     Align(
  //                       alignment: Alignment.topRight,
  //                       child: Column(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: <Widget>[
  //                           const SizedBox(height: 15),
  //                           InkWell(
  //                             onTap: () async {
  //                               var place = await PlacesAutocomplete.show(
  //                                   context: context,
  //                                   apiKey: Constant.googleApikey,
  //                                   mode: Mode.overlay,
  //                                   types: [],
  //                                   strictbounds: false,
  //                                   components: [],
  //                                   onError: (err) {
  //                                     printLog(
  //                                         'Google map Autocomplete error ==>> ${err.errorMessage}');
  //                                   });

  //                               if (place != null) {
  //                                 // form google_maps_webservice package
  //                                 final plist = GoogleMapsPlaces(
  //                                   apiKey: Constant.googleApikey,
  //                                   apiHeaders: await const GoogleApiHeaders()
  //                                       .getHeaders(),
  //                                 );
  //                                 String placeid = place.placeId ?? "0";
  //                                 printLog('Google map Placeid ==>> $placeid');
  //                                 final detail =
  //                                     await plist.getDetailsByPlaceId(placeid);
  //                                 final geometry = detail.result.geometry!;
  //                                 final lat = geometry.location.lat;
  //                                 final lang = geometry.location.lng;
  //                                 var newlatlang = LatLng(lat, lang);
  //                                 List<Placemark> newPlace =
  //                                     await placemarkFromCoordinates(lat, lang);
  //                                 // this is all you need
  //                                 Placemark placeMark = newPlace[0];

  //                                 strLongitude = lang.toString();
  //                                 strLatitude = lat.toString();
  //                                 strAddress =
  //                                     "${placeMark.subLocality}, ${placeMark.locality}, ${placeMark.administrativeArea} ${placeMark.postalCode}, ${placeMark.country}";
  //                                 printLog("strLongitude =NEW=> $strLongitude");
  //                                 printLog("strLatitude =NEW=> $strLatitude");
  //                                 printLog("strAddress ==NEW==> $strAddress");
  //                                 printLog('New latlang ==>> $newlatlang');
  //                                 strLongitude = lang.toString().isNotEmpty
  //                                     ? lang.toString()
  //                                     : (editProfileProvider.doctorProfileModel
  //                                             .result?[0].longitude ??
  //                                         "${Constant.defaultLongitude}");
  //                                 strLatitude = lat.toString().isNotEmpty
  //                                     ? lat.toString()
  //                                     : (editProfileProvider.doctorProfileModel
  //                                             .result?[0].latitude ??
  //                                         "${Constant.defaultLatitude}");

  //                                 //move map camera to selected place with animation
  //                                 mapController?.animateCamera(
  //                                   CameraUpdate.newCameraPosition(
  //                                     CameraPosition(
  //                                         target: newlatlang, zoom: 17),
  //                                   ),
  //                                 );
  //                               }
  //                             },
  //                             child: Container(
  //                               width: 50,
  //                               height: 50,
  //                               margin: const EdgeInsets.only(right: 20),
  //                               alignment: Alignment.center,
  //                               decoration: const BoxDecoration(
  //                                 color: colorPrimary,
  //                                 shape: BoxShape.circle,
  //                               ),
  //                               child: MySvgAssetsImg(
  //                                 imageName: 'search.svg',
  //                                 imgHeight: 18,
  //                                 imgWidth: 18,
  //                                 fit: BoxFit.cover,
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(height: 15),
  //                           Container(
  //                             width: 50,
  //                             height: 50,
  //                             margin: const EdgeInsets.only(right: 20),
  //                             child: FloatingActionButton(
  //                               onPressed: () {
  //                                 printLog('button pressed');
  //                                 onMapTypeButtonPressed();
  //                               },
  //                               materialTapTargetSize:
  //                                   MaterialTapTargetSize.padded,
  //                               backgroundColor: colorPrimary,
  //                               elevation: 5,
  //                               child: const Icon(Icons.map, size: 36),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ],
  //                 )
  //               : Utils.pageLoader())
  //           : Utils.pageLoader();
  //     },
  //   );
  // }

  // void onMapTypeButtonPressed() {
  //   setState(() {
  //     currentMapType =
  //         currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
  //   });
  // }
  // ====== Clinic Location layout END ====== //

  // ====== Working Hours layout START ====== //
  Widget workHourEditPage() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(
            height: 20,
          ),
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 7,
            itemBuilder: (BuildContext context, int weekPos) {
              return buildWorkSlots(weekPos);
            },
          ),
          const SizedBox(
            height: 100,
          ),
        ],
      ),
    );
  }

  Widget buildWorkSlots(int weekPos) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () async {
          printLog("WeekDay position ==> $weekPos");
          printLog("WeekDay ==> ${weekDays[weekPos].toString()}");
          dynamic result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  AddWorkSlot("${(weekPos + 1)}", weekPos, ""),
            ),
          );
          if (result != null && result == true) {}
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 44,
          ),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(
              color: grayDark,
              width: .5,
            ),
            borderRadius: BorderRadius.circular(4),
            shape: BoxShape.rectangle,
          ),
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15),
                height: 44,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: MyText(
                        text: weekDays[weekPos].toString(),
                        fontsize: Dimens.text15Size,
                        fontstyle: FontStyle.normal,
                        fontweight: FontWeight.w600,
                        textalign: TextAlign.start,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        color: textTitleColor,
                      ),
                    ),
                  ],
                ),
              ),
              Consumer<EditProfileProvider>(
                builder: (context, editProfileProvider, child) {
                  if (editProfileProvider.loading) {
                    return const SizedBox.shrink();
                  }
                  if (editProfileProvider.timeSlotModel.status == 200 &&
                      editProfileProvider.timeSlotModel.result != null &&
                      (editProfileProvider.timeSlotModel.result?.length ?? 0) >
                          0) {
                    if (editProfileProvider
                                .timeSlotModel.result?[weekPos].timeSlotes !=
                            null &&
                        (editProfileProvider.timeSlotModel.result?[weekPos]
                                    .timeSlotes?.length ??
                                0) >
                            0) {
                      return Column(
                        children: <Widget>[
                          Container(
                            height: 0.5,
                            color: grayDark,
                          ),
                          const SizedBox(height: 8),
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: editProfileProvider.timeSlotModel
                                .result?[weekPos].timeSlotes?.length,
                            itemBuilder: (BuildContext context, int timePos) {
                              return Container(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 0, 15, 8),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    const SizedBox(width: 9),
                                    MyText(
                                      text:
                                          "${editProfileProvider.timeSlotModel.result?[weekPos].timeSlotes?[timePos].startTime} - ${editProfileProvider.timeSlotModel.result?[weekPos].timeSlotes?[timePos].endTime}",
                                      fontsize: Dimens.text15Size,
                                      fontstyle: FontStyle.normal,
                                      fontweight: FontWeight.normal,
                                      textalign: TextAlign.start,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      color: otherColor,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  // ====== Working Hours layout END ====== //

  // ====== UpdateProfile API START ====== //
  void validateAndUpdate() async {
    String fullName = mFirstNameController.text.toString().trim();
    String email = mEmailController.text.toString().trim();
    String password = mPasswordController.text.toString();
    String mobile = mMobileController.text.toString().trim();
    dynamic specialityID = specialityValue.id.toString();
    String aboutUs = mAboutUsController.text.toString().trim();
    String services = mServiceController.text.toString().trim();
    if (serviceChipList.isNotEmpty) {
      if (serviceChipList.length > 1) {
        services = serviceChipList.toList().join(",");
      } else {
        services = serviceChipList[0];
      }
    }
    String healthCare = "";
    if (healthCareChipList.isNotEmpty) {
      if (healthCareChipList.length > 1) {
        healthCare = healthCareChipList.toList().join(",");
      } else {
        healthCare = healthCareChipList[0];
      }
    }
    String instaURL = mInstaController.text.toString().trim();
    String fbURL = mFacebookController.text.toString().trim();
    String twitterURL = mTwitterController.text.toString().trim();

    printLog("fullName =======> $fullName");
    printLog("email ==========> $email");
    printLog("password =======> $password");
    printLog("mobile =========> $mobile");
    printLog("address ========> $strAddress");
    printLog("specialityID ===> $specialityID");
    printLog("aboutUs ========> $aboutUs");
    printLog("services =======> $services");
    printLog("healthCare =====> $healthCare");
    printLog("instaURL =======> $instaURL");
    printLog("fbURL ==========> $fbURL");
    printLog("twitterURL =====> $twitterURL");
    printLog("Latitude =======> $strLatitude");
    printLog("Longitude ======> $strLongitude");
    printLog("currentUserFId => $currentUserFId");
    printLog("countryCode => $countryCode");
    printLog("countryName => $countryName");

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
      await editProfileProvider.getDoctorUpdateProfile(
          email,
          password,
          fullName,
          countryCode,
          countryName,
          mobile,
          instaURL,
          twitterURL,
          fbURL,
          services,
          aboutUs,
          strWorkingTime,
          healthCare,
          strAddress,
          strLatitude,
          strLongitude,
          specialityID,
          currentUserFId,
          mPractisingTenureController.text.toString(),
          editProfileProvider.pickedImageFile,
          degreeDocument,
          caseStudies);
      await updatedata();

      printLog(
          'DoctorUpdateProfile loading ==>> ${editProfileProvider.loading}');
      if (!editProfileProvider.editloading) {
        // Hide Progress Dialog
        prDialog.hide();

        if (editProfileProvider.successModel.status == 200) {
          clearAllEditedData();
        }
        if (!mounted) return;
        Utils.showSnackbar(
            context, "${editProfileProvider.successModel.message}", false);
      }
    }
  }

  String getIsoFromDialCode(String dialCode) {
    final country = countries.firstWhere(
      (c) => '+${c.dialCode}' == dialCode,
      orElse: () => countries.first, // fallback
    );
    return country.code; // e.g. "IN"
  }

  void clearAllEditedData() async {
    mFirstNameController.clear();
    mEmailController.clear();
    mPasswordController.clear();
    mMobileController.clear();
    mAddressController.clear();
    mAboutUsController.clear();
    mServiceController.clear();
    mHealthCareController.clear();
    mInstaController.clear();
    mFacebookController.clear();
    mTwitterController.clear();
    serviceChipList.clear();
    healthCareChipList.clear();
    strLongitude = "";
    strLatitude = "";
    strWorkingTime = "";
    specialityValue = Speciality();

    // doctor_detail API call
    await editProfileProvider.getDoctorDetails();
    await editProfileProvider.getSpecialities();
    // Hide Progress Dialog
    prDialog.hide();
  }
  // ====== UpdateProfile API END ====== //
}
