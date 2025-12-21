import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class ThemeSelectionDialog extends StatefulWidget {
  static String tag = '/ThemeSelectionDialog';

  @override
  ThemeSelectionDialogState createState() => ThemeSelectionDialogState();
}

class ThemeSelectionDialogState extends State<ThemeSelectionDialog> {
  List<String> themeModeList = [locale.lblLight, locale.lblDark, locale.lblSystemDefault];

  int? currentIndex = 0;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    currentIndex = getIntAsync(THEME_MODE_INDEX);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(unselectedWidgetColor: context.primaryColor),
      child: RadioGroup<int>(
        groupValue: currentIndex,
        onChanged: (dynamic val) {
          if (val != null) {
            setState(() {
              currentIndex = val;

              if (val == THEME_MODE_SYSTEM) {
                appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.dark);
              } else if (val == THEME_MODE_LIGHT) {
                appStore.setDarkMode(false);
              } else if (val == THEME_MODE_DARK) {
                appStore.setDarkMode(true);
              }

              setValue(THEME_MODE_INDEX, val);
            });

            finish(context);
          }
        },
        child: Column(
          children: List.generate(themeModeList.length, (index) {
            return RadioListTile<int>(
              value: index,
              dense: true,
              title: Text(themeModeList[index], style: primaryTextStyle()),
              fillColor: WidgetStatePropertyAll(appPrimaryColor),
            );
          }),
        ),
      ),
    );
  }
}
