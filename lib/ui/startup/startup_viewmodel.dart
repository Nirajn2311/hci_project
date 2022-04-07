import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpViewModel extends BaseViewModel {
  Map<String, dynamic>? result;
  String currQR = '';
  Map<String, List<SensorData>> sensorValues = {};
  Map<String, String> fields = {};
  Dio dio = Dio();

  void updateQR(Barcode barcode) async {
    log('NEW QR DETECTED');
    currQR = barcode.rawValue!;
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
}

class SensorData {
  SensorData({this.x, this.y});
  DateTime? x;
  num? y;
}
