import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/rating_model.dart';
import 'package:kivicare_flutter/network/review_repository.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/component/review_widget.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/review_rating_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

class RatingViewAllScreen extends StatefulWidget {
  final int userId; // doctorId or patientId
  final bool? isDoctor; // true -> doctor reviews, false -> patient reviews

  RatingViewAllScreen({required this.userId, required this.isDoctor});

  @override
  State<RatingViewAllScreen> createState() => _RatingViewAllScreenState();
}

class _RatingViewAllScreenState extends State<RatingViewAllScreen> {
  Future<List<RatingData>>? future;
  int page = 1;
  bool isLastPage = false;
  List<RatingData> ratingList = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) appStore.setLoading(true);

    future = (widget.isDoctor.validate()
            ? doctorReviewsListAPI(
                ratingList: ratingList,
                doctorId: widget.userId.validate(),
                page: page,
                lastPageCallback: (b) => isLastPage = b,
              )
            : patientReviewsListAPI(
                ratingList: ratingList,
                patientId: widget.userId.validate(),
                page: page,
                lastPageCallback: (b) => isLastPage = b,
              ))
        .then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  void deleteReview(int reviewId) async {
    showConfirmDialogCustom(
      context,
      title: locale.lblDoYouWantToDeleteReview,
      positiveText: locale.lblDelete,
      negativeText: locale.lblCancel,
      dialogType: DialogType.DELETE,
      onAccept: (c) async {
        appStore.setLoading(true);
        await deleteReviewAPI(id: reviewId).then((value) {
          toast(value.message);

          setState(() {
            ratingList.removeWhere((element) => element.id == reviewId);

            future = Future.value(ratingList);
          });
        }).catchError((e) {
          toast(e.toString());
        }).whenComplete(() => appStore.setLoading(false));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblRatingsAndReviews,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: InternetConnectivityWidget(
        retryCallback: () => init(),
        child: Stack(
          children: [
            SnapHelperWidget<List<RatingData>>(
              future: future,
              loadingWidget: ReviewRatingShimmerScreen(),
              onSuccess: (data) {
                ratingList = data;
                if (ratingList.isEmpty) {
                  return NoDataFoundWidget(text: locale.lblNoReviewsFound).center();
                }
                return AnimatedListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(16),
                  itemCount: data.length,
                  onSwipeRefresh: () async {
                    page = 1;
                    init(showLoader: true);
                    return await 1.seconds.delay;
                  },
                  onNextPage: () async {
                    setState(() => page++);
                    init(showLoader: true);
                    await 1.seconds.delay;
                  },
                  itemBuilder: (context, index) {
                    return ReviewWidget(
                      data: data[index],
                      isDoctor: widget.isDoctor!,
                      callDelete: () => deleteReview(data[index].id.validate()),
                      callUpdate: (updatedData) {
                        setState(() {
                          data[index] = updatedData;
                        });
                      },
                      addMargin: false,
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: boxDecorationDefault(color: context.cardColor),
                    );
                  },
                );
              },
            ).paddingTop(8),
            Observer(
              builder: (_) => LoaderWidget().center().visible(appStore.isLoading),
            ),
          ],
        ),
      ),
    );
  }
}
