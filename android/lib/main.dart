import 'package:Moonlight/pages/DeviceControlPage.dart';
import 'package:Moonlight/pages/ScanPage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Eclipse Moonlight',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ScanPage(title: 'Scan Peripherals'),
      routes: {
        "/device": (context)=>const DeviceControlPage(title: "蓝牙控制")
      },
    );
  }
}

