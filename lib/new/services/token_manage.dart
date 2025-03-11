import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// SecureStorage 인스턴스 생성
const _storage = FlutterSecureStorage();

// 토큰 저장
Future<void> saveTokens(String accessToken, String refreshToken) async {
  await _storage.write(key: 'access_token', value: accessToken);
  await _storage.write(key: 'refresh_token', value: refreshToken);
}

// 액세스 토큰 불러오기
Future<String?> getAccessToken() async {
  return await _storage.read(key: 'access_token');
}

// 리프레시 토큰 불러오기
Future<String?> getRefreshToken() async {
  return await _storage.read(key: 'refresh_token');
}

// 토큰 삭제
Future<void> deleteTokens() async {
  await _storage.delete(key: 'access_token');
  await _storage.delete(key: 'refresh_token');
}
