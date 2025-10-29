import 'package:shared_preferences/shared_preferences.dart';
//shared_preferences 패키지 사용
class ProfileService {
  // SharedPreferences에 데이터를 저장할 때 사용할 키(key)
  //프로필 관련 기능 (데이터를 저장할 때 사용하는 키(key)를 사용)
  static const String _nameKey = 'profile_name';
  static const String _studentIdKey = 'profile_student_id';
  static const String _phoneKey = 'profile_phone';
  static const String _emailKey = 'profile_email';
//static const는 정적 상수라는 뜻이며, 절대 변하지 않음
  //변수 명 앞에 _가 붙는 것은 클래스 외부에서 접근할 수 없는 비공개 속성이라는 뜻

  // 프로필 정보를 SharedPreferences에 생성 & 수정 하는 메소드
  Future<void> saveProfile({//Future: 미래에 결과가 나올 자리를 표시-비동기/ 주로 미완료와 완료 두 상태를 가짐
    required String name,
    required String studentId,
    required String phone,
    required String email,//required는 필수임, 옵션 아님
  }) async { //asynchronous 비동기 프로그램 실행이 끝날 때까지 다른 프로그램을 먼저 처리
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_studentIdKey, studentId);
    await prefs.setString(_phoneKey, phone);
    await prefs.setString(_emailKey, email);
  }//await는 async함수 안에서만 쓸 수 있고 이 프로그램이 끝날 때까지

  // SharedPreferences에서 프로필 정보를 불러오는 메소드
  //<>:generics라고 부름, 꺽쇠 안의 내용물 타입을 구체적으로 알려주는 역할
  Future<Map<String, String>> loadProfile() async {//이 함수의 반환형을 의미:
    // 나중의 결과물은 map형태이다. 그 map은 key도 string이고 value도 string인 데이터이다.
    //map은 키와 값을 연결해 데이터를 저장하는 자료구조이다.
    final prefs = await SharedPreferences.getInstance();
    //저장소를 사용하겠다고 요청하는 코드
    // 저장된 값이 없을 경우 기본값을 반환
    final name = prefs.getString(_nameKey) ?? '김학생';
    final studentId = prefs.getString(_studentIdKey) ?? '20230123';
    final phone = prefs.getString(_phoneKey) ?? '010-1234-5678';
    final email = prefs.getString(_emailKey) ?? 'student@university.ac.kr';
  //final은 값을 딱 한번만 할당할 수 있음 그 뒤에는 변경 불가
    //??'' : 만약 getString의 결과가 null 이라면 기본값 사용하라는 뜻
    return {
      'name': name,
      'studentId': studentId,
      'phone': phone,
      'email': email,
    };//각 키에 해당 하는 값을 키에 저장
  }

  // (추가) 프로필 정보 초기화(삭제) 메소드
  Future<void> clearProfile() async {//비동기, 반환 값 없음
    final prefs = await SharedPreferences.getInstance();//SharedPreferences 인스턴스를 가져옴
    await prefs.remove(_nameKey);
    await prefs.remove(_studentIdKey);
    await prefs.remove(_phoneKey);
    await prefs.remove(_emailKey);//remove메소드를 사용하여 데이터 삭제
  }//메소드 끝
}//클래스 끝