import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nb_utils/nb_utils.dart';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode], // Only scan QR codes
  );

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(Colors.transparent);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: context.width() * 0.7,
      height: context.width() * 0.7, // Ensure square scan window
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final Barcode firstBarcode = barcodes.first;
                if (firstBarcode.rawValue != null) {
                  String data = firstBarcode.rawValue!;
                  if (data.isNotEmpty) {
                    HapticFeedback.heavyImpact();
                    if (data.validateURL()) {
                      final uri = Uri.parse(data.validate());

                      String username = uri.queryParameters['user'].validate();
                      String url = data.splitBefore('?');

                      toast("$url/");

                      userStore.setFirstName(username);
                      appStore.setBaseUrl("$url/wp-json/", initialize: true);
                      appStore.setDemoDoctor("doctor_$username@kivicare.com", initialize: true);
                      appStore.setDemoReceptionist("receptionist_$username@kivicare.com", initialize: true);
                      appStore.setDemoPatient("patient_$username@kivicare.com", initialize: true);
                    } else {
                      toast(locale.lblInvalidURL);
                    }
                    finish(context, true);
                  }
                }
              }
            },
            overlayBuilder: (context, constraints) {
              return CustomPaint(
                painter: ScannerOverlay(scanWindow: scanWindow),
                size: Size(constraints.maxWidth, constraints.maxHeight), // Pass canvas size here
              );
            },
          ),
          Positioned(
            top: context.height() * 0.28,
            left: 0,
            right: 0,
            child: Text(locale.lblQrScanner, style: boldTextStyle(color: white, size: 24), textAlign: TextAlign.center),
          ),
          Positioned(
            top: 32,
            left: 0,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: white),
              onPressed: () {
                finish(context);
              },
            ),
          ),
          Observer(builder: (_) => Loader().visible(appStore.isLoading)),
        ],
      ),
    );
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay({
    required this.scanWindow,
    this.borderRadius = 12.0,
  });

  final Rect scanWindow;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    // Use the actual canvas size
    final backgroundPath = Path()..addRect(Offset.zero & size);

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndCorners(
          scanWindow,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
      );

    final Paint backgroundPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // Draw the background with the transparent cutout
    canvas.drawPath(backgroundWithCutout, backgroundPaint);

    // Draw the white border around the scanning area
    final borderRect = RRect.fromRectAndCorners(
      scanWindow,
      topLeft: Radius.circular(borderRadius),
      topRight: Radius.circular(borderRadius),
      bottomLeft: Radius.circular(borderRadius),
      bottomRight: Radius.circular(borderRadius),
    );
    canvas.drawRRect(borderRect, borderPaint);
  }

  @override
  bool shouldRepaint(ScannerOverlay oldDelegate) {
    return scanWindow != oldDelegate.scanWindow || borderRadius != oldDelegate.borderRadius;
  }
}
