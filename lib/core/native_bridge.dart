import 'package:flutter/services.dart';

class NativeBridge {
  static const platform = MethodChannel('com.moeninja.mustamal/battery');

  Future<String> getBatteryInfo() async {
    try {
      final String result = await platform.invokeMethod('getBatteryTemp');
      return result;
    } on PlatformException catch (e) {
      return "Failed: '${e.message}'.";
    }
  }
}