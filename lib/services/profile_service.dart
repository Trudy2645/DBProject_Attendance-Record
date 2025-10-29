import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // SharedPreferences에 데이터를 저장할 때 사용할 키(key)
  static const String _nameKey = 'profile_name';
  static const String _studentIdKey = 'profile_student_id';
  static const String _phoneKey = 'profile_phone';
  static const String _emailKey = 'profile_email';
// 전역변수로 선언해 어디에서나 변수 사용 가능 또한 const로 선언해 데이터 조작 불가능하게 함

  // 프로필 정보를 SharedPreferences에 저장하는 메소드
  Future<void> saveProfile({ //Future+메소드 : 비동기 처리시 한번만 반환하는 메소드 ( 한번에 반환값이 여려개인것은 상관 x)
    required String name, // required 키워드는 변수선언에 사용 시 반드시 변수에 값을 할당하게끔 강제하는 역할을 한다
    required String studentId,
    required String phone,
    required String email,
  }) async { // 비동기 작업 처리 선언
    final prefs = await SharedPreferences.getInstance(); // await : Future 완료되어 결과값 반환 전까지 작업 대기시킴
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