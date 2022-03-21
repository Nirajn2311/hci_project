import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hci_project/ui/startup/startup_viewmodel.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      viewModelBuilder: () => StartUpViewModel(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('HCI Project'),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 2,
              child: MobileScanner(
                onDetect: (barcode, args) => model.updateQR(barcode),
              ),
            ),
            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                child: model.result != null && model.fieldValues != {}
                    ? Column(
                        children: [
                          Text(
                            '${model.result?['channel']['name']}',
                            style: const TextStyle(fontSize: 25),
                          ),
                          ...model.fieldValues.entries.map(
                            (entry) => Text(
                              '${entry.key}: ${entry.value}',
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Scan a code',
                        style: TextStyle(fontSize: 40),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
