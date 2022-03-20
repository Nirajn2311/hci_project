import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:dio/dio.dart';

class StartUpViewModel extends BaseViewModel {
  String title = '';
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  String currQR = '';
  QRViewController? controller;
  Dio dio = Dio();

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
    controller?.scannedDataStream.listen((scanData) async {
      result = scanData;
      if (result?.code != currQR) {
        log(result?.code ?? 'null');
        currQR = result?.code ?? '';
        Response dioRes = await dio.get('https://api.thingspeak.com/channels/$currQR/feed.json?results=3');
        log(dioRes.data.toString());
        notifyListeners();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
