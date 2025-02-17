import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 키 관리를 위한 Enum
enum UserKey { name, age, gender, level }

/// 유저 인포 관리 Class
class UserInfo {
  static final UserInfo _instance = UserInfo._internal();
  factory UserInfo() => _instance;

  UserInfo._internal();

  late SharedPreferences _prefs;

  // 초기화 메서드 (앱 시작 시 실행 필요)
  Future<void> initUserPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 유저 정보 저장
  Future<void> saveUserInfo({
    required String name,
    required int age,
    required int gender,
    int? level,
  }) async {
    int currentLevel =
        level ?? _prefs.getInt(UserKey.level.name) ?? 1; // 기존 level 유지

    await _prefs.setString(UserKey.name.name, name);
    await _prefs.setInt(UserKey.age.name, age);
    await _prefs.setInt(UserKey.gender.name, gender);
    await _prefs.setInt(UserKey.level.name, currentLevel);
  }

  // 유저 정보 로드
  Future<void> loadUserInfo() async {
    // 비동기로 유저 정보 불러오기
    _name = _prefs.getString(UserKey.name.name) ?? '';
    _age = _prefs.getInt(UserKey.age.name) ?? 0;
    _gender = _prefs.getInt(UserKey.gender.name) ?? 0;
    _level = _prefs.getInt(UserKey.level.name) ?? 1;
  }

  // 유저 정보 필드
  String _name = '';
  int _age = 0;
  int _gender = 0;
  int _level = 1;

  // 게터
  String get name => _name;
  int get age => _age;
  int get gender => _gender;
  int get level => _level;

  // 세터
  Future<void> setName(String value) async {
    _name = value;
    await _prefs.setString(UserKey.name.name, value);
  }

  Future<void> setAge(int value) async {
    _age = value;
    await _prefs.setInt(UserKey.age.name, value);
  }

  Future<void> setGender(int value) async {
    _gender = value;
    await _prefs.setInt(UserKey.gender.name, value);
  }

  Future<void> setLevel(int value) async {
    _level = value;
    await _prefs.setInt(UserKey.level.name, value);
  }

  // 유저 정보 삭제 (로그아웃 시 사용)
  Future<void> clearUserInfo() async {
    await _prefs.clear();
    _name = '';
    _age = 0;
    _gender = 0;
    _level = 1;
  }
}
