import 'package:flutter/material.dart';
import 'services/profile_service.dart';

// 앱 호출
void main() {
  runApp(const MyApp());
}
// 앱 전반 메인 색상 정의
const Color primaryOrange = Color(0xFFE8823A);

// 내나 아는 그거.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '출석부 데모',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryOrange),
      ),
      home: const HomePage(),
    );
  }
}
// 화면 다시 그리는 애
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); // _HomePageState 객체 생성
}

class _HomePageState extends State<HomePage> {
  final ProfileService profileService = ProfileService();

  // 얘네가 값을 받고 넘겨줄거임
  String name = '';
  String studentId = '';
  String phone = '';
  String email = '';
  bool _isLoading = true;

  @override
  void initState() { // 홈페이지 위젯 처음 만들어질때 딱한번 호출됨
    super.initState();
    _loadProfileData(); // 저장 데이터 불러옴
  }

  Future<void> _loadProfileData() async {
    final profileData = await profileService.loadProfile();
    // 	SharedPreferences에서 데이터를 불러와 state에 저장.
    if (mounted) {
      setState(() {
        name = profileData['name']!;
        studentId = profileData['studentId']!;
        phone = profileData['phone']!;
        email = profileData['email']!;
        _isLoading = false;
      });
    }
  }

  // 저장된 프로필 데이터 다 지우고 원래 기본값 설정한거 불러옴
  Future<void> _resetProfile() async {
    await profileService.clearProfile();
    await _loadProfileData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 초기화되었습니다.'), duration: Duration(seconds: 2)),
      );
    }
  }

  // 다이얼로그를 보여주는 함수가 매우 간결해졌습니다.
  // 프로필 수정 버튼(아바타)을 누르면 다이얼로그 띄움.
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // 별도로 분리된 다이얼로그 위젯을 호출합니다.
        return EditProfileDialog(
          initialName: name,
          initialStudentId: studentId,
          initialPhone: phone,
          initialEmail: email,
          onSave: (newName, newId, newPhone, newEmail) async {
            // 저장 로직은 HomePage에서 그대로 처리합니다.
            await profileService.saveProfile(
              name: newName,
              studentId: newId,
              phone: newPhone,
              email: newEmail,
            );

            if (mounted) {
              setState(() {
                name = newName;
                studentId = newId;
                phone = newPhone;
                email = newEmail;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('프로필이 저장되었습니다.'), duration: Duration(seconds: 2)),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomePage의 UI 코드는 변경이 없습니다.
    return Scaffold(
      backgroundColor: Colors.grey.shade50, // 백그라운드 컬러
      appBar: AppBar( // 상단 바
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: false, // 제목을 왼쪽 정렬
        title: const Row( // 가로방향 위젯 배치
          children: [ // 출석부 글자 관련
            Icon(Icons.book_outlined, color: primaryOrange),
            SizedBox(width: 8),
            Text('출석부', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [ // actions는 AppBar의 오른쪽 영역에 들어갈 위젯들을 지정하는 속성
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _resetProfile, // 누르면 프로필 리셋됨
            tooltip: '프로필 초기화', // 원래 마우스 대면 떠야하는 문구인디.. 이거 웹 데스크탑용이래
          ),
          if (_isLoading) // 로딩중이면 로딩 원 뜨이ㅜㅁ
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else // 로딩 다됏으면 사용자 프로필 보여줌
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: Row(
                children: [
                  Text(name, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _showEditProfileDialog,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryOrange,
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
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
        child: Padding( // 가운데에 텍스트
          padding: EdgeInsets.all(16.0),
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
// 프로필 수정 다이얼로그 만드는거
class EditProfileDialog extends StatefulWidget {
  final String initialName;
  final String initialStudentId;
  final String initialPhone;
  final String initialEmail;
  final Future<void> Function(String name, String studentId, String phone, String email) onSave;

  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialStudentId,
    required this.initialPhone,
    required this.initialEmail,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  // State 내부에 컨트롤러를 선언합니다.
  late final TextEditingController nameController;
  late final TextEditingController idController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;

  @override
  void initState() {
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

  // 재사용 가능한 입력 필드 위젯
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(
            vertical: 14, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
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
      // 다이얼로그 배경색
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      // 화면 좌우 여백
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // 모서리 둥글게
      child: SingleChildScrollView( // 스크롤 가능하게
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 제목 + 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('프로필 수정', style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
                  IconButton(
                    splashRadius: 20,
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(), // 닫기
                  )
                ],
              ),
              const SizedBox(height: 8),

              // 아바타(이름 첫 글자 원형 표시)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: nameController,
                  builder: (context, value, _) {
                    final txt = value.text;
                    final firstChar = txt.isNotEmpty
                        ? txt[0]
                        : (widget.initialName.isNotEmpty
                        ? widget.initialName[0]
                        : '?');
                    return CircleAvatar(
                      radius: 36,
                      backgroundColor: primaryOrange.withOpacity(0.1),
                      child: Text(
                        firstChar,
                        style: const TextStyle(fontSize: 28,
                            color: primaryOrange,
                            fontWeight: FontWeight.w600),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),

              // 입력 필드들
              _buildInputField(
                  controller: nameController, hint: '이름', icon: Icons.person),
              const SizedBox(height: 10),
              _buildInputField(controller: idController,
                  hint: '학번',
                  icon: Icons.bookmark_outline),
              const SizedBox(height: 10),
              _buildInputField(
                  controller: phoneController, hint: '전화번호', icon: Icons.phone),
              const SizedBox(height: 10),
              _buildInputField(controller: emailController,
                  hint: '이메일',
                  icon: Icons.email_outlined),
              const SizedBox(height: 16),

              // 하단 버튼 영역 (취소, 저장)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                    onPressed: () => Navigator.of(context).pop(), // 취소 버튼
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      // 저장 버튼 클릭 시 부모 콜백 호출
                      await widget.onSave(
                        nameController.text.trim(),
                        idController.text.trim(),
                        phoneController.text.trim(),
                        emailController.text.trim(),
                      );
                      if (mounted) Navigator.of(context).pop(); // 저장 후 닫기
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