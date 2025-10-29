import 'package:flutter/material.dart';
import 'services/profile_service.dart';

void main() {
  runApp(const MyApp());
}

const Color primaryOrange = Color(0xFFE8823A); // 색 설정

class MyApp extends StatelessWidget { // MyApp 클래스가 StatelessWidet을 상속했다는것을 의미
  const MyApp({super.key});
//StatelessWidget : 상태가 없는 위젯 -> 위젯 내부의 데이터가 변하지 않는 ui요소 만들때 사용
  @override
  Widget build(BuildContext context) { // StatelessWidget 상속해 사용시 반드시 오버라이드해야함
    return MaterialApp( // MaterialApp에 반환할 각 변수값들 설정하는듯
      title: '출석부 데모',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryOrange), // 스키마 : 데이터 논리구조와 제약조건 정의한것 from Adsp 즉 color에 대한 구조 or 제약 조건 설정하는 라인인것같다
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget { // 상속 사용, StatefulWidget : 상태가 있는 위젯으로 사용자 입력에 따라 상호작용하여 상태 변경함
  const HomePage({super.key}); // key 매개변수를 부모클래스인 widget의 생성자에게 전달

  @override
  State<HomePage> createState() => _HomePageState(); // 화살표 문법으로 함수 본문이 단일 표현식임을 나타낸다
}

class _HomePageState extends State<HomePage> {
  final ProfileService profileService = ProfileService(); // 생성자 정의
// 각 변수들 초기화
  String name = '';
  String studentId = '';
  String phone = '';
  String email = '';
  bool _isLoading = true;

  @override
  void initState() { // 상태 초기화 함수
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async { //비동기 처리 사용
    final profileData = await profileService.loadProfile();
    if (mounted) { //profileData 위젯트리 안에 정상적 존재시 작업 실행
      setState(() { //setter : 특정 클래스의 변수에 값 할당할때 사용
        name = profileData['name']!;
        studentId = profileData['studentId']!;
        phone = profileData['phone']!;
        email = profileData['email']!;
        _isLoading = false;
      });
    }
  }
  // 여기서 대괄호가 리스트는 아닌거같고 ai한테 물어보니 map형의 자료에 key로 접근하는 방식이라는데 main코드에는 없고
  // profile_service 파일에 map관련해서 loadprofile 이 있는걸 확안했습니다
  Future<void> _resetProfile() async { // Profile 데이터 모두 비움
    await profileService.clearProfile(); // 정보 제거 메소드 불러와 사용
    await _loadProfileData();

    if (mounted) { // mounted : 불린값으로써 state객체가 위젯트리 안에 존재하는지 여부를 불린값으로 반환
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 초기화되었습니다.'), duration: Duration(seconds: 2)),
      ); //SnackBar : 사용자에게 빠르고 간단한 메시지 보여줌. 위 코드는 프로필 초기화 멘트를 2초동안 띄워줌
    }
  }

  // 다이얼로그를 보여주는 함수가 매우 간결해졌습니다.
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true, // 다이얼로그 닫는 방법을 설정. true : 다이얼로그 외부 배경 탭시 자동으로 닫힘. false : 다이얼로그 내부 버튼 등 '명시적' 행위 통해서만 닫기 가능
      builder: (context) {
        // 별도로 분리된 다이얼로그 위젯을 호출합니다.
        return EditProfileDialog(
          initialName: name,
          initialStudentId: studentId,
          initialPhone: phone,
          initialEmail: email,
          onSave: (newName, newId, newPhone, newEmail) async {
            // 저장 로직은 HomePage에서 그대로 처리합니다.
            await profileService.saveProfile( //정보 저장 메소드 불러오기
              name: newName,
              studentId: newId,
              phone: newPhone,
              email: newEmail,
            );

            if (mounted) {
              setState(() { // 위젯트리에 있을때는 값을 '상태' 변수에 저장
                name = newName;
                studentId = newId;
                phone = newPhone;
                email = newEmail;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필이 저장되었습니다.'), duration: Duration(seconds: 2)),
              ); // 저장완료 메시지 2초간 출력
            }
          },
        );
      },
    );
  }

  //Scaffold : 앱 화면의 기본적이고 구조적인 레이아웃 구축하는 위젯
  @override
  Widget build(BuildContext context) {
    // HomePage의 UI 코드는 변경이 없습니다.
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // 배경색 설정
      appBar: AppBar( // 앱 바의 스펙 설정
        elevation: 0.6, // 위젯이 얼마나 떠있는가 ( 입체감 표현인거같은데 맞나요 )
        backgroundColor: Colors.white, // 배경색
        centerTitle: false, // 안드로이드 운영체제 기본값으로 제목을 왼쪽정렬로 표시함
        title: const Row(
          children: [
            Icon(Icons.book_outlined, color: primaryOrange), //아이콘
            SizedBox(width: 8), // 글자크기
            Text('출석부', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton( // 버튼 모양 설정
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _resetProfile, // 버튼 눌렀을시 실행하는 함수. 즉 이 버튼은 프로필 초기화 버튼이다
            tooltip: '프로필 초기화',
          ),
          if (_isLoading) // loading중인가? 가 답이 true일때
            const Padding( // padding : 하나의 자식 위젯을 가지는데 이 자식 위젯의 크기를 넓혀줌
              padding: EdgeInsets.symmetric(horizontal: 24.0), // 자식 위젯 크기를 얼마나 키울건지 결정. symmetric은 수평,수직 방향에 동일한 크기 적용
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8), // 필요한 방향만 선택적으로 적용
              child: Row(
                children: [
                  Text(name, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(width: 10),
                  GestureDetector( // 동작 감지했을때 실행되는 메소드
                    onTap: _showEditProfileDialog, // 탭 감지했을 때 실행하는 메소드 -> 프로필 수정 다이얼로그를 보여준다
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryOrange,
                      child: Text(
                        name.isNotEmpty ? name[0] : '?', // 이름 비어있지 않으면 name[0] 할당 비어있으면 ? 할당
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0), // 상하좌우 네 방향 모두 패딩 적용
          child: Text(
            '오른쪽 상단 프로필을 눌러 정보를 수정하세요.\n앱을 종료해도 데이터는 유지됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 다이얼로그의 내용물을 별도의 StatefulWidget으로 분리
// -----------------------------------------------------------------------------
class EditProfileDialog extends StatefulWidget { // 프로필 수정 다이얼로그 내용물들
  final String initialName;
  final String initialStudentId;
  final String initialPhone;
  final String initialEmail;
  final Future<void> Function(String name, String studentId, String phone, String email) onSave;
// 위의 모든 변수들 Future 이용해 한번에 반환
  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialStudentId,
    required this.initialPhone,
    required this.initialEmail,
    required this.onSave,
  });
//required 이용해 값이 반드시 할당되게 함
  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  // State 내부에 컨트롤러를 선언합니다.
  late final TextEditingController nameController;
  late final TextEditingController idController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
// 프로필 편집 다이얼로그의 state 설정
  @override
  void initState() { // 초기화
    super.initState();
    // initState에서 컨트롤러를 안전하게 생성합니다.
    nameController = TextEditingController(text: widget.initialName);
    idController = TextEditingController(text: widget.initialStudentId);
    phoneController = TextEditingController(text: widget.initialPhone);
    emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 Flutter가 자동으로 호출해주는 dispose에서 컨트롤러를 해제합니다.
    nameController.dispose();
    idController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
  // 각 컨트롤러 해제

  // 재사용 가능한 입력 필드 위젯
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration( // 위젯의 디자인 결정
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12), // 수직 수평방향으로 패딩
        border: OutlineInputBorder( // border : 위젯에 테두리 선 그릴때 사용
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder( // 활성화 상태의 테두리 ( 입력필드가 활성화되어있을때 적용)
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder( // 위젯이 활성화도 되어있고 포커스도 되어있을 때 테두리 적용
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryOrange, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 둥근 사각형 테두리
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min, // mainAxisSize : row와 col에 얼마만큼의 공간 허락할지 결정
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('프로필 수정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8), // margin : 위젯의 바깥쪽 여백 padding : 위젯의 안쪽 여백
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController, //valueListenable : 단일값을 감시하며 값 변경시 알림 받게 해주는 인터페이스
                  builder: (context, value, _) {
                    final txt = value.text;
                    final firstChar = txt.isNotEmpty ? txt[0] : (widget.initialName.isNotEmpty ? widget.initialName[0] : '?');
                    return CircleAvatar(
                      radius: 36,
                      backgroundColor: primaryOrange.withOpacity(0.1),
                      child: Text(
                        firstChar,
                        style: const TextStyle(fontSize: 28, color: primaryOrange, fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              _buildInputField(controller: nameController, hint: '이름', icon: Icons.person),
              const SizedBox(height: 10),
              _buildInputField(controller: idController, hint: '학번', icon: Icons.bookmark_outline),
              const SizedBox(height: 10),
              _buildInputField(controller: phoneController, hint: '전화번호', icon: Icons.phone),
              const SizedBox(height: 10),
              _buildInputField(controller: emailController, hint: '이메일', icon: Icons.email_outlined),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end, // row와 col에서 mainaxis 따라 자식 위젯들 어떻게 정렬할건지 결정
                children: [
                  TextButton( // 텍스트 버튼의 구성물
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton( //elevated버튼의 구성물
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // 변경된 값을 onSave 콜백으로 전달
                      await widget.onSave( // trim : 문자열 양 끝의 공백 문자 제거시 사용
                        nameController.text.trim(),
                        idController.text.trim(),
                        phoneController.text.trim(),
                        emailController.text.trim(),
                      );
                      if (mounted) {
                        Navigator.of(context).pop(); // 위젯트리에 존재할시 navigator.of(context)를 스택에서 빼냄
                      }
                    },
                    child: const Text('저장'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}