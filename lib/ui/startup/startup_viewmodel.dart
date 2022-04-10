import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpViewModel extends BaseViewModel {
  Map<String, dynamic>? result;
  BuildContext? context;
  // ignore: non_constant_identifier_names
  Barcode? QRres;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String currQR = '';
  Map<String, List<SensorData>> sensorValues = {};
  Map<String, String> fields = {};
  Dio dio = Dio();
  bool isLoading = false;
  bool isError = false;
  String err = '';
  String errST = '';

  void initState(BuildContext ctx) {
    context = ctx;
  }

  void openCamera() {
    log('Camera opened');
  }

  void onQRViewCreated(QRViewController qrController) {
    controller = qrController;
    notifyListeners();
    controller?.scannedDataStream.listen((scanData) async {
      QRres = scanData;
      log(currQR);
      if (currQR == '' || QRres?.code != currQR) {
        log('NEW QR DETECTED');
        log(QRres?.code ?? 'null');
        currQR = QRres?.code ?? '';
        log('FETCHING DATA');
        isLoading = true;
        isError = false;
        sensorValues = {};
        fields = {};
        try {
          notifyListeners();
          Response dioRes = await dio
              .get('https://api.thingspeak.com/channels/$currQR/feed.json');
          log('DATA FETCHED');
          result = dioRes.data;
          log('RESULTS PARSED');
          result?['channel'].entries.forEach((entry) {
            if (entry.key.toString().startsWith('field')) {
              sensorValues[entry.value] = [];
              fields[entry.key] = entry.value;
            }
          });
          log('FIELDS PARSED');
          log(result.toString());
          log(sensorValues.toString());
          log(fields.toString());
          result?['feeds'].forEach((feedEntry) {
            feedEntry.entries.forEach((entry) {
              if (entry.key.toString().startsWith('field')) {
                sensorValues[fields[entry.key]]?.add(
                  SensorData(
                    x: DateTime.parse(feedEntry['created_at']),
                    y: double.parse(feedEntry[entry.key] ?? '0'),
                  ),
                );
              }
            });
          });
          log('DATA PARSED');
          sensorValues.forEach((key, value) {
            log(key);
            log(value[0].toString());
          });
          log('DATA SENT TO VIEW');
          isLoading = false;
          HapticFeedback.vibrate();
          notifyListeners();
        } catch (e, st) {
          log('ERROR');
          log(e.toString());
          log(st.toString());
          err = e.toString();
          errST = st.toString();
          isLoading = false;
          isError = true;
          notifyListeners();
        }
      }
    }).onError((e, st) {
      log('ERROR');
      log(e.toString());
      log(st.toString());
      err = e.toString();
      errST = st.toString();
      isError = true;
      isLoading = false;
      HapticFeedback.vibrate();
      HapticFeedback.vibrate();
      notifyListeners();
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
