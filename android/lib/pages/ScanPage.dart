import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool isBluetoothEnabled = true;
  bool scanning = false;
  List<BluetoothDevice> bluetoothDevices = [];

  FlutterBlue flutterBlue = FlutterBlue.instance;

  void startScan() async {
    if (scanning) {
      return;
    }
    bool isBleOn = await flutterBlue.isOn;
    if (!isBleOn) {
      setState(() {
        isBluetoothEnabled = false;
      });
      return;
    }
    setState(() {
      isBluetoothEnabled = true;
      scanning = true;
    });

    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 4));
    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (r.device.name != "MoonLight") {
          continue;
        }
        if (!hasBluetoothDevice(r.device)) {
          bluetoothDevices.add(r.device);
          setState(() {
          });
        }
      }
    });
  }

  bool hasBluetoothDevice(BluetoothDevice device) {
    for(var i=0;i<bluetoothDevices.length;i++) {
      if (bluetoothDevices[i].id == device.id) {
        return true;
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    startScan();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("stop scan ble devices");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getWidgets()
        ),
      ),
    );
  }
  List<Widget> getWidgets() {
    if (!isBluetoothEnabled) {
      return <Widget>[
        Container(
            padding: const EdgeInsets.all(30),
            child: const Text("Bluetooth Device is not available")
        ),
        Container(
          child: TextButton(
            onPressed: () {
              startScan();
            },
            child: const Text("Retry"),
          ),
        )
      ];
    }
    List<Widget> widgets = [];
    bluetoothDevices.forEach((element) {
      widgets.add(TextButton(
        onPressed: (){
          Navigator.pushNamed(context, "/device", arguments: element);
        },
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Color(0xfff0f0f0))
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Text(element.name+" ["+element.id.toString()+"]"),
        ),
      ));
    });
    if (scanning) {
      widgets.addAll(
        <Widget> [
          Container(
              padding: const EdgeInsets.all(30),
              child: const Text("Scanning...")
          )
        ]
      );
    }
    return widgets;
  }
}
