import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScannerPage extends StatefulWidget {
  final Function(String) onScan;

  const QRCodeScannerPage({Key? key, required this.onScan}) : super(key: key);

  @override
  State<QRCodeScannerPage> createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  bool _scanned = false;

  @override
  void dispose() {
    controller.dispose(); // Always dispose the controller!
    super.dispose();
  }

  void _handleDetection(BarcodeCapture capture) {
    if (_scanned) return;
    final barcode = capture.barcodes.first;
    final String? code = barcode.rawValue;

    if (code != null) {
      _scanned = true;
      widget.onScan(code);
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR/Bar Code'),
        backgroundColor: Color.fromARGB(255, 215, 139, 25),
      ),
      body: MobileScanner(controller: controller, onDetect: _handleDetection),
    );
  }
}
