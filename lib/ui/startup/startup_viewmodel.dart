import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpViewModel extends BaseViewModel {
  Map<String, dynamic>? result;
  Barcode? res;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String currQR = '';
  Map<String, List<SensorData>> sensorValues = {};
  Map<String, String> fields = {};
  Dio dio = Dio();

  void openCamera() {
    log('Camera opened');
  }

  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    // notifyListeners();
    controller?.scannedDataStream.listen((scanData) async {
      res = scanData;
      if (res?.code != currQR) {
        log('NEW QR DETECTED');
        log(res?.code ?? 'null');
        currQR = res?.code ?? '';
        Response dioRes = await dio.get(
            'https://api.thingspeak.com/channels/$currQR/feed.json?results=3');
        log(dioRes.data.toString());
        // notifyListeners();
      }
      // notifyListeners();
    });
  }

  void updateQR(Barcode barcode) async {
    log('NEW QR DETECTED');
    // currQR = barcode.rawValue!;
    Response dioRes =
        await dio.get('https://api.thingspeak.com/channels/$currQR/feed.json');
    result = dioRes.data;
    sensorValues = {};
    result?['channel'].entries.forEach((entry) {
      if (entry.key.toString().startsWith('field')) {
        sensorValues[entry.value] = [];
        fields[entry.key] = entry.value;
        // fieldValues[entry.value]?.add([ ,result?['feeds'][0][entry.key]]);
      }
    });
    result?['feeds'].forEach((feedEntry) {
      feedEntry.entries.forEach((entry) {
        if (entry.key.toString().startsWith('field')) {
          sensorValues[fields[entry.key]]?.add(
            SensorData(
              x: DateTime.parse(feedEntry['created_at']),
              y: double.parse(feedEntry[entry.key]),
            ),
          );
        }
      });
    });
    sensorValues.forEach((key, value) {
      log(key);
      log(value[0].toString());
    });
    HapticFeedback.vibrate();
    notifyListeners();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class SensorData {
  SensorData({this.x, this.y});
  DateTime? x;
  num? y;
}
