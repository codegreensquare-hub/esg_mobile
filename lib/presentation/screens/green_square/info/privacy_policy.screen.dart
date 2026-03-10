import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquarePrivacyPolicyScreen extends StatelessWidget {
  const GreenSquarePrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GreenSquareInfoPage(
      title: '개인정보처리방침',
      backgroundColor: kPolicyPageBackground,
      bodyBuilder: (context) {
        final theme = Theme.of(context);
        final sectionTitleStyle = theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
        final subsectionTitleStyle = theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
        final itemTitleStyle = theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        );
        final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
          height: 1.7,
          color: Colors.black87,
        );
        final emphasisStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w700);
        final captionStyle = theme.textTheme.bodySmall?.copyWith(
          height: 1.6,
          color: Colors.black54,
        );
        final cardDecoration = BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5DED6)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        );

        return SafeArea(
          child: SelectionArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6EFE8),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFC6D7CB)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '개인정보처리방침',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '주식회사 리더스 오브 그린 소사이어티(이하 “회사”)는 「개인정보 보호법」 등 관계 법령을 준수하여 이용자의 개인정보를 적법하고 투명하게 처리합니다. 회사는 이용자가 언제든지 본 방침을 확인할 수 있도록 서비스 및 홈페이지에 공개합니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1. 개인정보의 처리 목적', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text('회사는 다음 목적 범위에서 개인정보를 처리합니다.', style: bodyStyle),
                        const SizedBox(height: 16),
                        Text('1. 회원가입·본인확인·연령확인 및 회원관리', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 가입 의사 확인, 본인 식별·인증(휴대폰 본인확인 포함), 연령확인, 만 14세 미만 법정대리인 동의 확인',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 부정이용 방지, 이용 제한·제재, 서비스 운영 고지 및 약관·정책 변경 안내',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text('2. 캠페인/미션 참여 및 검수·리워드 제공', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 미션 참여 접수, 인증자료(사진/텍스트/위치 등) 검수(AI+인력), 어뷰징 방지',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 마일리지 적립·사용, 기프티콘 지급·교환, 정산 및 성과 집계(탄소배출 감축량 등)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '3. 상품/서비스 제공(전자상거래: 직접판매 + 통신판매중개 혼합)',
                          style: itemTitleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 주문·결제·배송·환불·고객지원(CS), 민원 처리 및 분쟁 대응',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text('4. 서비스 개선·안정성 확보', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 서비스 이용 분석, 오류/장애 대응, 보안 모니터링, 통계(비식별·집계 중심)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text('5. 마케팅', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 이벤트/혜택 안내, 광고성 정보 전송(푸시/SMS/LMS/MMS/이메일/알림톡 등)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F3EE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '※ 마케팅 수신 동의는 선택이며, 동의하지 않아도 서비스 이용이 가능합니다.',
                            style: captionStyle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. 처리하는 개인정보의 항목 및 수집 방법',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 16),
                        Text('2.1 수집 방법', style: subsectionTitleStyle),
                        const SizedBox(height: 10),
                        Text(
                          '• 회원이 직접 입력/제출(회원가입, 캠페인 참여, 문의)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 서비스 이용 과정에서 자동 생성(기기정보, 접속로그, 이벤트 로그 등)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 본인확인기관/플랫폼을 통한 확인(휴대폰 본인확인 결과 등)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 제휴사/판매자 등으로부터 제공(중개거래, 제휴캠페인 운영에 필요한 경우)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 18),
                        Text('2.2 필수/선택 항목(요약 표)', style: subsectionTitleStyle),
                        const SizedBox(height: 10),
                        Text(
                          '아래 항목은 “대표 예시”이며, 캠페인/서비스 유형에 따라 세부 항목은 달라질 수 있습니다. 변경·추가 시 서비스 화면에서 별도 고지합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.sizeOf(context).width - 40,
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.3),
                                1: FlexColumnWidth(0.9),
                                2: FlexColumnWidth(3.8),
                              },
                              border: TableBorder.all(
                                color: const Color(0xFFD6CDC2),
                              ),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4EEE7),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('구분', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '필수/선택',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '처리 항목(예시)',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('개인회원', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('필수', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '계정/식별 정보, 본인확인 정보, 서비스 운영 정보',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('기업이용자', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('필수', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '관리자 계정, 담당자 정보, 사업자 정보, 담당자 본인확인 정보',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('주문/배송/환불', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('필수/선택', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '주문·결제 식별정보, 수령인 정보, 배송메모(선택)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '캠페인/미션 참여',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('필수/선택', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '참여 이력, 인증사진, 검수결과, 리워드 이력, 2차 활용/위치정보(별도 동의)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('자동수집', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '서비스 이용 과정',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '접속일시, IP, 쿠키, 기기/브라우저/OS/앱버전, 오류 로그, 분석 도구 이벤트/식별자',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('(1) 개인회원(필수)', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: '• 계정/식별: ', style: emphasisStyle),
                              const TextSpan(
                                text:
                                    '이메일(또는 계정 ID), 비밀번호(직접가입 시), 이름, 휴대전화번호, 성별, 생년월일, CI',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 본인확인(항상 진행): ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text:
                                    '이름, 생년월일, 성별, 휴대전화번호, 통신사, 내/외국인 여부, CI/DI',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 서비스 운영: ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text: '회원번호, 이용정지/제재 이력, 고객센터 문의·처리 이력',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '(2) 기업이용자(관리자/B2B 콘솔)(필수)',
                          style: itemTitleStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 아이디, 비밀번호, 담당자 이름/이메일/휴대전화번호, 회사명, 사업자등록번호, 대표자명, 담당자 본인확인(CI/DI)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text('(3) 주문/배송/환불(필수)', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 주문번호, 구매상품/수량/금액, 결제상태(승인/취소/환불)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 수령인 이름, 휴대전화번호, 배송지 주소(국내), 배송메모(선택)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 결제수단 정보는 원칙적으로 PG가 처리',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text:
                                    '하며 회사는 카드번호/비밀번호 등 민감한 결제정보를 직접 저장하지 않습니다(단, 승인번호 등 거래 식별정보는 보관될 수 있음).',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('(4) 캠페인/미션 참여(필수/선택)', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: '• 필수: ', style: emphasisStyle),
                              const TextSpan(
                                text:
                                    '미션 참여 이력, 인증사진, 제출일시, 검수결과, 리워드 지급/회수 이력',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 선택(별도 동의): ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text:
                                    '인증사진의 2차 활용(홍보/성과보고/콘텐츠 재활용), 정밀 개인위치정보(아래 8장 참조)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('(5) 자동수집(서비스 이용 과정)', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Text(
                          '• 접속일시, IP, 쿠키(웹 사용 시), 기기/브라우저/OS/앱버전, 앱 설치·실행 로그, 오류 로그',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• Firebase/GA4/AppsFlyer ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text:
                                    '등 분석·성과측정 도구를 통해 수집되는 앱 이벤트/식별자(광고식별자(IDFA/GAID 등) 포함 가능) – 아래 9장 참조',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3. 만 14세 미만 아동의 개인정보 처리',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. 만 14세 미만 아동은 가입이 가능하며, 회사는 관련 법령에 따라 법정대리인의 동의 및 동의 확인 절차를 진행합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2. 법정대리인 동의 확인은 보호자 휴대전화 본인인증 방식으로 진행합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '3. 회사는 동의 확인을 위해 필요한 최소 정보(보호자 성명/휴대전화번호/CI·DI 등)를 처리하며, 분쟁 대비 목적으로 동의 확인 기록을 1년 보관 후 파기합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '4. 아동 또는 법정대리인은 언제든지 열람·정정·삭제·처리정지 등 권리를 행사할 수 있습니다(아래 10장).',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('4. 개인정보의 보유 및 이용기간', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 원칙적으로 개인정보의 처리 목적 달성 또는 보유기간 경과 시 지체 없이 파기합니다. 다만, 관련 법령에 따라 보존이 필요한 경우 해당 기간 동안 보관합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '4.1 주요 보유기간(서비스 운영 기준)',
                          style: subsectionTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: '• 회원정보: ', style: emphasisStyle),
                              const TextSpan(
                                text:
                                    '회원 탈퇴 시까지 (단, 법령상 보존 또는 분쟁·부정이용 대응을 위한 별도 보관은 아래 기준 적용)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 부정이용/분쟁 대응 기록: ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text: '탈퇴 또는 조치 종료 시점부터 최대 1년 보관(필요 최소 범위)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 인증사진(원본/검수용): ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(text: '캠페인 종료 후 2년 보관 후 파기'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '• 단, 법령 준수/분쟁 대응에 필요한 경우 최소 범위에서 추가 보관 가능',
                            style: bodyStyle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 정밀 개인위치정보(원시 좌표): ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(text: '이벤트(캠페인) 종료 후 30일 보관 후 파기'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(
                                text: '• 마케팅 수신 동의 정보: ',
                                style: emphasisStyle,
                              ),
                              const TextSpan(
                                text: '동의 철회 또는 회원 탈퇴 시까지(증적은 필요한 범위에서 보관 가능)',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('4.2 법령에 따른 보존', style: subsectionTitleStyle),
                        const SizedBox(height: 10),
                        Text(
                          '• 전자상거래 등에서의 소비자보호에 관한 법률: 계약/청약철회, 대금결제 및 재화 공급, 소비자 불만/분쟁 처리 기록 등',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text('• 통신비밀보호법: 접속로그 등', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 전자금융거래법: 전자금융거래 기록 등', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text(
                          '• 위치정보법: 위치정보 이용·제공사실 확인자료(아래 8장)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '※ 정확한 보존 항목·기간은 서비스 유형에 따라 달라질 수 있으며, 회사는 관련 법령이 정하는 범위 내에서 보관합니다.',
                          style: captionStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('5. 개인정보의 제3자 제공', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. 다만 아래의 경우에는 제공될 수 있으며, 제공 시 제공받는 자/목적/항목/보유기간을 캠페인 또는 거래 화면에서 고지하고 동의를 받습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '5.1 통신판매중개(입점사/판매자) 제공',
                          style: subsectionTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text('• 제공 시점: 중개 상품 구매·배송·환불 처리 시', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text(
                          '• 제공 항목: 구매자(회원) 성명, 연락처, 주문/결제 식별정보, 수령인 정보(성명/주소/연락처), CS 처리에 필요한 정보',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text('• 보유기간: 거래 및 법령상 보존기간 범위', style: bodyStyle),
                        const SizedBox(height: 18),
                        Text(
                          '5.2 캠페인 운영을 위한 제휴사 제공',
                          style: subsectionTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• 제공 목적: 캠페인 운영(검수/정산/리워드 지급/성과 확인 등)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 제공 항목(예시): 캠페인 참여 식별정보, 인증사진(캠페인별 상이—원본 제공 캠페인 존재), 미션 수행/검수 결과, 배송 정보',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 중요 안내: 인증사진에는 이용자의 얼굴·주거지·차량번호 등 개인정보가 포함되지 않도록 촬영해 주세요. 회사는 가능한 범위에서 마스킹 등 보호조치를 적용하나 완전한 제거를 보장하지는 않습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 보유기간: 캠페인 종료 후 2년(또는 캠페인 안내에 별도 고지한 기간)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '5.3 인증사진 2차 활용(홍보/성과보고/콘텐츠 재활용)',
                          style: subsectionTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• 제공/활용 범위: (a) 회사/제휴사의 홍보(웹/앱/SNS/보도자료 등), (b) 성과보고(지자체/기관 제출 포함), (c) 콘텐츠 재활용(편집·가공 포함)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 원칙: 얼굴·주거지·차량번호 등 식별 가능 정보는 제외/마스킹 등 비식별 조치 후 활용',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 철회: 언제든지 회원탈퇴 없이 철회 가능(아래 10장). 철회 전 이미 배포된 매체에 대해서는 회수에 한계가 있을 수 있으나, 이후 신규 활용은 중단합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          '5.4 제휴사에 제공되는 위치정보(격자화/반경 처리)',
                          style: subsectionTitleStyle,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• 제공 항목: 정밀도를 낮춘 좌표(격자화/반경 처리된 위치정보)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text('• 제공 목적: 미션 수행 사실 확인 및 성과 집계', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 동의: 위치정보는 별도 동의 기반(아래 8장)', style: bodyStyle),
                        const SizedBox(height: 10),
                        Text(
                          '※ 제3자 제공의 구체적 상대방(제휴사/브랜드/지자체/플랫폼 등)은 캠페인별로 달라질 수 있으며, 회사는 서비스 화면에서 제공 대상 목록을 공개합니다.',
                          style: captionStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6. 개인정보 처리업무의 위탁(수탁사 현황 별도 운영)',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 원활한 서비스 제공을 위해 개인정보 처리업무를 위탁할 수 있습니다. 위탁 시 회사는 법령이 요구하는 사항을 계약에 반영하고 수탁자를 감독합니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F3EE),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '• 수탁사 현황 페이지(상시 업데이트): [수탁사 현황 페이지 (링크)]',
                                style: bodyStyle,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '• 위탁업무 내용 또는 수탁자가 변경되는 경우, 회사는 위 페이지를 통해 지체 없이 공개합니다.',
                                style: bodyStyle,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text('6.1 주요 위탁업무 유형(항목)', style: subsectionTitleStyle),
                        const SizedBox(height: 10),
                        Text(
                          '• 결제 대행(PG), 본인확인(휴대폰 인증), 메시지 발송(문자/알림톡/푸시), 배송, 클라우드/호스팅, 로그분석·성과측정(Firebase/GA4/AppsFlyer), 기프티콘 발송(제3자 직접 발송 방식 채택 시)',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7. 개인정보의 국외 이전(국외처리위탁 포함)',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 클라우드/분석 도구 이용 등으로 인해 개인정보를 국외(미국)로 이전할 수 있으며, 동일 서비스 내에서 국내(한국)와 국외(미국)에 분산 저장·처리될 수 있습니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '8. 개인위치정보(정밀 좌표) 처리 및 위치기반서비스',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 미션 인증의 진위 확인 및 탄소배출감축량 등 성과 집계를 위해 정밀 개인위치정보(좌표)를 처리할 수 있습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '1. 수집 시점/범위: 앱 사용 중(백그라운드 상시 수집은 하지 않음) 미션 수행 시점에 한해 수집',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2. 처리 목적: 미션 인증 진위 확인, 어뷰징 방지, 통계·성과 집계',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '3. 보유기간: 원시 좌표는 이벤트 종료 후 30일 보관 후 파기',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '4. 제휴사 제공: 필요한 경우 격자화/반경 처리된 좌표로 제공(별도 동의)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '5. 법령상 확인자료: 위치정보 이용·제공사실 확인자료는 법령에 따라 보관',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '6. 신고 및 약관: 회사는 위치기반서비스사업 신고 완료 후 관련 기능을 제공하며, 위치기반서비스 이용약관 및 동의 절차를 별도로 제공합니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '9. 온라인 행태정보(분석/성과측정) 처리 안내',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '회사는 앱 서비스의 이용 분석 및 성과 측정을 위해 Firebase, Google Analytics 4(GA4), AppsFlyer를 사용합니다. 이 과정에서 앱 이벤트(접속/클릭/구매/설치 등), 기기정보, 광고식별자(IDFA/GAID 등)가 처리될 수 있습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '• 처리 목적: 서비스 이용 분석, 오류/성능 측정, 유입/전환 성과 측정, 부정이용 탐지 및 개선',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Text('• 거부/제한 방법(예시):', style: itemTitleStyle),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '• iOS: 설정 > 개인정보 보호 및 보안 > 추적(ATT)에서 앱별 추적 허용/거부',
                            style: bodyStyle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '• Android: 설정 > 개인정보/광고(또는 Google) > 광고 ID 재설정/삭제',
                            style: bodyStyle,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            '• 앱 내 제공되는 “맞춤형 광고/분석 제한” 설정이 있는 경우 해당 설정을 통해 제한',
                            style: bodyStyle,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '• 거부 시에도 기본 서비스는 이용 가능하나, 일부 분석/맞춤 기능의 품질이 제한될 수 있습니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '10. 정보주체 및 법정대리인의 권리·의무 및 행사 방법',
                          style: sectionTitleStyle,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '이용자(법정대리인 포함)는 다음 권리를 행사할 수 있습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Text('• 개인정보 열람, 정정·삭제, 처리정지 요구', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text(
                          '• 동의 철회(마케팅/인증사진 2차 활용/개인위치정보 등) — 회원탈퇴 없이 가능',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 자동화된 결정(예: AI 검수)과 관련하여 법령상 권리가 인정되는 범위에서 설명 요구 및 이의제기',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 14),
                        Text.rich(
                          TextSpan(
                            style: bodyStyle,
                            children: [
                              TextSpan(text: '행사 방법: ', style: emphasisStyle),
                              const TextSpan(text: '고객센터로 요청'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '회사는 접수 후 7일 이내(부득이한 경우 지체 사유 안내) 처리 결과를 안내합니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('11. 개인정보의 파기 절차 및 방법', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text(
                          '1. 파기 절차: 파기 사유 발생 → 파기 대상 선정 → 내부 승인 → 파기',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '2. 파기 방법: 전자파일은 복구 불가능한 방법으로 삭제, 출력물은 분쇄/소각 등',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('12. 개인정보의 안전성 확보조치', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text('회사는 법령에 따라 다음과 같은 조치를 시행합니다.', style: bodyStyle),
                        const SizedBox(height: 10),
                        Text('• 내부관리계획 수립·시행, 정기 점검', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 접근권한 관리(최소권한), 접근통제, 계정 관리', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 주요 정보 암호화(비밀번호 등), 전송구간 암호화', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 접속기록 보관 및 위·변조 방지', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 악성코드 방지/보안 업데이트, 취약점 점검', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 위탁사 관리·감독 및 재위탁 통제', style: bodyStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('13. 광고성 정보 전송(마케팅)', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text(
                          '• 마케팅 정보 수신 동의는 선택이며 기본 설정은 ‘비동의’입니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 발송 채널: 푸시, 문자(SMS/LMS/MMS), 이메일, 카카오 알림톡 등(서비스 상황에 따라 변동)',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 동의/철회: 앱 내 [설정 > 마케팅 수신]에서 언제든지 변경 가능',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '• 주문/배송/검수결과/보안공지 등 필수 안내는 마케팅 동의와 무관하게 발송될 수 있습니다.',
                          style: bodyStyle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('14. 개인정보 보호책임자 및 담당부서', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text('• 개인정보 보호책임자: 임관섭', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 담당부서: 운영', style: bodyStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('15. 권익침해 구제방법', style: sectionTitleStyle),
                        const SizedBox(height: 12),
                        Text(
                          '이용자는 개인정보 침해에 대한 신고·상담을 아래 기관에 할 수 있습니다.',
                          style: bodyStyle,
                        ),
                        const SizedBox(height: 10),
                        Text('• 개인정보 분쟁조정위원회', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 개인정보침해신고센터', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 대검찰청', style: bodyStyle),
                        const SizedBox(height: 6),
                        Text('• 경찰청', style: bodyStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('수탁사 현황', style: sectionTitleStyle),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.sizeOf(context).width - 40,
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.1),
                                1: FlexColumnWidth(1.7),
                                2: FlexColumnWidth(1.5),
                                3: FlexColumnWidth(2.3),
                                4: FlexColumnWidth(1.5),
                              },
                              border: TableBorder.all(
                                color: const Color(0xFFD6CDC2),
                              ),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4EEE7),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('구분', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('수탁자', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('위탁업무', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '위탁 처리 항목(예시)',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '비고(재위탁/국외여부 등)',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('결제(PG)', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('㈜케이지이니시스', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('결제 처리', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '거래식별정보(주문번호/승인번호), 결제상태 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '카드번호 등은 PG 처리',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '본인확인(PASS)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이동통신 3사(SK텔레콤/KT/LG유플러스)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '휴대폰 본인확인(연령확인 포함)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이름, 생년월일, 성별, 휴대폰번호, 통신사, CI/DI 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '통신사에 따라 상이',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('알림톡', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('㈜카카오', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('알림톡 발송', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '휴대폰번호, 메시지 내용(필수 알림/마케팅 동의 시)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('', style: bodyStyle),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '문자(SMS 등)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이동통신 3사(SK텔레콤/KT/LG유플러스)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('문자 발송', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '휴대폰번호, 메시지 내용(필수 알림/마케팅 동의 시)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('', style: bodyStyle),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('배송', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'CJ대한통운/로젠택배/편의점택배 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('배송', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '수령인 정보(이름/연락처/주소), 주문정보',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('', style: bodyStyle),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('분석/성과측정', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Google LLC(Firebase/GA4), AppsFlyer Ltd.',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '앱 분석/성과측정',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '앱 이벤트, 기기정보, 광고식별자 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '국외이전 포함 가능(별첨2 참조)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('푸시', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Google(FCM), Apple(APNs)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('푸시 발송', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '푸시 토큰, 기기정보(필요시)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '국외이전 포함 가능',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: cardDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('국외이전 현황', style: sectionTitleStyle),
                        const SizedBox(height: 14),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: MediaQuery.sizeOf(context).width - 40,
                            ),
                            child: Table(
                              columnWidths: const {
                                0: FlexColumnWidth(1.6),
                                1: FlexColumnWidth(1.1),
                                2: FlexColumnWidth(1.5),
                                3: FlexColumnWidth(1.4),
                                4: FlexColumnWidth(2.0),
                                5: FlexColumnWidth(1.3),
                                6: FlexColumnWidth(1.5),
                              },
                              border: TableBorder.all(
                                color: const Color(0xFFD6CDC2),
                              ),
                              children: [
                                TableRow(
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF4EEE7),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이전받는 자',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('이전국가', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이전시점/방법',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('이전목적', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '이전항목(예시)',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('보유기간', style: emphasisStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '거부방법/불이익',
                                        style: emphasisStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Amazon Web Services, Inc. / Google LLC',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '미국(일부), 국내(일부는 한국 저장·처리)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '서비스 이용 시 네트워크 전송/클라우드 저장',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '클라우드 인프라 운영(저장/처리/백업 등)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '계정/주문/캠페인/인증자료/위치 등 서비스 운영 DB',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '목적 달성 시 또는 계약 종료 시까지',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '거부 시 일부 기능 제한',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'Google LLC(Firebase/GA4)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '미국 등(서비스 구성에 따라 상이)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'SDK 연동 시 전송',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text('앱 분석/통계', style: bodyStyle),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '앱 이벤트, 기기정보, 광고식별자 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '설정에 따른 보유기간',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'OS/앱 설정으로 제한 가능',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'AppsFlyer Ltd.',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '미국 등(서비스 구성에 따라 상이)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'SDK 연동 시 전송',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '유입/전환 성과측정',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '광고식별자(IDFA/GAID), 앱 이벤트 등',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        '목적 달성 시까지(내부정책)',
                                        style: bodyStyle,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        'OS/앱 설정 및 요청으로 제한 가능',
                                        style: bodyStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
