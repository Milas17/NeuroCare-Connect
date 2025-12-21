import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:kivicare_flutter/components/gender_selection_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/clinic_list_model.dart';
import 'package:kivicare_flutter/network/google_repository.dart';
import 'package:kivicare_flutter/network/patient_list_repository.dart';
import 'package:kivicare_flutter/screens/auth/components/login_register_widget.dart';
import 'package:kivicare_flutter/screens/auth/screens/map_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/doctor_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/patient_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/dashboard/screens/receptionist_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/patient_clinic_selection_screen.dart';
import 'package:kivicare_flutter/services/location_service.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/app_widgets.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/extensions/date_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../network/auth_repository.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  GlobalKey<FormState> formKey = GlobalKey();
  GlobalKey<FormState> passwordFormKey = GlobalKey();

  TextEditingController emailCont = TextEditingController();
  TextEditingController firstNameCont = TextEditingController();
  TextEditingController lastNameCont = TextEditingController();
  TextEditingController contactNumberCont = TextEditingController();
  TextEditingController dOBCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();
  TextEditingController selectedClinicCont = TextEditingController();

  TextEditingController addressCont = TextEditingController();

  String? genderValue;
  String? bloodGroup;
  String? selectedClinic;
  String? selectedRole;

  Clinic? selectedClinicData;
  List<Clinic> selectedClinics = [];
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();
  FocusNode firstNameFocus = FocusNode();
  FocusNode lastNameFocus = FocusNode();
  FocusNode contactNumberFocus = FocusNode();
  FocusNode dOBFocus = FocusNode();
  FocusNode bloodGroupFocus = FocusNode();
  FocusNode roleFocus = FocusNode();
  FocusNode clinicFocus = FocusNode();

  FocusNode genderFocus = FocusNode();

  late DateTime birthDate;

  bool isFirstTime = true;
  String countryCode = "+91";
  bool isAcceptedTerms = false;

  @override
  void initState() {
    super.initState();

    afterBuildCreated(() => () {
          setStatusBarColor(
            appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withValues(alpha: 0.02),
            statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
          );
        });
  }

  Future<void> _handleSetLocationClick() async {
    final hasPermission = await handlePermission();

    if (!hasPermission) {
      toast(locale.lblPermissionDenied);
      throw locale.lblPermissionDenied;
    }
    if (hasPermission) {
      String? res = await MapScreen(latitude: getDoubleAsync(SharedPreferenceKey.latitudeKey), latLong: getDoubleAsync(SharedPreferenceKey.longitudeKey)).launch(context);

      if (res != null) {
        addressCont.text = res;
        setState(() {});
      }
    }
  }

  Future<void> _handleCurrentLocationClick() async {
    final hasPermission = await handlePermission();

    if (!hasPermission) {
      toast(locale.lblPermissionDenied);
      throw locale.lblPermissionDenied;
    }
    if (hasPermission) {
      appStore.setLoading(true);
      await getUserLocation().then((value) {
        addressCont.clear();
        addressCont.text = value;

        setState(() {});
      }).whenComplete(() {
        appStore.setLoading(false);
      }).catchError((e) {
        log(e);
        appStore.setLoading(false);
        toast(e.toString());
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void signUp() async {
    hideKeyboard(context);
    // if (passwordFormKey.currentState!.validate()) {
    //   passwordFormKey.currentState!.save();
    //   return;
    // }

    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (genderValue == null) {
        toast("Gender field is required");
        return;
      }
      String rawPhone = contactNumberCont.text.validate().trim();
      String digitsOnly = rawPhone.replaceAll(RegExp(r'\D'), '');

      if (digitsOnly.isEmpty) {
        toast(locale.contactNumberIsRequired);
        return;
      }
      if (digitsOnly.length < 8 || digitsOnly.length > 15) {
        toast("Enter a valid phone number");
        return;
      }

      appStore.setLoading(true);

      String phoneNumber = digitsOnly;

      Map request = {
        "first_name": firstNameCont.text.validate(),
        "last_name": lastNameCont.text.validate(),
        "user_email": emailCont.text.validate(),
        "mobile_number": "$countryCode$phoneNumber",
        "gender": genderValue.validate().toLowerCase(),
        "dob": birthDate.getFormattedDate(SAVE_DATE_FORMAT).validate(),
        "user_pass": passwordCont.text,
        'role': selectedRole,
      };
      if (selectedRole == UserRolePatient && bloodGroup.validate().isNotEmpty) {
        request.putIfAbsent("blood_group", () => bloodGroup.validate());
      }
      // if (selectedClinicData != null) {
      //   request.putIfAbsent('clinic_id', () => selectedClinicData!.id.validate());
      // }
      if (selectedRole == UserRoleDoctor) {
        if (selectedClinics.isNotEmpty) {
          request.putIfAbsent('clinic_id', () => selectedClinics.map((c) => c.id.validate()).join(","));
        } else {
          toast(locale.clinicIdRequired);
          appStore.setLoading(false);
          return;
        }
      } else {
        if (selectedClinicData != null) {
          request.putIfAbsent('clinic_id', () => selectedClinicData!.id.validate());
        } else {
          toast(locale.clinicIdRequired);
          appStore.setLoading(false);
          return;
        }
      }

      if (!isAcceptedTerms) {
        toast("You must agree to the Terms & Conditions before signing up");
        return;
      }

      await addNewUserAPI(request).then((value) async {
        toast(value.message.capitalizeFirstLetter().validate());

        Map<String, dynamic> req = {
          'username': emailCont.text,
          'password': passwordCont.text,
        };

        await loginAPI(req).then((value) async {
          if (value != null) {
            setValue(USER_NAME, emailCont.text);
            setValue(USER_PASSWORD, passwordCont.text);
            setValue(IS_REMEMBER_ME, true);

            getConfigurationAPI().whenComplete(() {
              if (userStore.userRole!.toLowerCase() == UserRoleDoctor) {
                doctorAppStore.setBottomNavIndex(0);
                toast(locale.lblLoginSuccessfullyAsADoctor + '!! 🎉');
                setValue(SELECTED_PROFILE_INDEX, 2);
                DoctorDashboardScreen().launch(context, isNewTask: true, duration: pageAnimationDuration, pageRouteAnimation: PageRouteAnimation.Slide);
              } else if (userStore.userRole!.toLowerCase() == UserRolePatient) {
                toast(locale.lblLoginSuccessfullyAsAPatient + '!! 🎉');
                patientStore.setBottomNavIndex(0);
                setValue(SELECTED_PROFILE_INDEX, 0);
                PatientDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide, duration: pageAnimationDuration);
              } else if (userStore.userRole!.toLowerCase() == UserRoleReceptionist) {
                setValue(SELECTED_PROFILE_INDEX, 1);
                receptionistAppStore.setBottomNavIndex(0);
                toast(locale.lblLoginSuccessfullyAsAReceptionist + '!! 🎉');
                RDashBoardScreen().launch(context, isNewTask: true, pageRouteAnimation: PageRouteAnimation.Slide, duration: pageAnimationDuration);
              } else {
                toast(locale.lblWrongUser);
              }
              appStore.setLoading(false);
            }).catchError((e) {
              appStore.setLoading(false);

              throw e;
            });
          }
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString().capitalizeFirstLetter());
        });
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString().capitalizeFirstLetter());
      });
    } else {
      isFirstTime = !isFirstTime;
      setState(() {});
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: formKey,
                autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    64.height,
                    Image.asset(appIcon, height: 100, width: 100),
                    16.height,
                    RichTextWidget(
                      list: [
                        TextSpan(text: APP_FIRST_NAME, style: boldTextStyle(size: 32, letterSpacing: 1)),
                        TextSpan(text: APP_SECOND_NAME, style: primaryTextStyle(size: 32, letterSpacing: 1)),
                      ],
                    ).center(),
                    32.height,
                    Text(locale.lblSignUpAsPatient, style: secondaryTextStyle(size: 14)),
                    24.height,
                    Row(
                      children: [
                        AppTextField(
                          textStyle: primaryTextStyle(),
                          controller: firstNameCont,
                          textFieldType: TextFieldType.NAME,
                          focus: firstNameFocus,
                          errorThisFieldRequired: locale.lblFirstNameIsRequired,
                          nextFocus: lastNameFocus,
                          decoration: inputDecoration(
                            context: context,
                            labelText: locale.lblFirstName,
                            prefixIcon: ic_user.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                          ),
                          onFieldSubmitted: (value) {
                            lastNameFocus.requestFocus();
                          },
                        ).expand(),
                        16.width,
                        AppTextField(
                            textStyle: primaryTextStyle(),
                            controller: lastNameCont,
                            textFieldType: TextFieldType.NAME,
                            focus: lastNameFocus,
                            nextFocus: emailFocus,
                            errorThisFieldRequired: locale.lblLastNameIsRequired,
                            decoration: inputDecoration(context: context, labelText: locale.lblLastName, prefixIcon: ic_user.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                            onFieldSubmitted: (value) {
                              emailFocus.requestFocus();
                            }).expand(),
                      ],
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      controller: emailCont,
                      textFieldType: TextFieldType.EMAIL,
                      focus: emailFocus,
                      nextFocus: passwordFocus,
                      errorThisFieldRequired: locale.lblEmailIsRequired,
                      onFieldSubmitted: (value) {
                        passwordFocus.requestFocus();
                      },
                      decoration: inputDecoration(context: context, labelText: locale.lblEmail, prefixIcon: ic_message.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                    ),
                    16.height,
                    AppTextField(
                      isPassword: true,
                      controller: passwordCont,
                      focus: passwordFocus,
                      nextFocus: confirmPasswordFocus,
                      textStyle: primaryTextStyle(),
                      errorThisFieldRequired: locale.passwordIsRequired,
                      textFieldType: TextFieldType.PASSWORD,
                      obscureText: true,
                      validator: (value) {
                        String password = value?.trim() ?? '';
                        RegExp regex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$');
                        if (password.isEmpty) {
                          return locale.passwordIsRequired;
                        } else if (!regex.hasMatch(password)) {
                          return locale.lblPasswordMustBeStrong;
                        } else {
                          return null;
                        }
                      },
                      suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      decoration: inputDecoration(context: context, labelText: locale.lblPassword, prefixIcon: ic_lock.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                      onFieldSubmitted: (value) {
                        confirmPasswordFocus.requestFocus();
                      },
                    ),
                    16.height,
                    AppTextField(
                      isPassword: true,
                      controller: confirmPasswordCont,
                      focus: confirmPasswordFocus,
                      textStyle: primaryTextStyle(),
                      nextFocus: contactNumberFocus,
                      errorThisFieldRequired: locale.confirmPasswordIsRequired,
                      textFieldType: TextFieldType.PASSWORD,
                      obscureText: true,
                      validator: (value) {
                        if (confirmPasswordCont.text.isEmpty) return locale.confirmPasswordIsRequired;
                        if (passwordCont.text != confirmPasswordCont.text) {
                          return locale.lblPwdDoesNotMatch;
                        } else {
                          return null;
                        }
                      },
                      onFieldSubmitted: (value) {
                        contactNumberFocus.requestFocus();
                      },
                      suffixPasswordVisibleWidget: ic_showPassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      suffixPasswordInvisibleWidget: ic_hidePassword.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      decoration: inputDecoration(context: context, labelText: locale.lblConfirmPassword, prefixIcon: ic_lock.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                    ),
                    16.height,
                    IntlPhoneField(
                      controller: contactNumberCont,
                      initialCountryCode: 'IN', // default India
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblContactNumber,
                        prefixIcon: ic_phone.iconImage(size: 18, color: context.iconColor).paddingAll(14),
                      ),
                      style: primaryTextStyle(),
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (value) {
                        // value may be a PhoneNumber instance or a String depending on package version
                        if (value == null) return locale.contactNumberIsRequired;

                        String number;
                        number = (value.number).trim();

                        if (number.isEmpty) return locale.contactNumberIsRequired;

                        // optional: basic digit-only length check
                        final digits = number.replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 8 || digits.length > 15) return "Enter a valid phone number";

                        return null;
                      },
                      onChanged: (phone) {
                        // PhoneNumber object -> phone.countryCode is like '+91'
                        if (phone.countryCode.isNotEmpty) {
                          countryCode = phone.countryCode;
                        }
                      },
                      onCountryChanged: (country) {
                        countryCode = "+${country.dialCode}";
                      },
                    ),
                    16.height,
                    AppTextField(
                      textStyle: primaryTextStyle(),
                      controller: dOBCont,
                      nextFocus: bloodGroupFocus,
                      focus: dOBFocus,
                      textFieldType: TextFieldType.NAME,
                      errorThisFieldRequired: locale.lblBirthDateIsRequired,
                      readOnly: true,
                      onFieldSubmitted: (value) {
                        if (selectedRole == UserRolePatient) bloodGroupFocus.requestFocus();
                      },
                      onTap: () {
                        dateBottomSheet(
                          context,
                          onBirthDateSelected: (selectedBirthDate) {
                            if (selectedBirthDate != null) {
                              dOBCont.text = DateFormat(SAVE_DATE_FORMAT).format(selectedBirthDate);
                              birthDate = selectedBirthDate;
                              setState(() {});
                            }
                          },
                        );
                      },
                      decoration: inputDecoration(context: context, labelText: locale.lblDOB, prefixIcon: ic_calendar.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                    ),
                    16.height,
                    Row(
                      children: [
                        DropdownButtonFormField(
                          icon: SizedBox.shrink(),
                          isExpanded: true,
                          borderRadius: radius(),
                          dropdownColor: context.cardColor,
                          focusNode: roleFocus,
                          autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value.isEmptyOrNull)
                              return locale.roleIsRequired;
                            else
                              return null;
                          },
                          decoration: inputDecoration(context: context, labelText: locale.lblSelectRole, prefixIcon: ic_user.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                          onChanged: (dynamic role) {
                            selectedRole = role;

                            // 👇 Reset state on role change
                            if (selectedRole == UserRoleDoctor) {
                              selectedClinicData = null;
                              selectedClinics = [];
                              selectedClinicCont.text = "";
                            } else {
                              selectedClinics = [];
                              selectedClinicData = null;
                              selectedClinicCont.text = "";
                            }

                            setState(() {});
                          },
                          items: userRoleList.map((role) {
                            return DropdownMenuItem<String>(
                              value: role,
                              onTap: () {
                                selectedRole = role;
                                if (selectedRole == UserRolePatient)
                                  bloodGroupFocus.requestFocus();
                                else
                                  clinicFocus.requestFocus();
                                setState(() {});
                              },
                              child: Text(role.capitalizeEachWord(), style: primaryTextStyle()),
                            );
                          }).toList(),
                        ).expand(),
                        if (selectedRole == UserRolePatient) 16.width,
                        if (selectedRole == UserRolePatient)
                          DropdownButtonFormField(
                            icon: SizedBox.shrink(),
                            isExpanded: true,
                            borderRadius: radius(),
                            dropdownColor: context.cardColor,
                            focusNode: bloodGroupFocus,
                            decoration: inputDecoration(context: context, labelText: locale.lblBloodGroup, prefixIcon: ic_arrow_down.iconImage(size: 10, color: context.iconColor).paddingAll(14)),
                            onChanged: (dynamic value) {
                              bloodGroup = value;
                              bloodGroupFocus.unfocus();
                            },
                            items: bloodGroupList.map((bloodGroup) => DropdownMenuItem(value: bloodGroup, child: Text("$bloodGroup", style: primaryTextStyle()))).toList(),
                          ).expand()
                      ],
                    ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.NAME,
                      focus: clinicFocus,
                      controller: selectedClinicCont,
                      isValidationRequired: true,
                      readOnly: true,
                      errorThisFieldRequired: locale.clinicIdRequired,
                      selectionControls: EmptyTextSelectionControls(),
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblSelectClinic,
                        prefixIcon: ic_clinic.iconImage(size: 18, color: context.iconColor).paddingAll(14),
                      ),
                      validator: (value) {
                        if (selectedRole == UserRoleDoctor) {
                          if (selectedClinics.isEmpty) return locale.clinicIdRequired;
                        } else {
                          if (selectedClinicData == null) return locale.clinicIdRequired;
                        }
                        return null;
                      },
                      maxLines: 1,
                      onTap: () {
                        hideKeyboard(context);
                        bool isDoctor = selectedRole == UserRoleDoctor;

                        PatientClinicSelectionScreen(
                          isForRegistration: true,
                          clinicId: selectedClinicData != null ? selectedClinicData!.id.toInt() : null,
                          isDoctor: isDoctor,
                          preselectedClinics: isDoctor ? selectedClinics : (selectedClinicData != null ? [selectedClinicData!] : []),
                        ).launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                          if (value != null) {
                            if (isDoctor) {
                              selectedClinics = value as List<Clinic>;
                              selectedClinicCont.text = selectedClinics.map((c) => c.name.validate()).join(", ");
                            } else {
                              selectedClinicData = value;
                              selectedClinicCont.text = selectedClinicData!.name.validate();
                            }
                            setState(() {});
                          } else {
                            print("No clinic selected");
                          }
                        });
                      },
                    ),
                    16.height,
                    GenderSelectionComponent(
                      onTap: (value) {
                        genderValue = value;
                        setState(() {});
                      },
                      type: genderValue,
                      isError: !isFirstTime && genderValue == null,
                    ),
                    if (!isFirstTime && genderValue == null)
                      Container(
                        padding: EdgeInsets.only(left: 10, top: 2),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          locale.lblSelectGender,
                          style: TextStyle(color: Colors.red.shade800, fontSize: 12),
                        ),
                      ),
                    16.height,
                    AppTextField(
                      textFieldType: TextFieldType.MULTILINE,
                      controller: addressCont,
                      minLines: 1,
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblAddress,
                        prefixIcon: ic_location.iconImage(size: 18, color: context.iconColor).paddingAll(14),
                      ),
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          child: Text(locale.chooseFromMap, style: boldTextStyle(color: primaryColor, size: 13)),
                          onPressed: () {
                            _handleSetLocationClick();
                          },
                        ).flexible(),
                        TextButton(
                          onPressed: _handleCurrentLocationClick,
                          child: Text(locale.currentLocation, style: boldTextStyle(color: primaryColor, size: 13), textAlign: TextAlign.right),
                        ).flexible(),
                      ],
                    ),
                    16.height,
                    Row(
                      children: [
                        Checkbox(
                          value: isAcceptedTerms,
                          onChanged: (value) {
                            setState(() {
                              isAcceptedTerms = value ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              text: "I agree to the ",
                              style: primaryTextStyle(size: 16),
                              children: [
                                TextSpan(text: locale.lblTermsAndCondition, style: boldTextStyle(color: primaryColor, size: 16), recognizer: TapGestureRecognizer()),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    AppButton(
                      width: context.width(),
                      shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
                      color: primaryColor,
                      padding: EdgeInsets.all(16),
                      child: Text(locale.lblSignUp, style: boldTextStyle(color: textPrimaryDarkColor)),
                      onTap: signUp,
                    ),
                    24.height,
                    LoginRegisterWidget(
                      title: locale.lblAlreadyAMember,
                      subTitle: locale.lblSignIn + " ?",
                      onTap: () {
                        finish(context);
                      },
                    ),
                    24.height,
                  ],
                ),
              ),
            ),
            Positioned(
              top: -2,
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20),
                onPressed: () {
                  finish(context);
                },
              ),
            ),
            Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).center())
          ],
        ),
      ),
    );
  }
}
