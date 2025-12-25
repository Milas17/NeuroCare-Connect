import 'package:yourappname/model/getreviewlistmodel.dart' as review;
import 'package:yourappname/model/getreviewlistmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservices.dart';
import 'package:flutter/material.dart';

class FeedbackProvider extends ChangeNotifier {
  GetReviewListModel reviewListModel = GetReviewListModel();
  bool loadmore = false;
  bool loading = false;
  int? totalRows, totalPage, currentPage;
  bool isMorePage = false;
  List<review.Result>? reviewList = [];

  Future<void> getReviewList(pageNo) async {
    loading = true;
    printLog("reviewListModel userId :===> ${Constant.userID}");
    reviewListModel = await ApiService().reviewList(Constant.userID, pageNo);
    if (reviewListModel.status == 200) {
      setReviewPaginationData(
          reviewListModel.totalRows,
          reviewListModel.totalPage,
          reviewListModel.currentPage,
          reviewListModel.morePage);
      if (reviewListModel.result != null &&
          (reviewListModel.result?.length ?? 0) > 0) {
        if (reviewListModel.result != null &&
            (reviewListModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (reviewListModel.result?.length ?? 0); i++) {
            reviewList?.add(reviewListModel.result?[i] ?? review.Result());
          }
          final Map<int, review.Result> postMap = {};
          reviewList?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          reviewList = postMap.values.toList();
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  setReviewPaginationData(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage!;

    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  clearProvider() {
    totalPage = 0;
    currentPage = 0;
    reviewList = [];
    reviewListModel = GetReviewListModel();
    loading = false;
  }
}
