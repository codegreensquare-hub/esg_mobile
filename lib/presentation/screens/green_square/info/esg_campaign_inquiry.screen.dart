import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_attachment_button.widget.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:flutter/material.dart';

class GreenSquareEsgCampaignInquiryScreen extends StatefulWidget {
  const GreenSquareEsgCampaignInquiryScreen({super.key});

  @override
  State<GreenSquareEsgCampaignInquiryScreen> createState() =>
      _GreenSquareEsgCampaignInquiryScreenState();
}

class _GreenSquareEsgCampaignInquiryScreenState
    extends State<GreenSquareEsgCampaignInquiryScreen> {
  final _emailController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  static const int _titleMaxLength = 20;

  @override
  void initState() {
    super.initState();
    _contentController.text =
        '아래 내용을 보내주시면 빠른 확인에 도움이 됩니다.\n\n'
        '· 기업/기관명:\n'
        '· 추진 목적(ESG 목표, 홍보, 임직원 참여 등):\n'
        '· 희망 캠페인 유형\n'
        '  (예 - 친환경 소비, 탄소 저감, 임직원 참여 프로그램 등):\n'
        '· 예상 참여 대상\n'
        '  (예 - 임직원/고객/협력사/지역사회 등):\n'
        '· 예상 규모 (참여 인원 또는 대상 범위):\n'
        '· 희망 일정 및 진행 기간:\n'
        '· 참고하고 싶은 기존 ESG 사례:\n'
        '· 기타 전달 사항:';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
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
        foregroundColor: Colors.white,
        title: 'ESG 캠페인 문의',
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
                  '본 문의는 기업 및 기관 대상의\nESG 캠페인/마케팅 협업 문의 창구입니다.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontFamily: 'Noto Sans KR',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'ESG 캠페인/마케팅 관련 문의가 있으실 경우,\n'
                  '하단 양식을 작성하여 보내주시기 바랍니다.',
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
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '메일을 입력해주세요.',
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
                // 담당자 이름 및 직책
                Text('담당자 이름 및 직책 *', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactNameController,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '담당자/직책을 입력해주세요.',
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
                // 담당자 연락처
                Text('담당자 연락처 *', style: labelStyle),
                const SizedBox(height: 8),
                TextField(
                  controller: _contactPhoneController,
                  keyboardType: TextInputType.phone,
                  style: inputTextStyle,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '연락처를 입력해주세요.',
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
                    filled: true,
                    fillColor: Colors.white,
                    hintText: '제목을 입력해주세요.',
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
                  maxLines: 12,
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
                const SizedBox(height: 16),
                // 첨부 파일
                Text('첨부 파일', style: labelStyle),
                const SizedBox(height: 8),
                GreenSquareAttachmentButton(
                  placeholderLabel: '파일을 업로드해주세요.',
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
                  '가능한 빠른 시일 내 답변 드리도록 하겠습니다.',
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
