import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  // 마이크 권한을 요청하는 메서드
  Future<bool> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    return status.isGranted;
  }

  // 저장소 권한을 요청하는 메서드
  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  // 마이크와 저장소 권한을 모두 요청하는 메서드
  Future<void> requestPermissions() async {
    await requestMicrophonePermission();
    await requestStoragePermission();
  }
}
