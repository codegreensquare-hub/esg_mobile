import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_attachment_button.widget.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:flutter/material.dart';

class GreenSquarePartnershipInquiryScreen extends StatefulWidget {
  const GreenSquarePartnershipInquiryScreen({super.key});

  @override
  State<GreenSquarePartnershipInquiryScreen> createState() =>
      _GreenSquarePartnershipInquiryScreenState();
}

class _GreenSquarePartnershipInquiryScreenState
    extends State<GreenSquarePartnershipInquiryScreen> {
  final _companyEmailController = TextEditingController();
  final _contactController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController(
    text:
        '아래 내용을 보내주시면 빠른 확인에 도움이 됩니다. \n\n'
        '· 브랜드/회사명: \n'
        '· 취급 제품 또는 서비스: \n'
        '· 주요 판매 채널(온라인몰, 오프라인 등): \n'
        '· 공식 홈페이지 또는 SNS: \n'
        '· 입점 희망 이유: \n'
        '· 기타 전달 사항:\n',
  );

  static const int _titleMaxLength = 20;

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
      titleTextStyle:
          (theme.appBarTheme.titleTextStyle ??
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
        title: '입점 문의',
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
                  '그린 스퀘어는 가치 있는 소비를 위한\n친환경 전문 플랫폼입니다.',
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
                const SizedBox(height: 16),
                Text(
                  '함께 하길 원하실 경우 아래 입점 양식을 작성하여\n제출하기 버튼을 눌러주시기 바랍니다.',
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
                    hintText: '메일 주소를 입력해 주세요.',
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
                    hintText: '연락처를 입력해 주세요.',
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
                Text('제목을 입력해 주세요. (20자 이내) *', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  maxLength: _titleMaxLength,
                  style: inputTextStyle,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '제목을 입력해 주세요.',
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          '(${_titleController.text.characters.length}/$_titleMaxLength)',
                          style: labelStyle?.copyWith(
                            color: const Color(0xFF878583),
                          ),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(
                      minWidth: 0,
                      minHeight: 0,
                    ),
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
                  keyboardType: TextInputType.multiline,
                  minLines: 6,
                  maxLines: null,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '내용을 입력해 주세요.',
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
                // 첨부 파일
                Text('첨부 파일', style: labelStyle),
                const SizedBox(height: 8),
                GreenSquareAttachmentButton(
                  textStyle: inputTextStyle,
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
                  '(입점이 어려울 경우 별도의 회신이 없을 수 있습니다.)',
                  style: helperStyle,
                  textAlign: TextAlign.center,
                ),
                SafeArea(
                  top: false,
                  left: false,
                  right: false,
                  bottom: true,
                  child: const SizedBox(height: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
