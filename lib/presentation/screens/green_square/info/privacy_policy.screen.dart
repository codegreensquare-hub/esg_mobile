import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquarePrivacyPolicyScreen extends StatelessWidget {
  const GreenSquarePrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GreenSquareInfoPage(
      title: '개인정보 처리방침',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제 1장 총칙
              Text(
                '제 1장 총칙',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제1조 (목적)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '(주) 리더스 오브 그린 소사이어티 (이하 ‘회사\'라고 함)는 회사가 제공하고자 하는 서비스(이하 ‘회사 서비스’)를 이용하는 개인(이하 ‘이용자’ 또는 ‘개인’)의 정보(이하 ‘개인정보’)를 보호하기 위해, 개인정보보호법, 정보통신망 이용촉진 및 정보보호 등에 관한 법률 등 관련 법령을 준수하고, 서비스 이용자의 개인정보 보호 관련한 고충을 신속하고 원활하게 처리할 수 있도록 하기 위하여 다음과 같이 개인정보처리방침(이하 ‘본 방침’)을 수립합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 2조 (개인정보 처리의 원칙)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '개인정보 관련 법령 및 본 방침에 따라 회사는 이용자의 개인정보를 수집할 수 있으며 수집된 개인정보는 개인의 동의가 있는 경우에 한해 제3자에게 제공될 수 있습니다. 단, 법령의 규정 등에 의해 적법하게 강제되는 경우 회사는 수집한 이용자의 개인정보를 사전에 개인의 동의 없이 제3자에게 제공할 수도 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 3조(본 방침의 공개)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 이용자가 언제든지 쉽게 본 방침을 확인할 수 있도록 회사 홈페이지 첫화면 또는 첫 화면과의 연결화면을 통해 본 방침을 공개하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 4조(본 방침의 변경)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 본 방침은 개인정보 관련 법령, 지침, 고시 또는 정부나 회사 서비스의 정책이나 내용의 변경에 따라 개정될 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 제1항에 따라 본 방침을 개정하는 경우 다음 각 호 하나 이상의 방법으로 공지합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '1. 회사가 운영하는 인터넷 홈페이지의 첫 화면의 공지사항란 또는 별도의 창을 통하여 공지하는 방법.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '2. 서면·모사전송·전자우편 또는 이와 비슷한 방법으로 이용자에게 공지하는 방법',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제2장 수집하는 개인정보 및 수집· 이용목적
              Text(
                '제2장 수집하는 개인정보 및 수집· 이용목적',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 5조(개인정보 수집 목적)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회원관리 및 이용자 식별 : 회원 가입의사 확인, 회원제 서비스 제공, 회원자격 유지관리',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 민원사무 처리 : 민원인의 신원 확인, 민원사항 확인, 사실조사를 위한 연락•통지, 처리결과 통보, 각종 고지 및 통지, 고충처리, 분쟁 조정을 위한 기록 보존 등',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 재화 또는 서비스 제공 : 물품배송, 서비스 제공, 콘텐츠 제공, 맞춤 서비스 제공, 연령인증, 요금결제정산, 서비스 부정이용 방지 등',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 마케팅 및 광고에의 활용 : 신규 서비스(제품) 개발 및 맞춤 서비스 제공, 이벤트 및 광고성 정보 제공 및 참여기회 제공 , 인구통계학적 특성에 따른 서비스 제공 및 광고 게재 , 서비스의 유효성 확인, 접속빈도 파악 또는 회원의 서비스 이용에 대한 통계 등',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 6조(회원가입을 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자에게 회사의 서비스를 제공하기 위하여 다음과 같은 정보를 수집합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '개인이용자 : 이메일, 비밀번호, 성별, 생년월일, 휴대전화 번호, 이름 ,CI',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '기업이용자 : 아이디, 비밀번호, 담당자 이름, 담당자 이메일, 담당자 휴대전화 번호, 사업자 등록번호, 회사명, 대표자명',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 선택 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '연령대, 배송지 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 7조(본인인증을 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '이름, 생년월일, 성별, 휴대폰 번호, 본인확인값(CI, DI), 이동통신사, 아이핀 정보(아이핀 확인 시), 내/외국인 여부',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 8조(법정대리인 동의를 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '보호자 이름, 보호자 생년월일, 보호자 성별, 보호자 내/외국인 여부, 보호자 휴대폰 번호, 보호자 이동통신사 정보, 보호자 아이핀 정보(아이핀 확인 시), 보호자 본인확인값(CI, DI)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제9조(결제서비스를 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자에게 회사의 결제 서비스를 이용하게 하기 위하여 다음과 같은 정보를 수집합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '카드번호, 카드비밀번호, 유효기간, 생년월일 6자리(yy/mm/dd), 은행명, 계좌번호',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 선택 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '이메일 주소',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 10조(현금영수증발행을 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '휴대폰번호, 현금영수증 카드번호',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 11조(회사서비스제공을 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 상품 구매 시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '필수항목 : 구매자 정보(이름, 이메일, 핸드폰번호, 전화번호), 수령자 정보(성명, 전화번호, 휴대전화번호, 주소)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '선택항목 : 환불계좌 정보(은행, 계좌번호, 예금주)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 비회원 구매 시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '필수항목 : 구매자 정보(성명, 전화번호, 휴대전화 번호, 이메일,) 수령자 정보(성명, 전화번호, 휴대전화번호, 주소)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '선택항목 : 환불계좌 정보(은행, 계좌번호, 예금주)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 커스터마이징 이용 시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '선택항목 : 키, 몸무게 등의 개인 신체사이즈 정보, 선호 스타일 등 취향 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 제품(스타일, 포토, 일반)후기 작성시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '선택항목: 키, 몸무게, 성별',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑤ 서비스 이용과정에서 자동 수집 정보 : IP정보, 디바이스 또는 브라우저 정보, 쿠키, 방문 일시, 서비스 이용 기록, 불량 이용 기록',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑥서비스 이용과정에서 자동 수집 정보 : IP정보, 디바이스 또는 브라우저 정보, 쿠키, 방문 일시, 서비스 이용 기록, 불량 이용 기록',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 12조(서비스 이용 및 부정이용 확인을 위한 정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자의 서비스 이용 및 부정이용의 확인 및 분석을 위하여 다음과 같은 정보를 수집합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 필수 수집 정보',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '서비스 이용기록, 쿠키, 접속지 정보, 기기정보, 불량 이용 기록, 방문 일시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 13조(민감정보)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '민감정보란 사상·신념, 노동조합·정당의 가입·탈퇴, 정치적 견해, 건강, 성생활 등에 관한 정보, 그 밖에 정보주체의 사생활을 현저히 침해할 우려가 있는 개인정보를 말합니다. 따라서 회사는 원칙적으로 수집하지 아니하며, 법령에 의해 수집의무가 있는 등 부득이한 경우에는 반드시 이용자의 동의를 구하고 수집하겠습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제3장 개인정보 수집의 방법
              Text(
                '제3장 개인정보 수집의 방법',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 14조(개인정보 수집 방법)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 다음과 같은 방법으로 이용자의 개인정보를 수집합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 웹페이지, 휴대폰 어플리케이션, 서면양식, 팩스, 전화, 고객센터, 상담게시판, 이메일, 이벤트 응모',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 생성정보 수집 툴을 통한 수집',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제4장 개인정보의 이용
              Text(
                '제4장 개인정보의 이용',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 15조(개인정보의 이용)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 개인정보를 회원관리, 서비스 개발・제공 및 향상, 안전한 인터넷 이용환경 구축 등 다음 각 호의 경우에 이용합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 회원 가입 의사의 확인, 연령 확인 및 법정대리인 동의 진행, 이용자 및 법정대리인의 본인 확인, 이용자 식별, 회원탈퇴 의사의 확인 등 회원관리를 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 콘텐츠 등 기존 서비스 제공(광고 포함)에 더하여, 인구통계학적 분석, 서비스 방문 및 이용 기록의 분석, 개인정보 및 관심에 기반한 이용자 간 관계의 형성, 지인 및 관심사 등에 기반한 맞춤형 서비스 제공 등 신규 서비스 요소의 발굴 및 기존 서비스 개선을 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 법령 및 회사 이용약관을 위반하는 회원에 대한 이용 제한 조치, 부정 이용 행위를 포함하여 서비스의원활한 운영에 지장을 주는 행위에 대한 방지 및 제재, 계정도용 및 부정 거래방지, 약관 개정 등의 고지사항 전달, 분쟁조정을 위한 기록 보존, 민원처리 등 이용 자 보호 및 서비스 운영을 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 유료 서비스 제공에 따르는 본인인증, 구매 및 요금 결제, 상품 및 서비스의 배송을 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑤ 이벤트 정보 및 참여기회 제공, 광고성 정보 제공 등 마케팅 및 프로모션을 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑥ 서비스 이용기록과 접속 빈도 분석, 서비스 이용에 대한 통계, 서비스 분석 및 통계에 따른 맞춤 서비스 제공 및 광고 게재를 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑦ 보안, 프라이버시, 안전 측면에서 이용자가 안심하고 이용할 수 있는 서비스 이용환경 구축을 위한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제5장 개인정보의 제3자 제공
              Text(
                '제5장 개인정보의 제3자 제공',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 16조(개인정보 제3자 제공 금지)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 개인정보의 수집·이용목적에서 고지한 범위에서 개인정보를 이용하며, 이용자의 사전 동의 없이 개인정보 수집이용 목적범위를 초과하여 이용하거나 제3자에게 제공하지 않습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '다만, 아래의 경우에는 예외로 합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자들이 사전에 공개에 동의한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 기타 법에 의해 요구된다고 선의로 판단되는 경우 (ex. 관련법에 의거 적법한 절차에 의한 정부기관의 요청이 있는 경우 등)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 17조(사전동의 등에 따른 개인정보의 제공)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '본 장에서 정하는 용어의 정의는 다음과 같습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자가 개인정보 제공에 사전에 동의한 경우에 한하여 개인정보를 제공하고 있으며, 개인정보의 제3자 제공에 대한 동의를 거부하시는 경우에도 기본 서비스를 이용하실 수 있으나 제3자 제공에 기반한 서비스의 이용 및 제공이 제한될 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '제공받는자',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '목적',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '항목',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '보유기간',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('입점사 ', style: theme.textTheme.bodyMedium),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '판매자와 구매자의 거래의 원활한 진행, 본인의사의 확인, 고객 상담 및 불만처리, 상품과 경품 배송을 위한 배송지 확인 등',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '구매자 성명, 전화번호, ID, 휴대폰 번호, 상품 구매정보, 상품 수취인 정보(성명, 주소, 전화번호)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '서비스 제공기간(관계법령의 규정에 의하여 보존할 필요가 있는 경우 및 사전 동의를 득한 경우 해당 보유 기간)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ESG 친환경 캠페인 운영 기업/단체 등',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '그린스퀘어 서비스를 통한 ESG 활동, 혹은 그린스퀘어에서 기업/단체와 함께하는 ESG 활동을 수행하고 알리기 위함',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '입점사와 상동',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '입점사와 상동',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '제 18조(법령 등에 따른 개인정보의 제공)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 다음 각호의 어느 하나에 해당하는 경우에는 이용자의 동의 없이 이용자의 개인정보를 수집·이용할 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 정보통신서비스의 제공에 관한 계약을 이행하기 위하여 필요한 개인정보로서 경제적·기술적인  사유로 통상적인 동의를 받는 것이 뚜렷하게 곤란한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 정보통신서비스의 제공에 따른 요금정산을 위하여 필요한 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 법령에 개인정보 제공에 관한 특별한 규정이 있는 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제6장 개인정보의 처리 위탁
              Text(
                '제6장 개인정보의 처리 위탁',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 19조(개인정보의 처리 위탁)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 원활한 서비스 제공과 효과적인 업무를 처리하기 위하여 다음 각 호와 같이 개인정보를 처리 위탁하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Table(
                border: TableBorder.all(),
                children: [
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '제공받는 자',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '제공목적',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '제공정보',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '보유 및 이용기간',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'CODE GREEN SQUARE 콜라보/협약 업체',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '서비스 및 상품 제공, 구매자 확인, 해피콜',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '성명, 휴대전화번호, 그린스퀘어 솔루션을 활용한 친환경 실천 참여 인증 사진 ※ 서비스 유형에 따라 (배송지)주소가 제한적으로 제공될 수 있습니다.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '재화 또는 서비스의 제공 목적이 달성 된 후 파기 (단, 관계법령에 정해진 규정에 따라 법정기간 동안 보관)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'ESG 친환경 캠페인 운영 기업/단체 등',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '그린스퀘어 서비스를 통한 ESG 활동, 혹은 그린스퀘어에서 기업/단체와 함께하는 ESG 활동을 위함',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '구매자 성명, 전화번호, ID, 휴대폰 번호, 상품 구매정보, 상품 수취인 정보(성명, 주소, 전화번호), 그린스퀘어 솔루션을 활용한 친환경 실천 참여 인증 사진',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '재화 또는 서비스의 제공 목적이 달성 된 후 파기 (단, 관계법령에 정해진 규정에 따라 법정기간 동안 보관)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'CODE GREEN SQUARE 서비스 협력 업체',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '서비스 및 상품 제공, 구매자(서비스 피제공자) 확인, 해피콜',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '성명, 휴대전화번호, 그린스퀘어 솔루션을 활용한 친환경 실천 참여 인증 사진 ※ 서비스 유형에 따라 (배송지)주소가 제한적으로 제공될 수 있습니다.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '재화 또는 서비스의 제공 목적이 달성 된 후 파기 (단, 관계법령에 정해진 규정에 따라 법정기간 동안 보관)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '배송 위탁 업체 alc 3자 물류 대행',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '서비스 제공, 구매자 확인, 해피콜',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '성명, 휴대전화번호, 배송지주소, 이메일 ※ 구매자와 수취인이 다를 경우에는 수취인의 정보(해외 배송 상품은 개인고유통관부호 포함)가 제공될 수 있습니다.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '재화 또는 서비스의 제공 목적이 달성 된 후 파기 (단, 관계법령에 정해진 규정에 따라 법정기간 동안 보관)',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '관할 세무서',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '국세청 고시에 따른 주류 통신판매 주문에 대한 분기별 명세 세무서 제공',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '구입자 인적사항(주소, 성명, 생년월일), 주문일자, 상품명, 수량, 주문금액',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('', style: theme.textTheme.bodyMedium),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '※ 개인정보 제3자 제공은 필요 서비스 발생 시에만 이루어집니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제7장 개인정보의 보유 및 이용 기간
              Text(
                '제7장 개인정보의 보유 및 이용 기간',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 20조(개인정보의 보유 및 이용기간)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 이용자의 개인정보에 대해 개인정보의 수집·이용 목적이 달성을 위한 기간동안 개인정보를 보유 및 이용합니다.개인정보 수집 및 이용목적이 달성된 후에는 해당 정보를 파기합니다.. 단, 후항과 제21조에 따라 일부 정보는 달성 후에도 보관할 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 전항에도 불구하고 회사는 내부 방침에 의해 서비스 부정이용기록은 부정 가입 및 이용 방지를 위하여 회원 탈퇴 시점으로부터 최대 1년간 보관합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제21조(법령에 따른 개인정보의 보유 및 이용기간)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 관계법령에 따라 다음과 같이 개인정보를 보유 및 이용합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '① 전자상거래 등에서의 소비자보호에 관한 법률에 따른 보유정보 및 보유기간',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 계약 또는 청약철회 등에 관한 기록 : 5년',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 대금결제 및 재화 등의 공급에 관한 기록 : 5년',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 통신비밀보호법에 따른 보유정보 및 보유기간',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 웹사이트 로그 기록 자료 : 3개월',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 전자금융거래법에 따른 보유정보 및 보유기간',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 전자금융거래에 관한 기록 : 5년',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 위치정보의 보호 및 이용 등에 관한 법률',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 개인위치정보에 관한 기록 : 6개월',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제8장 개인정보의 파기절차 및 방법
              Text(
                '제8장 개인정보의 파기절차 및 방법',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제 22조(개인정보의 파기원칙)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 원칙적으로 이용자의 개인정보 처리 목적의 달성, 보유·이용기간의 경과 등 개인정보가 필요하지 않을 경우에는 해당 정보를 지체 없이 파기합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 23조(서비스 미이용자에 대한 개인정보 처리)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 1년 동안 회사의 서비스를 이용하지 않은 이용자의 개인정보는 원칙적으로 이용자에게 사전통지하고 개인정보를 파기하거나 별도로 분리하여 저장 합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 장기 미이용 이용자의 개인정보는 별도로 분리되어 안전하게 보관하게 되며, 해당 이용자의 통지는 분리 보관 처리 일을 기준으로 최소 30일 이전에 전자우편주소로 전송됩니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 장기 미이용 이용자는 회사가 미이용자 DB를 별도로 분리하기 전에 계속 서비스를 이용하고자하는 경우 웹사이트(이하 ‘모바일앱’ 포함)에 로그인 하시면 됩니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 장기 미이용 이용자는 웹사이트에 로그인할 경우 이용자의 동의에 따라 본인의 계정을 복원할 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑤ 회사는 분리보관된 개인정보를 4년간 보관 후 지체없이 파기합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 24조(개인정보파기절차)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자가 회원가입 등을 위해 입력한 정보는 개인정보 처리 목적이 달성된 후 별도의 DB로 옮겨져(종이의 경우 별도의 서류함) 내부 방침 및 기타 관련 법령에 의한 정보보호 사유에 따라(보유 및 이용기간 참조) 일정 기간 저장된 후 파기 되어집니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 파기 사유가 발생한 개인정보를 개인정보보호 책임자의 승인절차를 거쳐 파기 합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제 25조(개인정보파기방법)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 전자적 파일형태로 저장된 개인정보는 기록을 재생할 수 없는 기술적 방법을 사용하여 삭제하며, 종이로 출력된 개인정보는 분쇄기로 분쇄하거나 소각 등을 통하여 파기합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제9장 영리목적의 광고성 정보 전송 제한
              Text(
                '제9장 영리목적의 광고성 정보 전송 제한',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제26조(광고정보의 전송 조치)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 전자적 전송매체를 이용하여 영리목적의 광고성 정보를 전송하는 경우 이용자의 명시적인 사전동의를 받습니다. 다만, 다음 각호 어느 하나에 해당하는 경우에는 사전 동의를 받지 않습니다.   \n1. 회사가 재화등의 거래관계를 통하여 수신자로부터 직접 연락처를 수집한 경우, 거래가 종료된 날로부터 6개월 이내에 회사가 처리하고 수신자와 거래한 것과 동종의 재화등에 대한 영리목적의 광고성 정보를 전송하려는 경우\n2. 「방문판매 등에 관한 법률」에 따른 전화권유판매자가 육성으로 수신자에게 개인정보의 수집출처를 고지하고 전화권유를 하는 경우',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 전항에도 불구하고 수신자가 수신거부의사를 표시하거나 사전 동의를 철회한 경우에는 영리목적의 광고성 정보를 전송하지 않으며 수신거부 및 수신동의 철회에 대한 처리 결과를 알립니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 회사는 오후 9시부터 그 다음 날 오전 8시까지의 시간에 전자적 전송매체를 이용하여 영리목적의 광고성 정보를 전송하는 경우에는 제1항에도 불구하고 그 수신자로부터 별도의 사전 동의를 받습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 회사는 전자적 전송매체를 이용하여 영리목적의 광고성 정보를 전송하는 경우 다음 각 호의 사항 등을 광고성 정보에 구체적으로 밝힙니다.\n1. 회사명 및 연락처   \n2. 수신의 거부 또는 수신동의의 철회 의사표시에 관한 사항의 표시',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '⑤ 회사는 전자적 전송매체를 이용하여 영리목적의 광고성 정보를 전송하는 경우 다음 각 호의 어느 하나에 해당하는 조치를 하지 않습니다.\n1. 광고성 정보 수신자의 수신거부 또는 수신동의의 철회를 회피·방해하는 조치\n2. 숫자·부호 또는 문자를 조합하여 전화번호·전자우편주소 등 수신자의 연락처를 자동으로 만들어 내는 조치\n3. 영리목적의 광고성 정보를 전송할 목적으로 전화번호 또는 전자우편주소를 자동으로 등록하는 조치\n4. 광고성 정보 전송자의 신원이나 광고 전송 출처를 감추기 위한 각종 조치\n5. 영리목적의 광고성 정보를 전송할 목적으로 수신자를 기망하여 회신을 유도하는 각종 조치',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제10장 아동의 개인정보보호
              Text(
                '제10장 아동의 개인정보보호',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제27조(아동의 개인정보보호)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 만 14세미만 아동의 개인정보 보호를 위하여 만 14세 이상의 이용자에 한하여 회원가입을 허용합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제11장 이용자 및 법정대리인의 권리와 그 행사방법 등
              Text(
                '제11장 이용자 및 법정대리인의 권리와 그 행사방법 등',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제28조(개인정보 수집철회 등)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자 및 법정 대리인은 언제든지 등록되어 있는 자신의 개인정보를 조회하거나 수정할 수 있으며 개인정보수집 동의 철회를 요청할수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 이용자 및 법정 대리인은 자신의 가입정보 수집등에 대한 동의를 철회하기 위해서는 개인정보보호책임자 또는 담당자에게 서면, 전화 또는 전자우편주소로 연락하시면 회사는 지체 없이 조치하겠습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제29조(개인정보 정보변경 등)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자는 회사에게 전조의 방법을 통해 개인정보의 오류에 대한 정정을 요청할 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 전항의 경우에 개인정보의 정정을 완료하기 전까지 개인정보를 이용 또는 제공하지 않으며 잘못된 개인정보를 제3자에게 이미 제공한 경우에는 정정 처리결과를 제3자에게 지체 없이 통지하여 정정이 이루어지도록 하겠습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제30조(이용자의 의무)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자는 자신의 개인정보를 최신의 상태로 유지해야 하며, 이용자의 부정확한 정보 입력으로 발생하는 문제의 책임은 이용자 자신에게 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 타인의 개인정보를 도용한 회원가입의 경우 이용자 자격을 상실하거나 관련 개인정보보호 법령에 의해 처벌 받을 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 이용자는 전자우편주소, 비밀번호 등에 대한 보안을 유지할 책임이 있으며 제3자에게 이를 양도하거나 대여 할 수 없습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제12장 개인정보의 기술적·관리적 보호대책
              Text(
                '제12장 개인정보의 기술적·관리적 보호대책',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제31조(회사의 개인정보 관리)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자의 개인정보를 처리함에 있어 개인정보가 분실, 도난, 유출, 변조, 훼손 등이 되지 아니하도록 안전성을 확보하기 위하여 다음과 같이 기술적·관리적 보호대책을 강구하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제32조(삭제된 정보의 처리)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자 혹은 법정 대리인의 요청에 의해 해지 또는 삭제된 개인정보는 회사가 수집하는 &quot;개인정보의 보유 및 이용기간&quot;에 명시된 바에 따라 처리하고 그 외의 용도로 열람 또는 이용할 수 없도록 처리하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제33조(비밀번호의 암호화)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이용자의 중요 개인정보(계좌번호 등)는 암호화하여 저장/관리되고 있으며, 암호화통신 등을 통하여 네트워크상에서 개인정보를 안전하게 전송할 수 있도록 하고 있습니다. 비밀번호는 복호화가 불가능한 일방향 암호화되어 저장/관리되고 있습니다. 개인정보의 확인 및 변경은 비밀번호를 알고 있는 본인에 의해서만 가능합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제34조(해킹 등에 대비한 대책)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 해킹, 컴퓨터 바이러스 등 정보통신망 침입에 의해 이용자의 개인정보가 유출되거나 훼손되는 것을 막기 위해 최선을 다하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 회사는 최신 백신프로그램을 이용하여 이용자들의 개인정보나 자료가 유출되거나 손상되지 않도록 방지하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '③ 회사는 만일의 사태에 대비하여 침입차단 시스템을 이용하여 보안에 최선을 다하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '④ 회사는 민감한 개인정보의 경우 암호화 통신 등을 통하여 네트워크상에서 개인정보를 안전하게 전송할 수 있도록 하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제35조(개인정보 처리 최소화 및 교육)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 개인정보 관련 처리 담당자를 최소한으로 제한하며, 개인정보 처리자에 대한 교육 등 관리적 조치를 통해 법령 및 내부방침 등의 준수를 강조하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제36조(개인정보보호 전담담당부서 운영)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 개인정보의 보호를 위해 개인정보보호 전담부서를 운영하고 있으며, 개인정보처리방침의 이행사항 및 담당자의 준수여부를 확인하여 문제가 발견될 경우 즉시 해결하고 바로 잡을 수 있도록 최선을 다하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제13장 개인정보유출등의 통지 및 신고
              Text(
                '제13장 개인정보유출등의 통지 및 신고',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제37조(개인정보 유출등에 대한 조치)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 회사는 개인정보의 분실·도난·유출(이하 &quot;유출 등&quot;이라 한다) 사실을 안 때에는 지체 없이 다음 각 호의 모든 사항을 해당 이용자에게 알리고 방송통신위원회 또는 한국인터넷진흥원에 신고합니다.\n1. 유출 등이 된 개인정보 항목\n2. 유출 등이 발생한 시점\n3. 이용자가 취할 수 있는 조치\n4. 정보통신서비스 제공자등의 대응 조치\n5. 이용자가 상담 등을 접수할 수 있는 부서 및 연락처',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제38조(개인정보 유출등에 대한 조치의 예외)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 전조에도 불구하고 이용자의 연락처를 알 수 없는 등 정당한 사유가 있는 경우에는 회사의 홈페이지에 30일 이상 게시하는 방법으로 전조의 통지를 갈음하는 조치를 취할 수 있습니다',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제14장 개인정보 자동수집장치의 설치/운영 및 거부에 관한 사항
              Text(
                '제14장 개인정보 자동수집장치의 설치/운영 및 거부에 관한 사항',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제39조(이용자의 쿠키설치선택권)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '① 이용자는 쿠키 설치에 대한 선택권을 가지고 있습니다. 따라서 이용자는 웹브라우저에서 옵션을 설정함으로써 모든 쿠키를 허용하거나, 쿠키가 저장될 때마다 확인을 거치거나, 아니면 모든 쿠키의 저장을 거부할 수도 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '② 다만, 쿠키의 저장을 거부할 경우에는 로그인이 필요한 회사의 일부 서비스는 이용에 어려움이 있을 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제40조(쿠키 설치 허용 지정방법)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이용자는 쿠키 설치에 대한 선택권을 가지고 있으며, 웹브라우저별 옵션 선택을 통해 모든 쿠키를 허용 또는 거부 하거나, 쿠키가 저장될 때마다 확인을 거치도록 할 수 있습니다. 쿠키 설치 허용여부를 지정하는 방법은 다음과 같습니다. 이용자는 회사의 서비스를 이용한 후 반드시 계정을 로그아웃하고 웹 브라우저 프로그램을 종료해야 합니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '•Internet Explorer : 도구(메뉴) &amp;gt 인터넷옵션 &amp;gt 개인정보(탭) &amp;gt 고급&amp;gt 개인정보처리 수준 설정\n•Chrome : 설정(메뉴) &amp;gt 고급설정 표시 선택 &amp;gt 개인정보-콘텐츠 설정 &amp;gt 쿠키 수준 설정 (단, 쿠키의 저장을 거부하였을 경우에는 로그인이 필요한 서비스 등 일부 서비스 이용에 어려움이 있을 수 있습니다.)',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              // 제15장 개인정보보호책임자지정
              Text(
                '제15장 개인정보보호책임자지정',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                '제41조(회사의 개인정보 보호 책임자 지정)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '회사는 이용자의 개인정보를 보호하고 개인정보와 관련한 불만을 처리하기 위하여 아래와 같이 관련 부서 및 개인정보 보호 책임자를 지정하고 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '가. 개인정보 보호책임자\n- 성명 : 임관섭\n- 연락처 : 02-926-0727\n- 이메일 : sup.ceo@codegreen.io',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제42조(이용자의 민원처리)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이용자는 회사의 서비스를 이용하며 발생하는 모든 개인정보보호 관련 민원을 개인정보 보호 책임자에게 신고할 수 있습니다. 회사는 이용자의 신고사항에 대해 신속하게 충분한 답변을 드릴 것입니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '제43조(이용자의 기관문의)',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이용자는 기타 개인정보침해에 대한 신고나 상담이 필요하신 경우에는 아래 기관에 문의할 수 있습니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '- 개인분쟁조정위원회 (http://kopico.or.kr / 02-405-5150)\n- 개인정보침해신고센터 (http://privacy.kisa.or.kr / 국번없이 118)\n- 경찰청 사이버테러대응센터 (http://www.netan.go.kr / 국번없이:182)\n- 대검찰청 사이버수사과 : http://www.spo.go.kr / (국번 없이) 1301',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                '부칙',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '제1조',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '본 방침은 2020. 09. 01. 부터 시행됩니다.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
