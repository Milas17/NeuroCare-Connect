import 'package:yourappname/pages/listofappoinment.dart';
import 'package:yourappname/utils/colors.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widgets/mytext.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScanner extends StatefulWidget {
  const QRCodeScanner({super.key});

  @override
  State<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends State<QRCodeScanner> {
  String? result;
  MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          buildQrView(),
          Positioned(
            bottom: 43,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 1, color: white),
                ),
                child: const Icon(
                  Icons.close,
                  color: white,
                  size: 35,
                ),
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: MyText(
              text: "scan_your_qr_code",
              fontsize: Dimens.text30Size,
              fontweight: FontWeight.w900,
              color: white,
              multilanguage: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildQrView() {
    return MobileScanner(
      controller: controller,
      onDetect: (BarcodeCapture barcodeCapture) {
        final List<Barcode> barcodes = barcodeCapture.barcodes;
        for (final Barcode barcode in barcodes) {
          if (barcode.rawValue != null) {
            result = barcode.rawValue;
            printLog("Detected QR Code: $result");
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ListOfAppointment(result!),
              ),
            );
          }
        }
      },
    );
  }
}
