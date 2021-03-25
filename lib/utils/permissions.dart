import 'package:permission_handler/permission_handler.dart';

class Permissions {
  static Future<bool> cameraAndMicrophonePermissionsGranted() async {
    final PermissionStatus cameraPermissionStatus = (await _getCameraPermission())!;
    final PermissionStatus microphonePermissionStatus =
        (await _getMicrophonePermission())!;
    if (cameraPermissionStatus == PermissionStatus.granted &&
        microphonePermissionStatus == PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  static Future<PermissionStatus?> _getCameraPermission() async {
    final PermissionStatus permission = await Permission.camera.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.camera].request();
      return permissionStatus[Permission.camera] ?? PermissionStatus.restricted;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus?> _getMicrophonePermission() async {
    final PermissionStatus permission = await Permission.microphone.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.microphone].request();
      return permissionStatus[Permission.microphone] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }

  static Future<PermissionStatus> getContactsPermission() async {
    final PermissionStatus permission = await Permission.contacts.status;
    if (permission != PermissionStatus.granted) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.contacts].request();
      return permissionStatus[Permission.contacts] ??
          PermissionStatus.restricted;
    } else {
      return permission;
    }
  }
}
