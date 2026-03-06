import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:flutter/material.dart';

class GreenSquareMissionRequestScreen extends StatefulWidget {
  const GreenSquareMissionRequestScreen({super.key});

  @override
  State<GreenSquareMissionRequestScreen> createState() =>
      _GreenSquareMissionRequestScreenState();
}

class _GreenSquareMissionRequestScreenState
    extends State<GreenSquareMissionRequestScreen> {
  final _companyEmailController = TextEditingController();
  final _contactController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  static const int _titleMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _contentController.text =
        '아래 내용을 보내주시면 빠른 확인에 도움이 됩니다.\n\n'
        '· 원하는 미션 이름:\n'
        '· 미션 신청 사유:\n'
        '· 미션 신청 시기/일정:\n'
        '· 미션 진행 방식:\n'
        '· 미션 진행 기간:\n'
        '· 기타 전달 사항:';
  }

  @override
  void dispose() {
    _companyEmailController.dispose();
    _contactController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final appBarTheme = theme.appBarTheme.copyWith(
      titleTextStyle: (theme.appBarTheme.titleTextStyle ??
              theme.textTheme.titleMedium ??
              const TextStyle())
          .copyWith(
        fontFamily: 'Noto Sans KR',
      ),
    );

    final labelStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontFamily: 'Noto Sans KR',
    );

    final helperStyle = theme.textTheme.bodySmall?.copyWith(
      color: Colors.white,
      fontFamily: 'Noto Sans KR',
    );

    final inputTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontFamily: 'Noto Sans KR',
    );

    return Theme(
      data: theme.copyWith(appBarTheme: appBarTheme),
      child: GreenSquareInfoPage(
        backgroundColor: const Color(0xFF355149),
        title: '미션 요청',
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: GreenSquareLogo(height: 30, color: Colors.white),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Container(
                    height: 1,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  '원하시는 미션이 있으신가요?\n하단 양식을 작성하여 신청해주세요!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Noto Sans KR',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  '지구를 위한 선한 영향력을 위해\n일하는 기업이라면 언제든 환영입니다.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Noto Sans KR',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // 회신 메일 주소
                Text('회신 메일 주소 *', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _companyEmailController,
                  keyboardType: TextInputType.emailAddress,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'green@gmail.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 회신 연락처
                Text('회신 연락처 (- 제외 입력)', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '01012345678',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 제목
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('제목을 입력해 주세요. (20자 이내) *', style: labelStyle),
                    Text(
                      '${_titleController.text.characters.length}/$_titleMaxLength',
                      style: helperStyle,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  maxLength: _titleMaxLength,
                  style: inputTextStyle,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '미션을 요청합니다.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 내용
                Text('내용을 입력해 주세요. *', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentController,
                  maxLines: 10,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // 제출하기 버튼
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: implement submission
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      '제출하기',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '제안해주신 내용에 대해서는\n'
                  '가능한 빠른 시일 내 안내 드리도록 하겠습니다.\n'
                  '(반영이 어려운 경우 별도의 회신이 없을 수 있습니다.)',
                  style: helperStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

