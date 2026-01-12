import 'package:yourappname/model/workingtimeslotmodel.dart';
import 'package:yourappname/pages/addworkslot.dart';
import 'package:yourappname/provider/editprofileprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Availability extends StatefulWidget {
  const Availability({super.key});

  @override
  State<Availability> createState() => _AvailabilityState();
}

class _AvailabilityState extends State<Availability>
    with SingleTickerProviderStateMixin {
  List<String> weekDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  TabController? _controller;
  List<bool> switchStates = List.generate(7, (index) => false);
  SharedPre sharedPref = SharedPre();
  int selectedIndex = 0;

  String currentUserFId = "";
  late EditProfileProvider editProfileProvider;

  @override
  void initState() {
    editProfileProvider =
        Provider.of<EditProfileProvider>(context, listen: false);
    controllerEvent();

    editProfileProvider.getTimeSlotByDoctorId(Constant.userID);
    _getData();
    super.initState();
  }

  @override
  void dispose() {
    editProfileProvider.clearAvailability();
    _controller!.dispose();
    super.dispose();
  }

  controllerEvent() {
    _controller = TabController(length: 2, vsync: this, initialIndex: 0);
    _controller!.addListener(() {
      selectedIndex = _controller!.index;
      printLog("Selected Index: ${_controller!.index}");
    });
  }

  _getData() async {
    currentUserFId = await sharedPref.read("firebaseid");
    printLog("firebaseid ==> $currentUserFId");
  }

  void handleSwitchOff(int weekPos) {
    printLog("Switch turned off for week position: $weekPos");
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EditProfileProvider>(
        builder: (context, editProfileProvider, child) {
      return Scaffold(
        backgroundColor: white,
        resizeToAvoidBottomInset: false,
        appBar:
            Utils.myAppBarWithBack(context, "available_settings", true, true),
        body: Column(
          children: [_buildTabItem(), Expanded(child: _buildTabData())],
        ),
      );
    });
  }

  Widget _buildTabData() {
    return TabBarView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        children: [
          workHourEditPage(),
          alwaysAvailable(),
        ]);
  }

  Widget _buildTabItem() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: TabBar(
              labelPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              controller: _controller,
              indicatorColor: colorPrimary,
              dividerColor: transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: false,
              indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                      colors: [colorAccent, colorAccent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.mirror)),
              tabs: [
                Tab(
                  child: LocaleText("specific_hours",
                      style: GoogleFonts.roboto(
                          color:
                              _controller?.index == 0 ? colorPrimary : grayDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ),
                Tab(
                  child: LocaleText("always_available",
                      style: GoogleFonts.roboto(
                          color:
                              _controller?.index == 1 ? colorPrimary : grayDark,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ),
              ]),
        ),
      ),
    );
  }

  // ====== Working Hours layout START ====== //
  Widget workHourEditPage() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            alignment: Alignment.topLeft,
            decoration: BoxDecoration(
                color: lightBlue, borderRadius: BorderRadius.circular(10)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: tabDefaultColor,
                  size: 25,
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: MyText(
                    text: "set_your_availability_note",
                    fontsize: Dimens.text15Size,
                    overflow: TextOverflow.ellipsis,
                    maxline: 2,
                    multilanguage: true,
                    fontweight: FontWeight.w500,
                    textalign: TextAlign.start,
                    color: tabDefaultColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Consumer<EditProfileProvider>(
            builder: (BuildContext context,
                EditProfileProvider editProfileProvider, Widget? child) {
              if (editProfileProvider.loading) {
                return const Center(child: CircularProgressIndicator());
              } else {
                // if ((editProfileProvider.timeSlotModel.result?.length ?? 0) >
                //         0 &&
                //     editProfileProvider.timeSlotModel.status == 200 &&
                //     editProfileProvider.timeSlotModel.result != null) {
                return ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: 7,
                  itemBuilder: (BuildContext context, int weekPos) {
                    return buildWorkSlots(weekPos);
                  },
                );
                // } else {
                //   return const NoData(text: "");
                // }
              }
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
    final editProfileProvider = Provider.of<EditProfileProvider>(context);
    List<TimeSlote> slots =
        editProfileProvider.weekSlots[weekDays[weekPos]] ?? [];
    DateTime? slotDate = editProfileProvider.weekDates[weekDays[weekPos]];

    // Format the date nicely
    String formattedDate = slotDate != null
        ? Utils.formatDates(slotDate, "EEE, dd MMM yyyy") // or use DateFormat
        : "";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: grayDark,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Day Title with Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: weekDays[weekPos],
                fontsize: Dimens.text16Size,
                fontweight: FontWeight.bold,
                color: black,
              ),
              if (formattedDate.isNotEmpty)
                MyText(
                  text: formattedDate,
                  fontsize: Dimens.text14Size,
                  color: gray,
                  fontweight: FontWeight.w400,
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 🔹 Slots
          if (slots.isNotEmpty)
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: slots.length,
              itemBuilder: (BuildContext context, int timePos) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(width: 0.5, color: black),
                          ),
                          child: MyText(
                            text: Utils.formateTimes(
                                slots[timePos].startTime ?? ""),
                            fontsize: Dimens.text15Size,
                            color: black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      MyText(
                        text: "to",
                        fontsize: Dimens.text16Size,
                        multilanguage: true,
                        color: black,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(width: 0.5, color: black),
                          ),
                          child: MyText(
                            text:
                                Utils.formateTime(slots[timePos].endTime ?? ""),
                            fontsize: Dimens.text15Size,
                            color: black,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

          // 🔹 Add More Hours
          InkWell(
            onTap: () {
              Navigator.of(context)
                  .push(
                MaterialPageRoute(
                  builder: (context) => AddWorkSlot(
                    "${weekPos + 1}",
                    weekPos,
                    slotDate.toString(),
                  ),
                ),
              )
                  .then((result) async {
                // if (result == true) {
                await editProfileProvider.clearAvailability();
                await editProfileProvider
                    .getTimeSlotByDoctorId(Constant.userID);
                if (mounted) setState(() {});
                // }
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 20, color: colorPrimary),
                  const SizedBox(width: 8),
                  MyText(
                    text: "addmorehours",
                    multilanguage: true,
                    fontsize: Dimens.text15Size,
                    color: colorPrimary,
                    fontweight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget alwaysAvailable() {
    return Column(
      children: [
        Container(
          // height: 200,
          margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
              color: lightBlue, borderRadius: BorderRadius.circular(10)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: tabDefaultColor,
                size: 25,
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: MyText(
                  text: "set_your_always_availability_note",
                  fontsize: Dimens.text15Size,
                  overflow: TextOverflow.ellipsis,
                  maxline: 3,
                  multilanguage: true,
                  fontweight: FontWeight.w500,
                  textalign: TextAlign.start,
                  color: tabDefaultColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
