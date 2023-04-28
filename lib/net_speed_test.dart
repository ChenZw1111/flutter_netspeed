import 'package:flutter/material.dart';
import 'package:flutter_internet_speed_test/flutter_internet_speed_test.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:dart_ping/dart_ping.dart';

class SpeedTestPage extends StatefulWidget {
  @override
  _SpeedTestPageState createState() => _SpeedTestPageState();
}

class _SpeedTestPageState extends State<SpeedTestPage> {
  final internetSpeedTest = FlutterInternetSpeedTest()..enableLog();

  bool _testInProgress = false;
  double _downloadRate = 0;
  double _uploadRate = 0;
  String _downloadProgress = '0';
  String _uploadProgress = '0';
  int _downloadCompletionTime = 0;
  int _uploadCompletionTime = 0;
  bool _isServerSelectionInProgress = false;
  int _netdeley =0;
  String? _ip;
  String? _asn;
  String? _isp;

  String _unitText = 'Mbps';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlutterInternetSpeedTest example'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            SfRadialGauge(
                title: const GaugeTitle(
                    text: 'Speedometer',
                    textStyle:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold)),
                axes: <RadialAxis>[
                  RadialAxis(
                      axisLineStyle: const AxisLineStyle(thickness: 15),
                      showTicks: false,
                      pointers: <GaugePointer>[
                        NeedlePointer(
                            value: _downloadRate,
                            enableAnimation: true,
                            needleStartWidth: 5,
                            needleEndWidth: 5,
                            needleColor: Color(0xFFDADADA),
                            gradient: const LinearGradient(
                                colors: <Color>[
                                  Color(0xFFDADADA),
                                  Color(0xFF753A88)
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter),
                            knobStyle: const KnobStyle(
                                color: Colors.white,
                                borderColor: Colors.white,
                                knobRadius: 0,
                                borderWidth: 0),
                            tailStyle: const TailStyle(
                                color: Color(0xFFDADADA),
                                width: 5,
                                length: 0.15)),
                        RangePointer(
                          value: _downloadRate,
                          width: 15,
                          enableAnimation: true,
                          gradient: const SweepGradient(colors: <Color>[
                            Color(0xFFCC2B5E),
                            Color(0xFF753A88)
                          ], stops: <double>[
                            0.25,
                            0.75
                          ]),
                        )
                      ])
                ]),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextColumn('网络延迟', '$_netdeley'),
                _buildTextColumn('下载速度', '$_downloadRate $_unitText'),
                _buildTextColumn('上传速度', '$_uploadRate $_unitText')
              ],
            ),
            if (!_testInProgress) ...{
              ElevatedButton(
                child: const Text('Start Testing'),
                onPressed: () async {
                  reset();
                  await internetSpeedTest.startTesting(onStarted: () {
                    setState(() => _testInProgress = true);
                  }, onCompleted: (TestResult download, TestResult upload) {
                    setState(() {
                      _downloadRate = download.transferRate;
                      _unitText =
                          download.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                      _downloadProgress = '100';
                      _downloadCompletionTime = download.durationInMillis;
                    });
                    setState(() {
                      _uploadRate = upload.transferRate;
                      _unitText =
                          upload.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                      _uploadProgress = '100';
                      _uploadCompletionTime = upload.durationInMillis;
                      _testInProgress = false;
                    });
                  }, onProgress: (double percent, TestResult data) {
                    // if (kDebugMode) {
                    //   print(
                    //       'the transfer rate $data.transferRate, the percent $percent');
                    // }
                    setState(() {
                      _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                      if (data.type == TestType.download) {
                        _downloadRate = data.transferRate;
                        _downloadProgress = percent.toStringAsFixed(2);
                      } else {
                        _uploadRate = data.transferRate;
                        _uploadProgress = percent.toStringAsFixed(2);
                      }
                    });
                  }, onError: (String errorMessage, String speedTestError) {
                    // if (kDebugMode) {
                    //   print(
                    //       'the errorMessage $errorMessage, the speedTestError $speedTestError');
                    // }
                    reset();
                  }, onDefaultServerSelectionInProgress: () {
                    setState(() {
                      _isServerSelectionInProgress = true;
                    });
                  }, onDefaultServerSelectionDone: (Client? client) {
                    setState(() {
                      _isServerSelectionInProgress = false;
                      _ip = client?.ip;
                      _asn = client?.asn;
                      _isp = client?.isp;
                    });
                  }, onDownloadComplete: (TestResult data) {
                    setState(() {
                      _downloadRate = data.transferRate;
                      _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                      _downloadCompletionTime = data.durationInMillis;
                    });
                  }, onUploadComplete: (TestResult data) {
                    setState(() {
                      _uploadRate = data.transferRate;
                      _unitText = data.unit == SpeedUnit.kbps ? 'Kbps' : 'Mbps';
                      _uploadCompletionTime = data.durationInMillis;
                    });
                  }, onCancel: () {
                    reset();
                  });
                final ping = Ping("baidu.com",count: 5);
                ping.stream.listen((event) {
                  Duration? d = event.response?.time;
                  _netdeley = d?.inMilliseconds as int;
                });
                  },
              )
            } else ...{
              const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextButton.icon(
                  onPressed: () => internetSpeedTest.cancelTest(),
                  icon: const Icon(Icons.cancel_rounded),
                  label: const Text('Cancel'),
                ),
              )
            },
          ],
        ),
      ),
    );
  }

  void reset() {
    setState(() {
      {
        _testInProgress = false;
        _downloadRate = 0;
        _uploadRate = 0;
        _downloadProgress = '0';
        _uploadProgress = '0';
        _unitText = 'Mbps';
        _downloadCompletionTime = 0;
        _uploadCompletionTime = 0;

        _ip = null;
        _asn = null;
        _isp = null;
      }
    });
  }

  Column _buildTextColumn(String label1, String label2) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(left: 22,right: 22),
            child: Text(
          label1,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        )),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            label2,
            style: TextStyle(
                color:
                    !_testInProgress ? Colors.black : const Color(0xff305CE3),
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        )
      ],
    );
  }
}
