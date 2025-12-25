import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';

class FileViewerProvider with ChangeNotifier {
  String? urlExtension;

  Future<void> startLoadingFile(String fileUrl) async {
    urlExtension = fileUrl.split('.').last.toLowerCase();
    printLog("Extension provider :- $urlExtension");
  }
}
