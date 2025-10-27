import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // SharedPreferences에 데이터를 저장할 때 사용할 키(key)
  static const String _nameKey = 'profile_name';
  static const String _studentIdKey = 'profile_student_id';
  static const String _phoneKey = 'profile_phone';
  static const String _emailKey = 'profile_email';

  // 프로필 정보를 SharedPreferences에 저장하는 메소드
  Future<void> saveProfile({
    required String name,
    required String studentId,
    required String phone,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_studentIdKey, studentId);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
  }

  // SharedPreferences에서 프로필 정보를 불러오는 메소드
  Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 값이 없을 경우 기본값을 반환
    final name = prefs.getString(_nameKey) ?? '김학생';
    final studentId = prefs.getString(_studentIdKey) ?? '20230123';
    final phone = prefs.getString(_phoneKey) ?? '010-1234-5678';
    final email = prefs.getString(_emailKey) ?? 'student@university.ac.kr';

    return {
      'name': name,
      'studentId': studentId,
      'phone': phone,
      'email': email,
    };
  }

  // (추가) 프로필 정보 초기화(삭제) 메소드
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
  }
}