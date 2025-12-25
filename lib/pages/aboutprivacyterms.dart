import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/sharedpre.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class AboutPrivacyTerms extends StatefulWidget {
  final String appBarTitle, loadURL;

  const AboutPrivacyTerms({
    super.key,
    required this.appBarTitle,
    required this.loadURL,
  });

  @override
  State<AboutPrivacyTerms> createState() => _AboutPrivacyTermsState();
}

class _AboutPrivacyTermsState extends State<AboutPrivacyTerms> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  SharedPre sharedPref = SharedPre();
  late GeneralProvider generalProvider;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    printLog("loadURL ========> ${widget.loadURL}");
    pullToRefreshController = (kIsWeb) ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: colorAccent),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colorPrimary,
        body: Container(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: setWebView(),
        ),
      );
    } else {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: colorPrimary,
        appBar: Utils.myAppBarWithBack(
          context,
          widget.appBarTitle,
          false,
          true,
        ),
        body: setWebView(),
      );
    }
  }

  Widget setWebView() {
    return Consumer<GeneralProvider>(
      builder: (BuildContext context, GeneralProvider generalProvider,
          Widget? child) {
        return Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.loadURL)),
              pullToRefreshController: pullToRefreshController,
              onWebViewCreated: (controller) async {
                webViewController = controller;
              },
              onLoadStart: (controller, url) async {
                generalProvider.loadingPercentage = 0;
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                return NavigationActionPolicy.ALLOW;
              },
              onLoadStop: (controller, url) async {
                generalProvider.loadingPercentage = 100;
              },
              onProgressChanged: (controller, progress) {
                generalProvider.loadingPercentage = progress;
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                printLog("onUpdateVisitedHistory url =========> $url");
              },
              onConsoleMessage: (controller, consoleMessage) {
                printLog("consoleMessage =========> $consoleMessage");
              },
            ),
            if (generalProvider.loadingPercentage < 100)
              LinearProgressIndicator(
                color: colorAccent,
                backgroundColor: colorPrimary,
                value: generalProvider.loadingPercentage / 100.0,
              ),
          ],
        );
      },
    );
  }
}
