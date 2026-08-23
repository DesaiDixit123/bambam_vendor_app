import 'package:flutter/services.dart';

abstract class NativeOverlayService {
  static const MethodChannel _channel = MethodChannel('com.bambam.vendor/overlay');

  /// Forces MainActivity to come to front over home screen/launcher
  static Future<void> bringToForeground() async {
    try {
      await _channel.invokeMethod('bringToForeground');
      print('📱 [NATIVE] App brought to foreground over home screen!');
    } catch (e) {
      print('📱 [NATIVE] Error bringing app to foreground: $e');
    }
  }
}
