import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class StartUpViewModel extends BaseViewModel {
  String title = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  void doSomething() {
    title += 'updated ';
    // this will call the builder defined in the view file and rebuild the ui using
    // the update version of the model.
    notifyListeners();
  }

  void openCamera() {
    log('Camera opened');
  }

  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    notifyListeners();
    controller?.scannedDataStream.listen((scanData) {
      result = scanData;
      log(result.toString());
      notifyListeners();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
