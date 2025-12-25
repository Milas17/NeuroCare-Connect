import 'dart:convert';

import 'package:flutter/material.dart';

import '../model/getreviewlistmodel.dart';
import '../utils/utils.dart';
import '../webservice/apiservices.dart';

class CommentProvider extends ChangeNotifier {
  GetReviewListModel replyCommentsListModel = GetReviewListModel();
  bool replyCmtLoading = false;

  Future<void> getReplyComent(commentId) async {
    replyCmtLoading = true;
    replyCommentsListModel = await ApiService().replycomment(commentId);
    printLog(
        "replyCommentsListModel status :===> ${replyCommentsListModel.status}");
    printLog(
        "replyCommentsListModel message :==> ${replyCommentsListModel.message}");
    printLog(
        "replyCommentsListModel result :==> ${jsonEncode(replyCommentsListModel.result)}");
    replyCmtLoading = false;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    replyCmtLoading = isLoading;
  }
}
