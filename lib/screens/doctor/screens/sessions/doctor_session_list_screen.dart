import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/doctor_session_model.dart';
import 'package:kivicare_flutter/network/doctor_sessions_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/sessions/add_session_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/sessions/components/session_widget.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/session_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants/sharedpreference_constants.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorSessionListScreen extends StatefulWidget {
  @override
  _DoctorSessionListScreenState createState() => _DoctorSessionListScreenState();
}

class _DoctorSessionListScreenState extends State<DoctorSessionListScreen> {
  Future<List<SessionData>>? future;

  List<SessionData> sessionList = [];

  int page = 1;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init(showLoader: false);
  }

  Future<void> init({bool showLoader = true}) async {
    appStore.setLoading(showLoader);

    future = getDoctorSessionDataAPI(
      clinicId: isReceptionist() ? userStore.userClinicId.validate() : '',
      page: page,
      sessionList: sessionList,
      lastPageCallback: (b) => isLastPage = b,
    ).then((value) {
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    getDisposeStatusBarColor();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Scaffold(
        appBar: appBarWidget(isReceptionist() ? locale.lblDoctorSessions : locale.lblSessions, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context)),
        body: InternetConnectivityWidget(
          retryCallback: () {
            setState(() {});
          },
          child: Stack(
            children: [
              SnapHelperWidget(
                future: future,
                loadingWidget: SessionShimmerScreen(),
                errorWidget: ErrorStateWidget(),
                onSuccess: (data) {
                  if (sessionList.validate().isEmpty)
                    return NoDataFoundWidget(
                      text: locale.lblNoSessionAvailable,
                      onRetry: () {
                        page = 1;
                        init();
                      },
                    ).center();
                  return AnimatedScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                    disposeScrollController: true,
                    listAnimationType: listAnimationType,
                    physics: AlwaysScrollableScrollPhysics(),
                    slideConfiguration: SlideConfiguration(verticalOffset: 400),
                    onSwipeRefresh: () async {
                      page = 1;
                      init();
                      return await 2.seconds.delay;
                    },
                    onNextPage: () async {
                      if (!isLastPage) {
                        setState(() {
                          page++;
                        });
                        init();
                        await 1.seconds.delay;
                      }
                    },
                    children: [
                      if (isVisible(SharedPreferenceKey.kiviCareDoctorSessionEditKey) || isVisible(SharedPreferenceKey.kiviCareDoctorSessionDeleteKey))
                        Text('${locale.lblNote} : ${locale.lblSwipeLeftToEdit}', style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                      8.height,
                      ...sessionList
                          .validate()
                          .map<Widget>(
                            (sessionData) => SessionWidget(
                              data: sessionData,
                              callForRefresh: () {
                                init(showLoader: true);
                              },
                            ).paddingSymmetric(vertical: 8),
                          )
                          .toList()
                    ],
                  );
                },
              ),
              LoaderWidget().center().visible(appStore.isLoading)
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            if (appStore.isConnectedToInternet) {
              await AddSessionsScreen().launch(context, pageRouteAnimation: pageAnimation, duration: pageAnimationDuration).then((value) {
                if (value != null) {
                  if (value ?? false) {
                    init();
                  }
                }
              });
            } else {
              toast(locale.lblNoInternetMsg);
            }
          },
        ).visible(isVisible(SharedPreferenceKey.kiviCareDoctorSessionAddKey)),
      );
    });
  }
}
