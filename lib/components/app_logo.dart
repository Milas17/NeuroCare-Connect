import 'package:flutter/material.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/utils/images.dart';

class AppLogo extends StatelessWidget {
  final double? size;

  AppLogo({this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(appLogo, height: size ?? 80).center(),
        12.height,
      ],
    );
  }
}
