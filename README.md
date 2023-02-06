# Moonlight LED
## Introduction
This is a simple bluetooth night light based on ESP32-C3 microcontroller. It uses 4 RGB LEDs as the light source, and main functions are:
- BLE4 support
- LED color can be configured by BLE
- Fadeout supported, device can be controled from light to dark in configured time.
- Simple Android app suppored.BLE debugging APPs also useable.

家里小孩睡觉不愿意关灯，特地做了一个蓝牙小夜灯实现逐渐关灯的效果。 :)

## Demo images

![](images/2.jpg?raw=true)

![](images/1.jpg?raw=true)

## Source Description

- schematic/  Board schematic by KiCad
- esp32c3/  Embeded sources for ESP32-C3 microcontroller
- android/ Simple Android app sources

## BLE services description

蓝牙设备名称为 `Moonlight`, 包含两个Service.

### RGB服务
Service UUID为: `000000ff-0000-1000-8000-00805f9b34fb`, 包含1个characteristic
- LED当前颜色的Characteristic UUID为 `0000ff01-0000-1000-8000-00805f9b34fb`， 可读可写，数据为3个字节，分别为 红，绿，蓝 的颜色值，0-255。 如 "FFFFFF" 表示白色。
- 写入示例： `FF0000`设置当前LED颜色为红色, `00FF00`设置当前LED颜色为绿色。

### Fadeout服务
Service UUID为 `000000ee-0000-1000-8000-00805f9b34fb`, 包含1个characteristic
- Fadeout倒计时Characteristic UUID为 `0000ee01-0000-1000-8000-00805f9b34fb`， 可读可写
- 读取为4个字节，表示倒计时的时间， 单位为秒，`Little Endian`方式编码，如 `0x00112233`秒（1122867秒）的4个字节表示为  `33221100`； `0x00000003`秒（3秒）的4个字节表示为 `03000000`
- 写入时，可写入4个字节或者5个字节。前4个字节为`Little Endian`方式的倒计时时间，单位为秒，第5个字节（可选）为保存选项，如果第5个字节为1，表示保存当前的颜色和倒计时到芯片的flash中，下次上电时可直接使用保存的颜色和倒计时执行渐暗逻辑。
- 写入示例： `03000000`表示3秒内LED从当前颜色减至最暗，不保存， `0300000001`表示3秒内LED从当前颜色减至最暗，并且保存当前设置的颜色和倒计时到芯片Flash中，下次上电使用保存的值。