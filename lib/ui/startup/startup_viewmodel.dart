import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpViewModel extends BaseViewModel {
  Map<String, dynamic>? result;
  // ignore: non_constant_identifier_names
  Barcode? QRres;
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
    notifyListeners();
    controller?.scannedDataStream.listen((scanData) async {
      QRres = scanData;
      if (QRres?.code != currQR) {
        log('NEW QR DETECTED');
        log(QRres?.code ?? 'null');
        currQR = QRres?.code ?? '';
        Response dioRes = await dio.get(
            'https://api.thingspeak.com/channels/$currQR/feed.json');
        result = dioRes.data;
        sensorValues = {};
        result?['channel'].entries.forEach((entry) {
          if (entry.key.toString().startsWith('field')) {
            sensorValues[entry.value] = [];
            fields[entry.key] = entry.value;
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
    });
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
