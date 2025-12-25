import 'package:yourappname/pages/editprofilef.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';

import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  late EditProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<EditProfileProvider>(context, listen: false);
    getData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  getData() async {
    await profileProvider.getDoctorDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorPrimaryDark,
      appBar: myAppBar(),
      body: SizedBox(
        child: Consumer<EditProfileProvider>(
          builder: (context, profileProvider, child) {
            if (profileProvider.loading) {
              return profileShimmer();
            } else {
              if (profileProvider.doctorProfileModel.status == 200 &&
                  (profileProvider.doctorProfileModel.result?.length ?? 0) >
                      0) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(50)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        clipBehavior: Clip.antiAlias,
                        child: MyNetworkImage(
                          imageUrl: (profileProvider
                                  .doctorProfileModel.result?[0].image ??
                              Constant.userPlaceholder),
                          fit: BoxFit.cover,
                          imgHeight: 80,
                          imgWidth: 80,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    MyText(
                      text: ((profileProvider
                                      .doctorProfileModel.result?[0].fullName
                                      .toString() ??
                                  "")
                              .contains("null"))
                          ? ("Guest User")
                          : (profileProvider
                                  .doctorProfileModel.result?[0].fullName ??
                              ""),
                      fontsize: Dimens.text17Size,
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      fontweight: FontWeight.w700,
                      fontstyle: FontStyle.normal,
                      textalign: TextAlign.start,
                      color: white,
                    ),
                    const SizedBox(height: 18),
                    Expanded(
                      child: Container(
                        decoration: Utils.topRoundBG(),
                        child: buildProfileTabs(),
                      ),
                    ),
                  ],
                );
              } else {
                return const NoData(text: '');
              }
            }
          },
        ),
      ),
    );
  }

  AppBar myAppBar() {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: transparent,
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
              color: colorAccent, borderRadius: BorderRadius.circular(8)),
          child: const Icon(
            Icons.arrow_back_rounded,
            size: 25,
            color: black,
          ),
        ),
      ),
      title: MyText(
        text: "profile",
        multilanguage: true,
        fontsize: Dimens.text24Size,
        fontstyle: FontStyle.normal,
        fontweight: FontWeight.w600,
        textalign: TextAlign.center,
        color: white,
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            printLog('EditProfile pressed!');
            Navigator.of(context)
                .push(MaterialPageRoute(
                    builder: (context) => const EditProfileF()))
                .then((value) => profileProvider.getDoctorDetails());
          },
          icon: const Iconify(
            Mdi.square_edit_outline,
            size: 30,
            color: white,
          ),
        ),
      ],
    );
  }

  Widget buildProfileTabs() {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Card(
              color: white,
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: TabBar(
                  isScrollable: false,
                  labelColor: white,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: colorAccent,
                  dividerColor: transparent,
                  indicatorWeight: 1,
                  labelPadding: const EdgeInsets.only(top: 0, bottom: 0),
                  indicatorPadding: const EdgeInsets.all(0),
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                          colors: [colorPrimaryDark, colorPrimaryDark],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          tileMode: TileMode.mirror)),
                  unselectedLabelColor: otherColor,
                  tabs: <Widget>[
                    Tab(
                      child: MyText(
                        text: "personal",
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
                        text: "degree",
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
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                personalDetailTab(),
                degreeDetailTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget personalDetailTab() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            MyText(
              text: "name",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              elevation: 1,
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: ((profileProvider.doctorProfileModel.result?[0].fullName
                                  .toString() ??
                              "")
                          .contains("null"))
                      ? ("Guest User")
                      : (profileProvider
                              .doctorProfileModel.result?[0].fullName ??
                          ""),
                  fontsize: Dimens.text16Size,
                  fontweight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "contact_no",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider
                                  .doctorProfileModel.result?[0].mobileNumber ??
                              "")
                          .isNotEmpty
                      ? (profileProvider
                              .doctorProfileModel.result?[0].mobileNumber ??
                          "")
                      : "-",
                  fontsize: Dimens.text16Size,
                  fontweight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "email_address",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider.doctorProfileModel.result?[0].email ??
                              "")
                          .isNotEmpty
                      ? (profileProvider.doctorProfileModel.result?[0].email ??
                          "-")
                      : "-",
                  multilanguage: false,
                  fontsize: Dimens.text16Size,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "address",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider.doctorProfileModel.result?[0].bio ??
                              "")
                          .isNotEmpty
                      ? (profileProvider.doctorProfileModel.result?[0].bio ??
                          "-")
                      : "-",
                  multilanguage: false,
                  fontsize: Dimens.text16Size,
                  maxline: 5,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "birth_date",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider
                                  .doctorProfileModel.result?[0].dateOfBirth ??
                              "")
                          .isNotEmpty
                      ? (profileProvider
                              .doctorProfileModel.result?[0].dateOfBirth ??
                          "-")
                      : "-",
                  multilanguage: false,
                  fontsize: Dimens.text16Size,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w400,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget degreeDetailTab() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: "speciality",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider.doctorProfileModel.result?[0]
                                  .specialtiesName ??
                              "")
                          .isNotEmpty
                      ? (profileProvider
                              .doctorProfileModel.result?[0].specialtiesName ??
                          "-")
                      : "-",
                  fontsize: Dimens.text14Size,
                  maxline: 5,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "practicing_tenure",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider.doctorProfileModel.result?[0]
                                  .practicingTenure ??
                              "")
                          .isNotEmpty
                      ? (profileProvider
                              .doctorProfileModel.result?[0].practicingTenure ??
                          "-")
                      : "-",
                  fontsize: Dimens.text14Size,
                  maxline: 5,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
            MyText(
              text: "specialization",
              multilanguage: true,
              fontsize: Dimens.text14Size,
              fontweight: FontWeight.w400,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              color: black.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 4),
            Card(
              color: white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                width: MediaQuery.of(context).size.width,
                child: MyText(
                  text: (profileProvider.doctorProfileModel.result?[0]
                                  .specialtiesName ??
                              "")
                          .isNotEmpty
                      ? (profileProvider
                              .doctorProfileModel.result?[0].specialtiesName ??
                          "-")
                      : "-",
                  fontsize: Dimens.text14Size,
                  maxline: 5,
                  overflow: TextOverflow.ellipsis,
                  fontweight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                  textalign: TextAlign.start,
                  color: textTitleColor,
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget profileShimmer() {
    return Column(
      children: [
        Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                color: white, borderRadius: BorderRadius.circular(50)),
            child: const CustomWidget.circular(
              height: 80,
              width: 80,
            )),
        const SizedBox(height: 6),
        const CustomWidget.roundcorner(
          height: 15,
          width: 100,
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: Utils.topRoundBG(),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomWidget.roundcorner(
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          height: 40,
                          width: 65,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: CustomWidget.roundcorner(
                          shapeBorder: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          height: 40,
                          width: 65,
                        ),
                      ),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}
