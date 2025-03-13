import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SecureStorage 인스턴스 생성
const _storage = FlutterSecureStorage();

// userId 저장
Future<void> saveUserId(String userId) async {
  await _storage.write(key: 'user_id', value: userId);
}

// userId 불러오기
Future<String?> getUserId() async {
  return await _storage.read(key: 'user_id');
}

// userId 삭제
Future<void> deleteUserId() async {
  await _storage.delete(key: 'user_id');
}
