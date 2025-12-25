import 'package:yourappname/pages/aboutprivacyterms.dart';
import 'package:yourappname/pages/availability.dart';
import 'package:yourappname/pages/editprofilef.dart';
import 'package:yourappname/pages/loginselect.dart';
import 'package:yourappname/pages/patienthistory.dart';
import 'package:yourappname/pages/profile.dart';
import 'package:yourappname/pages/qrcodescanner.dart';
import 'package:yourappname/pages/seereview.dart';
import 'package:yourappname/pages/select_language_screen.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:iconify_flutter/icons/bx.dart';
import 'package:iconify_flutter/icons/icon_park_twotone.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/pajamas.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

import 'changepassword.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  late GeneralProvider generalProvider;
  SharedPre sharedPref = SharedPre();
  late EditProfileProvider profileProvider;
  late int selectedMenuItemId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ProgressDialog prDialog;
  @override
  void initState() {
    prDialog = ProgressDialog(context);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    profileProvider = Provider.of<EditProfileProvider>(context, listen: false);

    _getData();
    selectedMenuItemId = 0;
    super.initState();
  }

  Future<void> _getData() async {
    profileProvider.getDoctorDetails();

    generalProvider.getPages();
    generalProvider.getSocialLink();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: transparent,
          centerTitle: false,
          automaticallyImplyLeading: false,
          title: MyText(
            text: "menu",
            fontsize: Dimens.text22Size,
            fontstyle: FontStyle.normal,
            multilanguage: true,
            fontweight: FontWeight.w600,
            textalign: TextAlign.center,
            color: colorPrimaryDark,
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Consumer<EditProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (profileProvider.loading) {
                    return const Row(
                      children: [
                        CustomWidget.circular(
                          height: 70,
                          width: 70,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: CustomWidget.roundcorner(
                            height: 28,
                            width: 70,
                          ),
                        ),
                      ],
                    );
                  } else {
                    if (profileProvider.doctorProfileModel.status == 200 &&
                        profileProvider.doctorProfileModel.result != null &&
                        (profileProvider.doctorProfileModel.result?.length ??
                                0) >
                            0) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Profile()));
                          },
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: MyNetworkImage(
                                    imageUrl: profileProvider
                                            .doctorProfileModel.result?[0].image
                                            .toString() ??
                                        "",
                                    imgHeight: 70,
                                    imgWidth: 70,
                                    fit: BoxFit.cover),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: MyText(
                                          text: profileProvider
                                                  .doctorProfileModel
                                                  .result?[0]
                                                  .fullName
                                                  .toString() ??
                                              "",
                                          color: textTitleColor,
                                          fontsize: Dimens.text20Size,
                                          maxline: 2,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          fontweight: FontWeight.w600,
                                          textalign: TextAlign.start,
                                          fontstyle: FontStyle.normal,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      const Iconify(
                                        MaterialSymbols.verified_user,
                                        color: blue,
                                        size: 25,
                                      ),
                                    ],
                                  ),
                                  MyText(
                                    text: profileProvider.doctorProfileModel
                                            .result?[0].specialtiesName ??
                                        "",
                                    color: grayDark,
                                    fontsize: Dimens.text15Size,
                                    maxline: 2,
                                    multilanguage: false,
                                    overflow: TextOverflow.ellipsis,
                                    fontweight: FontWeight.w500,
                                    textalign: TextAlign.start,
                                    fontstyle: FontStyle.normal,
                                  )
                                ],
                              )),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }
                },
              ),
              mySideNavDrawer(),
            ],
          ),
        ));
  }

  Widget mySideNavDrawer() {
    return Consumer<GeneralProvider>(
      builder: (BuildContext context, GeneralProvider generalProvider,
          Widget? child) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 10),
              /* Forgot Passward */
              if (profileProvider.doctorProfileModel.result != null &&
                  profileProvider.doctorProfileModel.result?[0].type
                          .toString() ==
                      "4")
                _buildSettingIcon(
                  iconType: "asset",
                  icon: Icons.lock_outline_rounded,
                  title: "change_password",
                  titleMultilang: true,
                  onClick: () {
                    printLog("Tapped on forgotPassword");

                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ChangePassword(""),
                      ),
                    );
                  },
                ),

              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  printLog("Tapped on scanQRCode");

                  if (Constant.userID == "") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QRCodeScanner(),
                      ),
                    );
                  }
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Iconify(
                            Bx.scan,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "scan_qr_code",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),
              // Patient History
              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  printLog("Tapped on scanQRCode");

                  if (Constant.userID == "") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PatientHistory(),
                      ),
                    );
                  }
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Iconify(
                            IconParkTwotone.prescription,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "patient_history",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),

              // Patient History
              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  printLog("Tapped on scanQRCode");

                  if (Constant.userID == "") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Availability(),
                      ),
                    );
                  }
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Iconify(
                            Pajamas.false_positive,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "available_settings",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),
              //Select Language
              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SelectLanguageScreen(),
                    ),
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.language,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "change_language",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),

              //account Settings
              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute(
                      builder: (context) => const EditProfileF(),
                    ),
                  )
                      .then(
                    (value) {
                      _getData();
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Iconify(
                            Ion.settings_sharp,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "account_settings",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  if (Constant.userID == "") {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SeeReview(
                          doctorId: int.parse(Constant.userID.toString()),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Iconify(
                            Mdi.message_star_outline,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "doctor_recommendation",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),

              // const SizedBox(
              //   height: 20,
              // ),

              /* Pages */
              _buildPages(),
              _buildSocialLink(),

              InkWell(
                borderRadius: BorderRadius.circular(2),
                onTap: () {
                  if (Constant.userID != "") {
                    showMyDialog("2");
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  }
                },
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: Dimens.minHeightSettings,
                  ),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: colorAccent),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.delete_sharp,
                            size: 25,
                            color: colorPrimary,
                          )),
                      const SizedBox(width: 15),
                      Expanded(
                        child: MyText(
                          text: "delete_account",
                          color: textTitleColor,
                          fontsize: Dimens.text16Size,
                          maxline: 2,
                          multilanguage: true,
                          overflow: TextOverflow.ellipsis,
                          fontweight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ),
                      const SizedBox(width: 15),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 25,
                        color: gray,
                      ),
                    ],
                  ),
                ),
              ),

              InkWell(
                onTap: () {
                  if (Constant.userID != "") {
                    showMyDialog("1");
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Loginselect(),
                      ),
                    );
                  }
                },
                child: MyText(
                  text: (Constant.userID == "") ? "login" : "logout",
                  color: colorPrimary,
                  fontsize: Dimens.text17Size,
                  maxline: 2,
                  multilanguage: true,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w600,
                  textalign: TextAlign.start,
                  fontstyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPages() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.pagesModel.status == 200 &&
          generalProvider.pagesModel.result != null &&
          (generalProvider.pagesModel.result?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            itemCount: (generalProvider.pagesModel.result?.length ?? 0),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              return _buildSettingButton(
                iconType: "url",
                iconName:
                    generalProvider.pagesModel.result?[position].icon ?? '',
                title: generalProvider.pagesModel.result?[position].title ?? '',
                titleMultilang: false,
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutPrivacyTerms(
                        appBarTitle: generalProvider
                                .pagesModel.result?[position].title ??
                            '',
                        loadURL:
                            generalProvider.pagesModel.result?[position].url ??
                                '',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSocialLink() {
    if (generalProvider.loading) {
      return const SizedBox.shrink();
    } else {
      if (generalProvider.socialLinkModel.status == 200 &&
          generalProvider.socialLinkModel.result != null &&
          (generalProvider.socialLinkModel.result?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            itemCount: (generalProvider.socialLinkModel.result?.length ?? 0),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int position) {
              return _buildSettingButton(
                iconType: "url",
                iconName:
                    generalProvider.socialLinkModel.result?[position].image ?? '',
                title: generalProvider.socialLinkModel.result?[position].name ?? '',
                titleMultilang: false,
                onClick: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AboutPrivacyTerms(
                        appBarTitle: generalProvider
                                .socialLinkModel.result?[position].name ??
                            '',
                        loadURL:
                            generalProvider.socialLinkModel.result?[position].url ??
                                '',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _buildSettingIcon({
    required String iconType,
    required IconData icon,
    required String title,
    required bool titleMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onClick,
      child: Container(
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: colorAccent),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  icon,
                  size: 25,
                  color: colorPrimary,
                )),
            const SizedBox(width: 15),
            Expanded(
              child: MyText(
                text: title,
                color: textTitleColor,
                fontsize: Dimens.text16Size,
                maxline: 2,
                multilanguage: titleMultilang,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w600,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 25,
              color: gray,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingButton({
    required String iconType,
    required String iconName,
    required String title,
    required bool titleMultilang,
    required Function() onClick,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(2),
      onTap: onClick,
      child: Container(
        constraints: BoxConstraints(
          minHeight: Dimens.minHeightSettings,
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: colorAccent),
              padding: const EdgeInsets.all(8),
              child: MyNetworkImage(
                imageUrl: iconName,
                fit: BoxFit.cover,
                imgHeight: 24,
                imgWidth: 24,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: MyText(
                text: title,
                color: textTitleColor,
                fontsize: Dimens.text16Size,
                maxline: 2,
                multilanguage: titleMultilang,
                overflow: TextOverflow.ellipsis,
                fontweight: FontWeight.w600,
                textalign: TextAlign.start,
                fontstyle: FontStyle.normal,
              ),
            ),
            const SizedBox(width: 15),
            const Icon(
              Icons.arrow_forward_rounded,
              size: 25,
              color: gray,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showMyDialog(type) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(20),
          backgroundColor: white,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                MyText(
                  text: type == "1" ? "logout" : "delete_account",
                  color: black,
                  fontsize: Dimens.text26Size,
                  fontstyle: FontStyle.normal,
                  multilanguage: true,
                  fontweight: FontWeight.w600,
                  textalign: TextAlign.left,
                ),
                const SizedBox(height: 15),
                MyText(
                  text: type == "1"
                      ? "are_you_sure_want_to_logout"
                      : "are_you_sure_want_to_delete_account",
                  multilanguage: true,
                  color: otherColor,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.normal,
                  textalign: TextAlign.start,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: white,
                backgroundColor: white, // foreground
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: MyText(
                  text: "no",
                  multilanguage: true,
                  color: colorPrimary,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.w600,
                  textalign: TextAlign.center,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                foregroundColor: white,
                backgroundColor: white, // foreground
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: MyText(
                  text: "yes",
                  multilanguage: true,
                  color: colorPrimary,
                  fontsize: Dimens.text16Size,
                  fontstyle: FontStyle.normal,
                  fontweight: FontWeight.w600,
                  textalign: TextAlign.center,
                ),
              ),
              onPressed: () async {
                Utils.showProgress(context, prDialog);
                try {
                  Constant.userID = "";
                  // Firebase Signout
                  await _auth.signOut();
                  await GoogleSignIn.instance.signOut();
                  await Utils.setUserId(null);
                  Constant.userID = null;
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  await sharedPref.save("isEdit", "0");
                  await prDialog.hide();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const Loginselect(),
                    ),
                  );
                } catch (e) {
                  await prDialog.hide();
                }
              },
            )
          ],
        );
      },
    );
  }
}
