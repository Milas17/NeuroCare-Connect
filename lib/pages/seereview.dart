import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/feedbackprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SeeReview extends StatefulWidget {
  final int? doctorId;
  const SeeReview({
    required this.doctorId,
    super.key,
  });

  @override
  State<SeeReview> createState() => _SeeReviewState();
}

class _SeeReviewState extends State<SeeReview> {
  late FeedbackProvider feedbackProvider;
  late ScrollController _scrollController;

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (feedbackProvider.currentPage ?? 0) <
            (feedbackProvider.totalPage ?? 0)) {
      await feedbackProvider.setLoadMore(true);
      await _getData((feedbackProvider.currentPage ?? 0));
    }
  }

  @override
  void initState() {
    feedbackProvider = Provider.of<FeedbackProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
    _getData(0);
  }

  _getData(pageNo) async {
    await feedbackProvider.getReviewList((pageNo + 1).toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar:
          Utils.myAppBarWithBack(context, "doctor_recommendation", true, true),
      body: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          child: Consumer<FeedbackProvider>(
              builder: (context, feedbackProvider, child) {
            return _buildPage();
          })),
    );
  }

  Widget _buildPage() {
    if (feedbackProvider.loading) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: reviewShimmer(),
      );
    }
    if (feedbackProvider.reviewListModel.result == null ||
        (feedbackProvider.reviewList?.length ?? 0) == 0) {
      return const NoData(text: 'not_data_found');
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: MyText(
            text: "reviewtitle",
            multilanguage: true,
            fontsize: Dimens.text30Size,
            color: colorPrimaryDark,
            fontweight: FontWeight.w600,
            textalign: TextAlign.start,
            fontstyle: FontStyle.normal,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(height: 20),
        AlignedGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 1,
          padding: const EdgeInsets.all(20),
          mainAxisSpacing: 25,
          itemCount: feedbackProvider.reviewList?.length ?? 0,
          itemBuilder: (BuildContext context, int position) => Card(
            color: white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: MyNetworkImage(
                              imageUrl: feedbackProvider
                                      .reviewList?[position].patientsImg ??
                                  "",
                              fit: BoxFit.cover,
                              imgHeight: 65,
                              imgWidth: 65,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      RatingBar(
                        initialRating: double.parse(feedbackProvider
                                .reviewList?[position].rating
                                .toString() ??
                            "0"),
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        ignoreGestures: true,
                        itemCount: 5,
                        itemSize: 25,
                        ratingWidget: RatingWidget(
                          full: const Icon(
                            Icons.star,
                            color: colorPrimary,
                            size: 30,
                          ),
                          half: const Icon(
                            Icons.star,
                            color: gray,
                            size: 30,
                          ),
                          empty: const Icon(
                            Icons.star_border_outlined,
                            color: gray,
                            size: 30,
                          ),
                        ),
                        itemPadding: const EdgeInsets.symmetric(horizontal: 2),
                        onRatingUpdate: (rating) {
                          printLog('$rating');
                        },
                      ),
                      const SizedBox(width: 10),
                      MyText(
                        // text: feedbackProvider.reviewList?[position].avgRating
                        //         .toString() ??
                        //     "",
                        text: feedbackProvider.reviewList?[position].rating
                                .toString() ??
                            "",
                        fontsize: Dimens.text15Size,
                        color: black,
                        fontweight: FontWeight.w700,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: feedbackProvider.reviewList?[position].patientName ??
                        "",
                    fontsize: Dimens.text16Size,
                    color: black,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  MyText(
                    text: feedbackProvider.reviewList?[position].review ?? "",
                    fontsize: Dimens.text14Size,
                    fontweight: FontWeight.w600,
                    textalign: TextAlign.start,
                    fontstyle: FontStyle.normal,
                    maxline: 15,
                    overflow: TextOverflow.ellipsis,
                    color: otherColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        Consumer<FeedbackProvider>(
          builder: (context, feedbackProvider, child) {
            if (feedbackProvider.loadmore) {
              return Utils.pageLoader();
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }

  Widget reviewShimmer() {
    return AlignedGridView.count(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 1,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 25,
      itemCount: 10,
      itemBuilder: (BuildContext context, int position) => Card(
        color: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: CustomWidget.roundcorner(
                        height: 65,
                        width: 65,
                        shapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CustomWidget.roundcorner(
                    height: 25,
                    width: 100,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  const SizedBox(width: 10),
                  CustomWidget.roundcorner(
                    height: 15,
                    width: 65,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              CustomWidget.roundcorner(
                height: 15,
                width: MediaQuery.of(context).size.width,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 10),
              CustomWidget.roundcorner(
                height: 15,
                width: MediaQuery.of(context).size.width,
                shapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
