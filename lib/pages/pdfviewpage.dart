import 'package:yourappname/pages/nodata.dart';
import 'package:yourappname/provider/patienthistoryprovider.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewPage extends StatefulWidget {
  final String? id, title;
  const PdfViewPage({super.key, required this.id, required this.title});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  late PdfViewerController _pdfViewerController;
  late PatientHistoryProvider patientHistoryProvider;
  @override
  void initState() {
    patientHistoryProvider =
        Provider.of<PatientHistoryProvider>(context, listen: false);
    _pdfViewerController = PdfViewerController();
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    await patientHistoryProvider.getDownloadPrescription(widget.id);

    Future.delayed(Duration.zero).then((value) {
      if (!mounted) return;
      patientHistoryProvider.notifyListener();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      // onPopInvoked: onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: white,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                  color: colorAccent.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8)),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: black,
              ),
            ),
          ),
          title: MyText(
            color: white,
            text: widget.title.toString(),
            fontsize: Dimens.text18Size,
            fontweight: FontWeight.w600,
          ),
        ),
        body: Consumer<PatientHistoryProvider>(
          builder: (context, patientHistoryProvider, child) {
            if (patientHistoryProvider.prescLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (patientHistoryProvider.downloadPrescriptionModel.status ==
                      200 &&
                  patientHistoryProvider.downloadPrescriptionModel.result !=
                      null &&
                  patientHistoryProvider.downloadPrescriptionModel.result !=
                      []) {
                return SfPdfViewer.network(
                  patientHistoryProvider
                          .downloadPrescriptionModel.result?[0].pdfUrl
                          .toString() ??
                      "",
                  controller: _pdfViewerController,
                  key: _pdfViewerKey,
                  onPageChanged: (details) {
                    _pdfViewerController.pageNumber;
                    printLog(
                        "Current Page nO -- ${_pdfViewerController.pageNumber}");
                    printLog(
                        "Current Page pageCount -- ${_pdfViewerController.pageCount}");
                  },
                );
              } else {
                return const NoData(text: "");
              }
            }
          },
        ),
      ),
    );
  }
}
