import 'package:flutter/material.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/widgets/myimage.dart';

class ShimmerUtils {
  static Widget appointment(context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  clipBehavior: Clip.antiAlias,
                  child: const CustomWidget.circular(
                    height: 90,
                    width: 90,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: const BoxConstraints(maxWidth: 80),
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            CustomWidget.roundcorner(
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CustomWidget.roundcorner(
                                height: 10,
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const CustomWidget.roundcorner(
                        height: 15,
                        width: 100,
                      ),
                      const SizedBox(height: 5),
                      const CustomWidget.roundcorner(
                        height: 15,
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              alignment: Alignment.topLeft,
              decoration: BoxDecoration(
                  color: lightBlue, borderRadius: BorderRadius.circular(4)),
              child: const Row(
                children: [
                  CustomWidget.roundcorner(
                    height: 25,
                    width: 25,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: CustomWidget.roundcorner(
                      height: 15,
                      width: 100,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const CustomWidget.roundcorner(
                  height: 25,
                  width: 25,
                ),
                const SizedBox(width: 5),
                const CustomWidget.roundcorner(
                  height: 15,
                  width: 100,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: rejectedStatus, width: 0.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: const CustomWidget.roundcorner(
                    height: 25,
                    width: 25,
                  ),
                ),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: approvedStatus, width: 0.5),
                      borderRadius: BorderRadius.circular(10)),
                  child: const CustomWidget.roundcorner(
                    height: 25,
                    width: 25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget doctor(context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      color: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50.0),
                  clipBehavior: Clip.antiAlias,
                  child: const CustomWidget.circular(
                    height: 90,
                    width: 90,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        constraints: const BoxConstraints(maxWidth: 80),
                        padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                        decoration: BoxDecoration(
                            color: colorAccent,
                            borderRadius: BorderRadius.circular(8)),
                        child: const Row(
                          children: [
                            CustomWidget.roundcorner(
                              height: 25,
                              width: 25,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: CustomWidget.roundcorner(
                                height: 10,
                                width: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      const CustomWidget.roundcorner(
                        height: 15,
                        width: 100,
                      ),
                      const SizedBox(height: 5),
                      const CustomWidget.roundcorner(
                        height: 15,
                        width: 100,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              children: [
                CustomWidget.roundcorner(
                  height: 20,
                  width: 60,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: CustomWidget.roundcorner(
                    height: 20,
                    width: 100,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  static Widget articles(context) {
    return Stack(
      children: [
        CustomWidget.roundcorner(
          height: 142,
          width: MediaQuery.of(context).size.width,
        ),
        Positioned(
          top: 15,
          left: 15,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.7,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundcorner(
                  height: 20,
                  width: 100,
                ),
                SizedBox(
                  height: 30,
                ),
                CustomWidget.roundcorner(
                  height: 30,
                  width: 100,
                ),
                SizedBox(
                  height: 8,
                ),
                CustomWidget.roundcorner(
                  height: 15,
                  width: 150,
                ),
                SizedBox(
                  height: 3,
                ),
                CustomWidget.roundcorner(
                  height: 15,
                  width: 150,
                ),
              ],
            ),
          ),
        ),
        const Positioned(
          top: 10,
          right: 10,
          child: CustomWidget.roundcorner(
            height: 20,
            width: 20,
          ),
        ),
        const Positioned(
          bottom: 20,
          right: 10,
          child: CustomWidget.roundcorner(
            height: 20,
            width: 20,
          ),
        ),
      ],
    );
  }

  static Widget appointmentList(context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Stack(
        children: <Widget>[
          Card(
            clipBehavior: Clip.antiAlias,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      tileMode: TileMode.clamp,
                      colors: [
                        colorPrimary.withValues(alpha: 0.1),
                        // colorPrimary.withValues(alpha: 0.1),
                        // colorPrimary.withValues(alpha: 0.1),
                        white,

                        white,
                        white
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      const CustomWidget.circular(
                        height: 65,
                        width: 65,
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const CustomWidget.roundrectborder(
                              height: 20,
                              width: 65,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                const CustomWidget.roundrectborder(
                                  height: 10,
                                  width: 50,
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: otherColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const CustomWidget.roundrectborder(
                                  height: 10,
                                  width: 50,
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            const Row(
                              children: [
                                CustomWidget.roundrectborder(
                                  height: 20,
                                  width: 50,
                                ),
                                SizedBox(width: 20),
                                Flexible(
                                  child: CustomWidget.roundrectborder(
                                    height: 10,
                                    width: 50,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CustomWidget.roundcorner(
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                  )
                ],
              ),
            ),
          ),
          Positioned(
              top: 0,
              right: 0,
              child: Stack(
                children: [
                  MyImage(
                    imagePath: "polygon.png",
                    height: 70,
                    width: 80,
                  ),
                  const Positioned(
                    top: 10,
                    right: 0,
                    child: SizedBox(
                      width: 60,
                      child: CustomWidget.roundrectborder(
                        height: 10,
                        width: 50,
                      ),
                    ),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
