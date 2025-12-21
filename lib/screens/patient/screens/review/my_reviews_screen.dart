import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class MyReviewsScreen extends StatefulWidget {
  final VoidCallback? callback;
  final bool? isForRegistration;
  final int? clinicId;

  MyReviewsScreen({this.callback, this.isForRegistration, this.clinicId});
  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  Future<List<UpcomingAppointmentModel>>? future;

  int page = 1;
  bool isLastPage = false;

  List<UpcomingAppointmentModel> appointmentList = [];

  @override
  void initState() {
    super.initState();

    /// load cached appointments first
    String res = getStringAsync(SharedPreferenceKey.cachedAppointmentListKey);
    if (res.isNotEmpty) {
      appointmentList = (jsonDecode(res) as List).map((e) => UpcomingAppointmentModel.fromJson(e)).toList();
    }

    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);

    future = getPatientAppointmentList(
      userStore.userId.validate(),
      appointmentList: appointmentList,
      status: "All",
      page: page,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) async {
      /// save cache
      await setValue(SharedPreferenceKey.cachedAppointmentListKey, jsonEncode(value));
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  Future<void> _onSwipeRefresh() async {
    setState(() => page = 1);
    init(showLoader: true);
    return await 800.milliseconds.delay;
  }

  Future<void> _onNextPage() async {
    if (!isLastPage) {
      setState(() => page++);
      init(showLoader: true);
      await 1.seconds.delay;
    }
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblReview,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: InternetConnectivityWidget(
        retryCallback: () {
          init(showLoader: true);
        },
        child: Stack(
          children: [
            SnapHelperWidget<List<UpcomingAppointmentModel>>(
              future: future,
              initialData: appointmentList, // cached data first
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: error.toString(),
                  onRetry: () {
                    init(showLoader: true);
                  },
                );
              },
              loadingWidget: LoaderWidget(),
              onSuccess: (data) {
                /// filter only appointments having reviews
                List<UpcomingAppointmentModel> reviewData = data.where((e) => e.doctorRating != null).toList();

                return AnimatedListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  itemCount: reviewData.length,
                  onSwipeRefresh: _onSwipeRefresh,
                  onNextPage: _onNextPage,
                  listAnimationType: listAnimationType,
                  slideConfiguration: SlideConfiguration(verticalOffset: 300),
                  itemBuilder: (context, index) {
                    UpcomingAppointmentModel appt = reviewData[index];

                    return Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: boxDecorationWithRoundedCorners(
                        backgroundColor: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Doctor name
                          Text(appt.doctorName.validate(), style: boldTextStyle(size: 16)),

                          4.height,

                          /// Show appointment ID
                          Text('ID: ${appt.id.validate()}', style: secondaryTextStyle()),

                          /// Show appointment date
                          Text(
                            'Date: ${appt.appointmentEndDate != null ? appt.appointmentEndDate! : ''}',
                            style: secondaryTextStyle(),
                          ),

                          Text(
                            'Date: ${appt.appointmentEndTime != null ? appt.appointmentEndTime : ''}',
                            style: secondaryTextStyle(),
                          ),

                          8.height,

                          /// Rating stars
                          if (appt.doctorRating?.rating != null)
                            RatingBarWidget(
                              rating: appt.doctorRating!.rating!.toDouble(),
                              size: 16,
                              activeColor: Colors.amber,
                              onRatingChanged: (r) {},
                            ),

                          8.height,

                          /// Review text
                          Text(appt.doctorRating?.reviewDescription.validate() ?? ''),
                        ],
                      ),
                    );
                  },
                ).visible(
                  reviewData.isNotEmpty,
                  defaultWidget: NoDataFoundWidget(
                    text: locale.lblNoReviewsFound,
                  ).center(),
                );
              },
            ).paddingTop(8),
            Observer(
              builder: (context) => LoaderWidget().center().visible(appStore.isLoading),
            ),
          ],
        ),
      ),
    );
  }
}
