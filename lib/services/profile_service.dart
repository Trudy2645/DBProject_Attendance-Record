import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  // SharedPreferences에 데이터를 저장할 때 사용할 키(key)
  static const String _nameKey = 'profile_name'; // 이름 저장 키
  static const String _studentIdKey = 'profile_student_id'; // 학번 저장 키
  static const String _phoneKey = 'profile_phone'; // 전화번호 저장키
  static const String _emailKey = 'profile_email'; // 이메일 저장 키

  // 프로필 정보를 SharedPreferences에 저장하는 메소드
  Future<void> saveProfile({
    required String name, // required가 있으면 null이 될 수 없음
    required String studentId, // 그럼 뭐가 들어가야 널 가능하지?
    required String phone,
    required String email,
  }) async {
    // SharedPreferences 인스턴스는 싱글턴처럼 동작. 즉 인스턴스 여러개 만들어도 하나를 공유함.
    // 내부적으로 네이티브 쪽에 접근하므로 await로 비동기 호출을 기다려야 함 (메인 스레드를 블로킹하지 않음. 즉 화면안멈춤)
    final prefs = await SharedPreferences.getInstance(); // 비동기로 인스턴스 가져옴

    // 각 키에 대응하는 값들을 저장
    await prefs.setString(_nameKey, name);
    await prefs.setString(_studentIdKey, studentId); // setString은 실패 시 false를 반환
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);

    // 주의: 여러 번 set 연산을 연속해서 호출하면 내부적으로 여러 I/O 작업이 발생할 수 있습니다.
    // 대량의 데이터를 빈번히 저장해야 하는 경우에는 별도의 배치 처리나 debounce 로직을 검토하세요.c
    //이럴 때는 “한 번에 모아서” 저장하는 게 좋음. 이걸 배치 처리(batch) 또는 디바운스(debounce) 로 해결
  }

  // SharedPreferences에서 프로필 정보를 불러오는 메소드
  Future<Map<String, String>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // 저장된 값이 없을 경우 기본값을 반환
    // getString은 값이 없으면 null을 반환하므로 널 병합 연산자(??)로 기본값을 지정
    final name = prefs.getString(_nameKey) ?? '김학생';
    final studentId = prefs.getString(_studentIdKey) ?? '20230123';
    final phone = prefs.getString(_phoneKey) ?? '010-1234-5678';
    final email = prefs.getString(_emailKey) ?? 'student@university.ac.kr';
    // Map으로 묶어서 반환
    return {
      'name': name,
      'studentId': studentId,
      'phone': phone,
      'email': email,
    };
  }
  // 저장된 프로필 관련 키들을 제거합
  // remove는 해당 키가 존재하면 삭제하고, 삭제 여부를 Future<bool>으로 반환합니다.
  // (추가) 프로필 정보 초기화(삭제) 메소드
  Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);
  }
}