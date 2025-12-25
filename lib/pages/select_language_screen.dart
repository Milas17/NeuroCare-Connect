import 'package:yourappname/utils/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import '../utils/colors.dart';
import '../utils/dimens.dart';
import '../utils/sharedpre.dart';
import '../utils/utils.dart';
import '../widgets/mytext.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  String selectedLanguage = "";
  SharedPre sharedPre = SharedPre();
  List<LanguageModel> languageData = [];

  ValueNotifier<bool> refreshList = ValueNotifier(false);
  @override
  void initState() {
    languageData = [
      LanguageModel(languageName: "Arabic", languageCode: "ar"),
      LanguageModel(languageName: "English", languageCode: "en"),
      LanguageModel(languageName: "Hindi", languageCode: "hi")
    ];
    init();
    super.initState();
  }

  init() async {
    selectedLanguage = await sharedPre.read("language_code") ?? "";
    if (selectedLanguage == "") {
      selectedLanguage = "en";
    }
    refreshList.value = !refreshList.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: white,
        appBar: Utils.myAppBarWithBack(context, 'change_language', true, true),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(15.0),
          child: AppBottomCommonButton(
            btnTitle: "save",
            onBtnTap: () async {
              await SharedPre().save("language_code", selectedLanguage);
              if (!context.mounted) return;
              Locales.change(context, selectedLanguage);
              Navigator.of(context).pop();
            },
          ),
        ),
        body: mainBody());
  }

  Widget mainBody() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          MyText(
            text: 'select_your_preferred_language',
            fontweight: FontWeight.w400,
            fontsize: Dimens.text18Size,
            color: black,
            type: 9,
            multilanguage: true,
          ),
          verticalSpace(5),
          MyText(
            text: 'choose_your_preferred_language',
            fontweight: FontWeight.w500,
            fontsize: Dimens.text18Size,
            color: lightGrey,
            textalign: TextAlign.start,
            type: 9,
            multilanguage: true,
          ),
          verticalSpace(15),
          Expanded(child: languageList())
        ],
      ),
    );
  }

  Widget languageList() {
    return ValueListenableBuilder(
      valueListenable: refreshList,
      builder: (context, value, child) => ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                selectedLanguage = languageData[index].languageCode;
                refreshList.value = !refreshList.value;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedLanguage == languageData[index].languageCode
                        ? colorPrimary
                        : colorAccent.withValues(alpha: 0.5)),
                child: Center(
                  child: MyText(
                    text: languageData[index].languageName,
                    fontsize: Dimens.text16Size,
                    fontweight: FontWeight.w500,
                    type: 1,
                    color: selectedLanguage == languageData[index].languageCode
                        ? white
                        : black,
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) => verticalSpace(16),
          itemCount: languageData.length),
    );
  }

  Widget verticalSpace(double height) {
    return SizedBox(
      height: height,
    );
  }
}

class LanguageModel {
  final String languageName;
  final String languageCode;

  LanguageModel({required this.languageCode, required this.languageName});
}
