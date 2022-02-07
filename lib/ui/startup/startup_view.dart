import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hci_project/ui/startup/startup_viewmodel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double? scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
      log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
      if (!p) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('no Permission')),
        );
      }
    }

    return ViewModelBuilder<StartUpViewModel>.reactive(
      viewModelBuilder: () => StartUpViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('HCI Project'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 4,
              child: QRView(
                key: model.qrKey,
                onQRViewCreated: model.onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: scanArea,
                ),
                onPermissionSet: (ctrl, p) =>
                    _onPermissionSet(context, ctrl, p),
              ),
            ),
            Expanded(
              flex: 1,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    model.result != null
                        ? Text(
                            'Type: ${describeEnum(model.result!.format)}   Data: ${model.result!.code}')
                        : const Text('Scan a code')
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
