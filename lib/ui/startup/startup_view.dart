import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hci_project/ui/startup/startup_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stacked/stacked.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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
        body: SlidingUpPanel(
          renderPanelSheet: false,
          backdropOpacity: 0.3,
          panel: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0)),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20.0,
                  color: Colors.grey,
                ),
              ],
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
                        ...model.sensorValues.entries.map(
                          (entry) => Text(
                            '${entry.key}: ${entry.value[0].y}',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        SfCartesianChart(
                          primaryXAxis: DateTimeAxis(
                            edgeLabelPlacement: EdgeLabelPlacement.shift,
                            intervalType: DateTimeIntervalType.auto,
                            // dateFormat: DateFormat.Hms(),
                            name: 'Time',
                            majorGridLines: const MajorGridLines(width: 0),
                          ),
                          series: <LineSeries<SensorData, DateTime>>[
                            LineSeries<SensorData, DateTime>(
                              dataSource: model.sensorValues.values.elementAt(
                                Random().nextInt(
                                  model.sensorValues.values.length,
                                ),
                              ),
                              xValueMapper: (SensorData data, _) => data.x,
                              yValueMapper: (SensorData data, _) => data.y,
                            )
                          ],
                        )
                      ],
                    )
                  : const Text(
                      'Scan a code',
                      style: TextStyle(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                // flex: 2,
                child: MobileScanner(
                  onDetect: (barcode, args) => model.updateQR(barcode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
