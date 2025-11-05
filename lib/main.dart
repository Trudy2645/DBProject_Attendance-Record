import 'package:flutter/material.dart';
import 'services/profile_service.dart';
//-대충 함수보고 구상은 한 것
///-상상치도 못한 정체

void main() {
  runApp(const MyApp());
}//위젯 실행

const Color primaryOrange = Color(0xFFE8823A);
//앱 기본 색상

class MyApp extends StatelessWidget {//앱의 기본설정: (테마)
  // StatelessWidget-한번 저장되면 변하지 않음
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {///화면에 그려야 할 ui
    return MaterialApp(// flutter앱의 기본 골격 만드는 함수
      title: '출석부 데모',//앱 제목
      theme: ThemeData(//테마
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryOrange),
      ),
      home: const HomePage(),///앱이 실행되었을 때 가장 먼저 보여줄 화면
    );
  }
}

class HomePage extends StatefulWidget {///프로필 데이터가 로딩되거나 변경될 때 업데이트 하게 함
  const HomePage({super.key});//앱의 첫 화면

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ProfileService profileService = ProfileService();
//데이터 저장,로드를 담당할 progileservice의 인스턴스 생성

  String name = '';
  String studentId = '';
  String phone = '';
  String email = '';
  bool _isLoading = true;
  ///homepage가 관리해야 할 상태 변수들

  @override
  void initState() {
    super.initState();//초기화
    _loadProfileData();//데이터 로딩
    //처음 화면을 생성할 때 _loadProfileData()함수를 호출하여 저장된 프로필을 불러옴
  }

  Future<void> _loadProfileData() async {//데이터 로딩/ async-await: 다른 함수 먼저 실행 수 받음
    final profileData = await profileService.loadProfile();
    if (mounted) {
      /// 안전장치, 데이터 로딩 중 화면이 사라질 경우 대비
      setState(() {
        name = profileData['name']!;
        studentId = profileData['studentId']!;
        phone = profileData['phone']!;
        email = profileData['email']!;
        _isLoading = false;
      });//mounted가 true일 때만 화면을 갱신
      ///불러온 데이터로 상태변수등을 업데이트하고, 로딩이 끝났으므로 _isLoading을 false로 변ㄱㅇ
    }
  }

  Future<void> _resetProfile() async {//app bar의 새로고침을 눌렀을 때 실행될 함수
    await profileService.clearProfile();///저장된 데이터 다 지움
    await _loadProfileData();///다시 불러옴; 두 함수 잘 이해안됨

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 초기화되었습니다.'), duration: Duration(seconds: 2)),
      );//프로필이 초기화됐다는 알림메시지(스낵바)를 화면 하단에 띄움
    }
  }

  // 다이얼로그를 보여주는 함수가 매우 간결해졌습니다.
  void _showEditProfileDialog() {//프로필 아이콘을 눌렀을 때 실행
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        // 별도로 분리된 다이얼로그 위젯을 호출합니다.
        return EditProfileDialog(///위젯을 반환
          initialName: name,
          initialStudentId: studentId,
          initialPhone: phone,
          initialEmail: email,
          //homepage가 갖고있는 상태를 초기값으로 전달
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
              );///저장버튼이 눌렸을때 실행될 로직을 homepage 에서 미리 정의하여 함수자체 전달
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // HomePage의 UI 코드는 변경이 없습니다.
    return Scaffold(//앱 화면의 기본구조를 제공하는 가장 표준적인 위젯
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(//화면 상단의 앱바
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.book_outlined, color: primaryOrange),
            SizedBox(width: 8),
            Text('출석부', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [///앱바의 오른쪽에 표시될 위젯
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.grey),
            onPressed: _resetProfile,
            tooltip: '프로필 초기화',
          ),//프로필을 초기화할 수 있는 새로고침 버튼
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.0)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
              child: Row(
                children: [
                  Text(name, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(width: 10),
                  GestureDetector(///circleavatar을 감싸서 클릭이벤트를 감지 할 수 있음
                    onTap: _showEditProfileDialog,///ontap클릭시 함수 실행하고 다이얼로그 띄움
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: primaryOrange,
                      child: Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),//isLoading이 true면 circularprogressindicator
                      //isLoading이 false면 text(사용자 이름)과 circleavatar
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            '오른쪽 상단 프로필을 눌러 정보를 수정하세요.\n앱을 종료해도 데이터는 유지됩니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),//center 위젯을 사용해 내부의 text위젯을 화면 중앙에 정렬
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 다이얼로그의 내용물을 별도의 StatefulWidget으로 분리
// -----------------------------------------------------------------------------
class EditProfileDialog extends StatefulWidget {//statefulwidget-데이터가 변함
  final String initialName;
  final String initialStudentId;
  final String initialPhone;
  final String initialEmail;
  final Future<void> Function(String name, String studentId, String phone, String email) onSave;
//homepage로부터 전달받을 초기값을 저장할 변수.
/// final-위젯 내부에서 변경되지 않음
  const EditProfileDialog({
    super.key,
    required this.initialName,
    required this.initialStudentId,
    required this.initialPhone,
    required this.initialEmail,
    required this.onSave,
  });///required- 필수로 받아야 할 값들 정의

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  // State 내부에 컨트롤러를 선언합니다.
  late final TextEditingController nameController;
  late final TextEditingController idController;
  late final TextEditingController phoneController;
  late final TextEditingController emailController;
///지금 당장은 값이 없지만, initState에서 딱 한번 초기화 될 것이고 이후로는 바뀌지 않는다
//textfield위젯을 제어하기 위한 texteditingcontroller들을 선언
  @override
  void initState() {//다이얼로그가 처음 열릴 때 호출됨
    super.initState();
    // initState에서 컨트롤러를 안전하게 생성합니다.
    nameController = TextEditingController(text: widget.initialName);
    idController = TextEditingController(text: widget.initialStudentId);
    phoneController = TextEditingController(text: widget.initialPhone);
    emailController = TextEditingController(text: widget.initialEmail);
  }
//전달받은 init데이터들을 textfield의 초기 텍스트로 설정하여 컨트롤러 생성
  @override
  void dispose() {
    // 위젯이 제거될 때 Flutter가 자동으로 호출해주는 dispose에서 컨트롤러를 해제합니다.
    nameController.dispose();
    idController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
///dipose을 하지 않으면 누수 발생 statefulwidget와 dispose는 같이
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
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
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
    );//스타일이 적용된 textfield위젯을 반환
  }

  @override
  Widget build(BuildContext context) {//상단 빌드
    return Dialog(//다이얼로그의 기본 형태
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ValueListenableBuilder<TextEditingValue>(
                ///nameController의 값이 변경되는지 항상 주시
                  valueListenable: nameController,
                  builder: (context, value, _) //사용자가 이름을 타이핑 할 때마다 실시간으로 다시 실행
                    final txt = value.text;//value가 nameController의 현재 값
                    final firstChar = txt.isNotEmpty ? txt[0] : (widget.initialName.isNotEmpty ? widget.initialName[0] : '?');
                    //텍스트의 첫글자 계산
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
              Row(//하단 버튼
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(//취소 버튼
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      foregroundColor: Colors.black87,
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),//버튼 스타일
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('취소'),//닫기
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(//저장 버튼
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),//버튼 스타일
                    onPressed: () async {
                      // 변경된 값을 onSave 콜백으로 전달
                      await widget.onSave(//homepage에서 받은 함수 호출
                        nameController.text.trim(),
                        idController.text.trim(),
                        phoneController.text.trim(),
                        emailController.text.trim(),
                      );
                      if (mounted) {//안전장치
                        Navigator.of(context).pop();//저장 후 다이얼로그 닫기
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