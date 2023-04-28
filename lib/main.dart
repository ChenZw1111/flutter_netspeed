import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_netspeed/resources/project_colors.dart';
import 'package:http/http.dart' as http;

import 'net_speed_test.dart';


void main() => runApp(const AppBarApp());

class AppBarApp extends StatelessWidget {
  const AppBarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: AppBarExample(),
    );
  }
}

class AppBarExample extends StatelessWidget {
  const AppBarExample({super.key});

  @override
  Widget build(BuildContext context) {
    bool isOn = true;
    void _toggle() {
      if (isOn) {
        isOn = false;
      } else {
        isOn = true;
      }
    }

    //网络测速页
    Widget netSpeedPage = Scaffold(
      backgroundColor: MyColors.fff3f3f3,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.fff3f3f3,
        iconTheme: const IconThemeData(color: Color(0xff305CE3)),
        title: const Text(
          '网络测速',
          style: TextStyle(color: Color(0xff305CE3)),
        ),
      ),
      body: ListView(children: [
        Image.asset(
          'images/lake.jpeg',
          width: 600,
          height: 200,
          fit: BoxFit.cover,
        ),
        NetSpeedPage()
      ]),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('AppBar Demo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add_alert),
            tooltip: 'Show Snackbar',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('This is a snackbar')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.navigate_next),
            tooltip: 'Go to the next page',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute<void>(
                builder: (BuildContext context) {
                  return SpeedTestPage();
                },
              ));
            },
          ),
        ],
      ),
      body: const Center(
        child:
        Text(
          'This is the home page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

Column _buildTextColumn(bool isOn, String label1, String label2) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label1,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      ),
      Container(
        margin: const EdgeInsets.only(top: 8),
        child: Text(
          label2,
          style: TextStyle(
              color: isOn ? Colors.black : const Color(0xff305CE3),
              fontSize: 14,
              fontWeight: FontWeight.w400),
        ),
      )
    ],
  );
}

class NetSpeedPage extends StatefulWidget {
  NetSpeedPage({super.key});

  @override
  State<StatefulWidget> createState() => _NetSpeedPageState();
}

class _NetSpeedPageState extends State<NetSpeedPage> {
  bool isOn = true;
  String res = '';

  void _toggle() {
    netSpeed();
    setState(() {
      isOn = !isOn;
    });
  }

  void netSpeed() async {
    int inByte = 0;
    int start_time = 0;
    int cur_time=0;
    double speed= 0;
    const url = 'https://t7.baidu.com/it/u=2604797219,1573897854&fm=193&f=GIF';
    Dio dio = Dio();
    final rs = await dio.get(url,
    options: Options(responseType: ResponseType.stream));
    var _BoundSinkStream= rs.data.stream;
    var stdin = _BoundSinkStream as Stdin;
    start_time = DateTime.now().millisecondsSinceEpoch;
    while(stdin.readByteSync()!= -1){
      inByte++;
      cur_time = DateTime.now().millisecondsSinceEpoch;
      if(cur_time-start_time == 0){
        speed =1000;
      }else{
        speed = inByte/(cur_time-start_time)*1000;
        print('===============================');
        print(speed);
      }
    }
    // final internetSpeedTest = InternetSpeedTest();
    // internetSpeedTest.startDownloadTesting(onDone: (double transferRate, SpeedUnit unit) {
    //   // TODO: Change UI
    //   print('======================================================');
    //   print(transferRate);
    //   print('======================================================');
    // },
    //   onProgress: (double percent, double transferRate, SpeedUnit unit) {
    //     // TODO: Change UI
    //   },
    //   onError: (String errorMessage, String speedTestError) {
    //     // TODO: Show toast error
    //   },testServer:url );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Column(children: [
      TextButton(
          onPressed: _toggle,
          style: ButtonStyle(
              backgroundColor:
              MaterialStateColor.resolveWith((states) => MyColors.ff305ce3),
              shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
              padding: const MaterialStatePropertyAll(
                  EdgeInsets.fromLTRB(10, 6, 10, 6))),
          child: Text(
            isOn ? '开始测速' : '取消测速',
            style: const TextStyle(color: Colors.white),
          )),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTextColumn(isOn, '0MS', '网络延迟'),
          _buildTextColumn(isOn, '0.0MS', '下载速度'),
          _buildTextColumn(isOn, '0.0MS', '上传速度'),
        ],
      ),
      Text(res)
    ]);
  }
}
