import 'package:flutter/material.dart';

Future<dynamic> navigateToPage(
    {required context, required Widget route}) async {
  var result = await Navigator.push(
      context, MaterialPageRoute(builder: (context) => route));
  return result;
}

Future<dynamic> navigateToPageRemoveAllPage(
    {required context, required Widget route}) async {
  var result = await Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => route),
    (route) => true,
  );
  return result;
}
