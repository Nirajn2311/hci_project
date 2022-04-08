import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hci_project/ui/startup/startup_viewmodel.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StartUpView extends StatelessWidget {
  const StartUpView({Key? key}) : super(key: key);

  SfCartesianChart _generateChart(Map<String, List<SensorData>> sensorValues) {
    MapEntry<String, List<SensorData>> data = sensorValues.entries.elementAt(
      Random().nextInt(
        sensorValues.entries.length,
      ),
    );
    return SfCartesianChart(
      title: ChartTitle(text: data.key),
      primaryXAxis: DateTimeAxis(
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        intervalType: DateTimeIntervalType.auto,
        name: 'Time',
      ),
      series: <LineSeries<SensorData, DateTime>>[
        LineSeries<SensorData, DateTime>(
          dataSource: data.value,
          xValueMapper: (SensorData data, _) => data.x,
          yValueMapper: (SensorData data, _) => data.y,
        )
      ],
    );
  }

  Color _setTextColor(num? value) {
    if (value == null) {
      return Colors.black;
    } else if (value < 1000) {
      return Colors.green;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<StartUpViewModel>.reactive(
      viewModelBuilder: () => StartUpViewModel(),
      onModelReady: (model) => model.initState(context),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('HCI Project'),
        ),
        body: SlidingUpPanel(
          renderPanelSheet: false,
          backdropOpacity: 0.3,
          panel: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24.0),
                topRight: Radius.circular(24.0),
              ),
              border: Border.all(
                color: Colors.black,
                width: 3,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: model.result != null && model.sensorValues != {}
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          '${model.result?['channel']['name']}',
                          style: const TextStyle(fontSize: 25),
                          textAlign: TextAlign.center,
                        ),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              ...model.sensorValues.entries.map(
                                (entry) => Text(
                                  '${entry.key}: ${entry.value.last.y}',
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                              _generateChart(model.sensorValues),
                            ],
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Scan a code',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            children: [
              QRView(
                key: model.qrKey,
                onQRViewCreated: model.onQRViewCreated,
                overlay: QrScannerOverlayShape(
                  borderColor: Colors.red,
                  borderRadius: 10,
                  borderLength: 30,
                  borderWidth: 10,
                  cutOutSize: 200,
                  cutOutBottomOffset: 150,
                ),
              ),
              model.sensorValues.entries.isNotEmpty
                  ? IntrinsicHeight(
                      child: Column(
                        children: [
                          const Icon(
                            CupertinoIcons.triangle_fill,
                            color: Colors.black,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8)),
                              border: Border.all(
                                color: Colors.black,
                                width: 3,
                              ),
                            ),
                            child: Column(
                              children: [
                                ...model.sensorValues.entries
                                    .toList()
                                    .take(3)
                                    .map(
                                      (entry) => Text(
                                        '${entry.key}: ${entry.value.last.y}',
                                        style: TextStyle(
                                            fontSize: 20,
                                            color: _setTextColor(
                                                entry.value.last.y)),
                                      ),
                                    ),
                              ],
                            ),
                          )
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
