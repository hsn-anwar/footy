import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footy/shared/constants.dart';
import 'package:footy/views/result_screen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrScreen extends StatefulWidget {
  static String id = 'scan_qr_screen';
  @override
  _ScanQrScreenState createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
      ),
      body: QrScanner(),
    );
  }
}

class QrScanner extends StatefulWidget {
  @override
  _QrScannerState createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  var qrText;

  void _onViewCreated(QRViewController controller) {
    controller.scannedDataStream.listen(
      (scanData) {
        if (mounted) {
          setState(
            () {
              qrText = scanData.code;
              // dispose();
              controller.pauseCamera();
              HapticFeedback.lightImpact();
              print(qrText);
              Navigator.pushReplacementNamed(context, ResultScreen.id,
                  arguments: qrText);
            },
          );
        }
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    SizeConfig().init(context);
    return Container(
      width: SizeConfig.screenWidth,
      child: QRView(
        formatsAllowed: [BarcodeFormat.qrcode],
        cameraFacing: CameraFacing.front,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea,
        ),
        key: qrKey,
        onQRViewCreated: _onViewCreated,
      ),
    );
  }
}
