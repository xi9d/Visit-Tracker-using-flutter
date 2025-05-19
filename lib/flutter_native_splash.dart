import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterNativeSplash {
  static const MethodChannel _channel = MethodChannel('flutter_native_splash');

  // This prevents the plugin class from being instantiated
  const FlutterNativeSplash._();

  /// Removes the native splash screen
  static Future<void> remove() async {
    try {
      await _channel.invokeMethod('remove');
    } on PlatformException catch (e) {
      debugPrint('Native splash screen error: ${e.message}');
    }
  }

  /// Preserves the native splash screen for later removal
  static Future<void> preserve({required BuildContext context}) async {
    try {
      await _channel.invokeMethod('preserve');
    } on PlatformException catch (e) {
      debugPrint('Native splash screen error: ${e.message}');
    }
  }
}