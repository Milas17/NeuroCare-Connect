import 'package:yourappname/pages/appointmentdetails.dart';
import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/notificationprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mynetworkimg.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:provider/provider.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  ProgressDialog? prDialog;
  late ScrollController _scrollController;
  late NotificationProvider notificationProvider;

  @override
  void initState() {
    prDialog = ProgressDialog(context);
    notificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    getApi(0);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (notificationProvider.currentPage ?? 0) <
            (notificationProvider.totalPage ?? 0)) {
      await notificationProvider.setLoadMore(true);
      await getApi((notificationProvider.currentPage ?? 0));
    }
  }

  getApi(pageNo) async {
    await notificationProvider.getDoctorNotification((pageNo + 1).toString());
  }

  @override
  void dispose() {
    notificationProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: white,
      appBar: Utils.myAppBarWithBack(context, "notifications", true, true),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollController,
          child: Column(
            children: [
              buildNotification(),
              Consumer<NotificationProvider>(
                builder: (context, viewallprovider, child) {
                  if (viewallprovider.loadmore) {
                    return Utils.pageLoader();
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
              const SizedBox(
                height: 50,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildNotification() {
    return Consumer<NotificationProvider>(
      builder: (context, notificationProvider, child) {
        if (notificationProvider.loading &&
            notificationProvider.loadmore == false) {
          return notificationShimmer();
        } else {
          if (notificationProvider.notificationModel.status == 200 &&
              notificationProvider.notificationModel.result != null) {
            if ((notificationProvider.notificationList?.length ?? 0) > 0) {
              return AlignedGridView.count(
                shrinkWrap: true,
                padding: const EdgeInsets.all(20),
                mainAxisSpacing: 14,
                crossAxisCount: 1,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: notificationProvider.notificationList?.length ?? 0,
                itemBuilder: (BuildContext context, int position) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: white,
                    ),
                    child: InkWell(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            clipBehavior: Clip.antiAlias,
                            child: MyNetworkImage(
                              // imageUrl: notificationProvider
                              //         .notificationList?[position]
                              //         .doctorProfileImage
                              //         .toString() ??
                              //     "",
                              imageUrl: notificationProvider.notificationList?[position].image ?? "",
                              fit: BoxFit.cover,
                              imgHeight: 50,
                              imgWidth: 50,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: [
                                    Expanded(
                                      child: MyText(
                                        text:  notificationProvider
                                                    .notificationList?[position]
                                                    .title
                                                     ??
                                                "",
                                        textalign: TextAlign.start,
                                        maxline: 1,
                                        overflow: TextOverflow.ellipsis,
                                        fontsize: Dimens.text16Size,
                                        color: colorPrimaryDark,
                                        fontweight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    MyText(
                                      text: Utils.covertTimeToText(
                                          notificationProvider
                                                  .notificationList?[position]
                                                  .createdAt
                                                  .toString() ??
                                              ""),
                                      textalign: TextAlign.start,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      fontsize: Dimens.text12Size,
                                      color: otherColor,
                                      fontweight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                MyText(
                                  text: notificationProvider
                                          .notificationList?[position].message
                                          .toString() ??
                                      "",
                                  textalign: TextAlign.start,
                                  maxline: 2,
                                  overflow: TextOverflow.ellipsis,
                                  fontsize: Dimens.text13Size,
                                  color: otherColor,
                                  fontweight: FontWeight.w400,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const NoData(
                text: '',
              );
            }
          } else {
            return const NoData(
              text: '',
            );
          }
        }
      },
    );
  }

  void readAndViewNotification(
      String notificationID, String appointmentID) async {
    printLog("notificationID ==> $notificationID");
    Utils.showProgress(context, prDialog);
    final removeNotificationProvider =
        Provider.of<NotificationProvider>(context, listen: false);

    printLog(
        "readAndViewNotification loading :==> ${removeNotificationProvider.loading}");
    if (!removeNotificationProvider.loading) {
      if (removeNotificationProvider.successModel.status == 200) {
        prDialog?.hide();

        printLog("appointmentID : ==> $appointmentID");
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AppointmentDetails(appointmentID),
          ),
        );
      } else {
        prDialog?.hide();
        if (!mounted) return;
        Utils.showSnackbar(
            context, removeNotificationProvider.successModel.message ?? "", false);
      }
    }
  }

  Widget notificationShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      padding: const EdgeInsets.all(20),
      mainAxisSpacing: 14,
      crossAxisCount: 1,
      scrollDirection: Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (BuildContext context, int position) => Container(
        padding: const EdgeInsets.all(10),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: white,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CustomWidget.circular(
              height: 50,
              width: 50,
            ),
            SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child: CustomWidget.roundcorner(
                          height: 15,
                          width: 200,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      CustomWidget.roundcorner(
                        height: 12,
                        width: 100,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  CustomWidget.roundcorner(
                    height: 12,
                    width: 200,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
