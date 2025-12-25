import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

import '../provider/file_viewer_provider.dart';

class NetworkFileViewer extends StatefulWidget {
  final String url;

  const NetworkFileViewer({super.key, required this.url});

  @override
  State<NetworkFileViewer> createState() => _NetworkFileViewerState();
}

class _NetworkFileViewerState extends State<NetworkFileViewer> {
  late FileViewerProvider fileViewerProvider;
  @override
  void initState() {
    fileViewerProvider =
        Provider.of<FileViewerProvider>(context, listen: false);
    init();

    super.initState();
  }

  init() async {
    await fileViewerProvider.startLoadingFile(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: MyText(
        text: "fileviewer",
        multilanguage: true,
      )),
      body: mainBody(), // body updated dynamically
    );
  }

  Widget mainBody() {
    printLog("Extension :- ${fileViewerProvider.urlExtension}");
    if (["jpg", "jpeg", "png", "heic", "heif", "webp"]
        .contains(fileViewerProvider.urlExtension)) {
      return PhotoView(
        imageProvider: NetworkImage(widget.url),
        backgroundDecoration: const BoxDecoration(color: black),
      );
    } else if (fileViewerProvider.urlExtension == "pdf") {
      return SfPdfViewer.network(widget.url);
    } else if ([
      "doc",
      "docx",
      "xls",
      "xlsx",
      "ppt",
      "pptx",
      "pdf",
      "rtf",
      "txt",
      "odt",
      "zip",
      "rar",
    ].contains(fileViewerProvider.urlExtension)) {
      _navigateToInAppBrowser(widget.url);
      return const SizedBox.shrink();
    } else {
      return Center(
        child: MyText(
          text: "filenotsupported",
          multilanguage: true,
        ),
      );
    }
  }

  _navigateToInAppBrowser(String networkUrl) async {
    Future.delayed(
      const Duration(milliseconds: 200),
      () async {
        try {
          final Uri uri = Uri.parse(networkUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri,
                mode: LaunchMode
                    .externalApplication); // Or LaunchMode.inAppWebView if applicable
          } else {
            // Handle the error: URL not supported or cannot be launched
            printLog('Could not launch $networkUrl');
          }
          if (!mounted) return;
          Navigator.of(context).pop();
        } catch (e) {
          printLog(
              'Could not launch with Exception $networkUrl, Exception :- $e');
        }
      },
    );
  }
}
