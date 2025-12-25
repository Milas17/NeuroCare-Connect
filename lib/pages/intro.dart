import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/loginselect.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yourappname/model/onboardingmodel.dart';

class Intro extends StatefulWidget {
  final List<Result>? introList;
  const Intro({super.key, required this.introList});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  PageController pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);
  int pos = 0;
  SharedPre sharedPre = SharedPre();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: intoPageview(),
    );
  }

  Widget intoPageview() {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          alignment: Alignment.center,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          "assets/images/intro_bg.png",
                        ),
                        fit: BoxFit.fill,
                      ),
                      shape: BoxShape.rectangle,
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Container(),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          child: SmoothPageIndicator(
                            controller: pageController,
                            count: widget.introList?.length ?? 0,
                            axisDirection: Axis.horizontal,
                            effect: WormEffect(
                              spacing: 5,
                              radius: 10,
                              dotWidth: 9,
                              dotHeight: 9,
                              dotColor: gray,
                              activeDotColor: black.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        PageView.builder(
          itemCount: widget.introList?.length,
          controller: pageController,
          scrollDirection: Axis.horizontal,
          itemBuilder: (BuildContext context, int index) {
            return SafeArea(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: MyNetworkImage(
                          imgWidth: MediaQuery.of(context).size.width,
                          imgHeight: MediaQuery.of(context).size.height,
                          imageUrl:
                              widget.introList?[index].image.toString() ?? "",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.fromLTRB(25, 40, 25, 10),
                        child: Column(
                          children: [
                            MyText(
                              type: 1,
                              color: black,
                              maxline: 4,
                              overflow: TextOverflow.ellipsis,
                              text: widget.introList?[index].title.toString() ??
                                  "",
                              multilanguage: false,
                              textalign: TextAlign.center,
                              fontsize: Dimens.text30Size,
                              fontweight: FontWeight.w600,
                              fontstyle: FontStyle.normal,
                            ),
                            const SizedBox(height: 15),
                            MyText(
                              type: 1,
                              color: gray,
                              maxline: 4,
                              text: widget.introList?[index].description
                                      .toString() ??
                                  "",
                              multilanguage: false,
                              textalign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              fontsize: Dimens.text14Size,
                              fontweight: FontWeight.w500,
                              fontstyle: FontStyle.normal,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          onPageChanged: (index) {
            pos = index;
            currentPageNotifier.value = index;
            printLog("pos:$pos");
            setState(() {});
          },
        ),
        Positioned(
          bottom: 20,
          right: 15,
          child: InkWell(
            onTap: () {
              if (pos == (widget.introList?.length ?? 0) - 1) {
                Utils.setFirstTime();
                if (Constant.userID != "") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const BottomBar();
                      },
                    ),
                  );
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const Loginselect();
                      },
                    ),
                  );
                }
              }
              pageController.nextPage(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeIn,
              );
            },
            child: Container(
              width: 120,
              height: 45,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: colorPrimaryDark,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: MyText(
                color: white,
                text: (pos == (widget.introList?.length ?? 0) - 1) ? "finish" : "next",
                multilanguage: true,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.text15Size,
                fontweight: FontWeight.w500,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 8,
          child: GestureDetector(
            onTap: () {
              printLog("pos :==> $pos");
              Utils.setFirstTime();
              if (Constant.userID != "") {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const BottomBar();
                    },
                  ),
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const Loginselect();
                    },
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 22),
              child: MyText(
                color: black,
                text: "skip",
                multilanguage: true,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.text16Size,
                fontweight: FontWeight.w500,
                textalign: TextAlign.center,
                fontstyle: FontStyle.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
