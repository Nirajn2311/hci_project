import 'dart:convert';
import 'dart:developer';

import 'package:stacked/stacked.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';

class StartUpViewModel extends BaseViewModel {
  Map<String, dynamic>? result;
  String currQR = '';
  Map<String, String> fieldValues = {};
  Dio dio = Dio();

  void updateQR(Barcode barcode) async {
    log('NEW QR DETECTED');
    currQR = barcode.rawValue!;
    Response dioRes = await dio
        .get('https://api.thingspeak.com/channels/$currQR/feed.json?results=3');
    result = dioRes.data;
    fieldValues = {};
    result?['channel'].entries.forEach((entry) {
      if (entry.key.toString().startsWith('field')) {
        fieldValues[entry.value] = result?['feeds'][0][entry.key];
      }
    });
    fieldValues.forEach((key, value) {
      log(key);
      log(value);
    });
    notifyListeners();
  }
}
