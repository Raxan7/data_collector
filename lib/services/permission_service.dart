import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestStorage() async {
    if (await Permission.storage.isGranted) return true;
    
    // Check Android version
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.request().isGranted;
      }
    }
    return await Permission.storage.request().isGranted;
  }

  static Future<bool> requestCamera() async {
    return await Permission.camera.request().isGranted;
  }

  static Future<bool> requestLocation() async {
    return await Permission.locationWhenInUse.request().isGranted;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}