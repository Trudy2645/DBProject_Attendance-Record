import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const Color primaryOrange = Color(0xFFE8823A);

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 샘플 프로필 필드
  String name = '김학생';
  String studentId = '20230123';
  String phone = '010-1234-5678';
  String email = 'student@university.ac.kr';

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: name);
    final idController = TextEditingController(text: studentId);
    final phoneController = TextEditingController(text: phone);
    final emailController = TextEditingController(text: email);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 타이틀 바 (프로필 수정 + 닫기 아이콘)
                  Row(
                    children: [
                      const Text(
                        '프로필 수정',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        splashRadius: 20,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // 다이얼로그 닫기만 하고 컨트롤러 해제는 아래의 .then에서 처리
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 원형 아바타 (미리보기: nameController 변화를 반영)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: nameController,
                      builder: (context, value, _) {
                        final txt = value.text;
                        final firstChar =
                        txt.isNotEmpty ? txt[0] : (name.isNotEmpty ? name[0] : '?');
                        return CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          child: Text(
                            firstChar,
                            style: const TextStyle(
                              fontSize: 28,
                              color: primaryOrange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 입력폼들
                  _buildInputField(
                      controller: nameController, hint: '이름', icon: Icons.person),
                  const SizedBox(height: 10),
                  _buildInputField(
                      controller: idController, hint: '학번', icon: Icons.bookmark_outline),
                  const SizedBox(height: 10),
                  _buildInputField(
                      controller: phoneController, hint: '전화번호', icon: Icons.phone),
                  const SizedBox(height: 10),
                  _buildInputField(
                      controller: emailController, hint: '이메일', icon: Icons.email_outlined),
                  const SizedBox(height: 16),
                  // 버튼: 취소, 저장
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // 취소
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      const SizedBox(width: 12),
                      // 저장
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          // 변경 내용 적용 (trim 해서 빈 문자열 허용하되, 뷰에서 안전하게 처리)
                          setState(() {
                            name = nameController.text;
                            studentId = idController.text;
                            phone = phoneController.text;
                            email = emailController.text;
                          });
                          Navigator.of(context).pop();
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
      },
    ).then((_) {
      // 다이얼로그가 완전히 닫힌 후 컨트롤러들을 해제
      nameController.dispose();
      idController.dispose();
      phoneController.dispose();
      emailController.dispose();
    });
  }

  // 재사용 가능한 입력 필드 위젯
  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0.6,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Row(
          children: [
            Icon(Icons.book_outlined, color: primaryOrange),
            SizedBox(width: 8),
            Text(
              '출석부',
              style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Text(
                  name,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showEditProfileDialog,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryOrange,
                    child: Text(
                      // 빈 문자열 방지
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: const SizedBox.expand(),
    );
  }
}