import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DeviceControlPage extends StatefulWidget {
  const DeviceControlPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<DeviceControlPage> createState() => _DeviceControlPageState();
}

class _DeviceControlPageState extends State<DeviceControlPage> {
  FlutterBlue flutterBlue = FlutterBlue.instance;
  BluetoothDevice? device;
  List<BluetoothService>? services;
  BluetoothCharacteristic? rgbCharacteristic;
  BluetoothCharacteristic? fadeoutCharacteristic;
  Color currentColor = Colors.white;
  double fadeOutSeconds = 60;
  bool changed = false;

  //000000ff-0000-1000-8000-00805f9b34fb  rgb service
  //====> 0000ff01-0000-1000-8000-00805f9b34fb  rgb characteristic

  //000000ee-0000-1000-8000-00805f9b34fb   fadeout service
  //====> 0000ee01-0000-1000-8000-00805f9b34fb  fadeout characteristic

  void connectDevice() async {
    await device?.connect();
    services = await device?.discoverServices();
    services?.forEach((service) {
      service.characteristics.forEach((characteristic) {
        if(characteristic.uuid == Guid("0000ff01-0000-1000-8000-00805f9b34fb")) {
          print("find out rgb characteristic");
          rgbCharacteristic = characteristic;
          //rgbCharacteristic?.write([0x00,0xFF,0x00]);
        }
        else if(characteristic.uuid == Guid("0000ee01-0000-1000-8000-00805f9b34fb")) {
          fadeoutCharacteristic = characteristic;
          print("find out fadeout characteristic");
        }
      });

      if (rgbCharacteristic!=null && fadeoutCharacteristic!=null) {
        setState(() {

        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("disconnect device...");
    device?.disconnect();
  }
  @override
  Widget build(BuildContext context) {
    if (device == null) {
      device = ModalRoute.of(context)?.settings.arguments as BluetoothDevice?;
      print("start connect to device...");
      connectDevice();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: (rgbCharacteristic == null || fadeoutCharacteristic==null) ? getConnectingWidget():getControlWidget()
    );
  }

  void setRgb(Color color) {
    currentColor = color;
    List<int> rgbValue = [
      color.red~/2,
      color.green~/2,
      color.blue~/2
    ];
    rgbCharacteristic?.write(rgbValue, withoutResponse: true);
    setState(() {
      changed = true;
    });
  }

  void setFadeout() {
    List<int> fadeOutData = [
      fadeOutSeconds.toInt()&0xff,
      (fadeOutSeconds.toInt()>>8)&0xff,
      (fadeOutSeconds.toInt()>>16)&0xff,
      (fadeOutSeconds.toInt()>>24)&0xff,
    ];
    fadeoutCharacteristic?.write(fadeOutData, withoutResponse: true);
  }

  Widget getControlWidget() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: const Text("LED颜色:"),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: ColorPicker(
            enableAlpha: false,
            showLabel: false,
            paletteType: PaletteType.hsvWithHue,

            pickerColor: currentColor,
            onColorChanged: (color){
              setRgb(color);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          width: double.infinity,
          child: Text("Fadeout时间: $fadeOutSeconds 秒"),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          child: Slider(
            value: fadeOutSeconds,
            onChanged: (v){
              setState(() {
                fadeOutSeconds = v.toInt().toDouble();
                changed = true;
              });
            },
            max: 1200,
            min: 3,
          ),
        ),
        if (changed)
        Container(
          padding: EdgeInsets.all(10),
          child: TextButton(
            onPressed: () {
              setFadeout();
              setState(() {
                changed = false;
              });
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(const Color(0xff3366ff))
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: const Center(
                child: Text("保存并执行", style: TextStyle(color: Colors.white),),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget getConnectingWidget() {
    return Container(
      padding: const EdgeInsets.all(50),
      child: const Center(
        child: Text("Connecting to device..."),
      ),
    );
  }
}
