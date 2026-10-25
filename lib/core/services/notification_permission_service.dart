import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

enum NotificationPermissionResult { granted, denied, permanentlyDenied }

abstract interface class NotificationPermissionService {
  Future<NotificationPermissionResult> requestPermission();
  Future<bool> isGranted();
  Future<bool> openAppSettings();
}

class SystemNotificationPermissionService
    implements NotificationPermissionService {
  const SystemNotificationPermissionService();

  @override
  Future<NotificationPermissionResult> requestPermission() async {
    final status = await ph.Permission.notification.request();
    if (status.isGranted || status.isLimited) {
      return NotificationPermissionResult.granted;
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      return NotificationPermissionResult.permanentlyDenied;
    } else {
      return NotificationPermissionResult.denied;
    }
  }

  @override
  Future<bool> isGranted() async {
    final status = await ph.Permission.notification.status;
    return status.isGranted || status.isLimited;
  }

  @override
  Future<bool> openAppSettings() async {
    return ph.openAppSettings();
  }
}

final notificationPermissionServiceProvider =
    Provider<NotificationPermissionService>((ref) {
      return const SystemNotificationPermissionService();
    });
