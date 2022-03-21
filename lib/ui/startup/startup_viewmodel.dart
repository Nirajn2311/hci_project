import 'dart:convert';
import 'dart:developer';

import 'package:stacked/stacked.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';

class StartUpViewModel extends BaseViewModel {
  Barcode? result;
  String currQR = '';
  Dio dio = Dio();

  void updateQR(Barcode barcode) async {
    log('NEW QR DETECTED');
    result = barcode;
    currQR = barcode.rawValue!;
    Response dioRes = await dio
        .get('https://api.thingspeak.com/channels/$currQR/feed.json?results=3');
    notifyListeners();
  }
}
