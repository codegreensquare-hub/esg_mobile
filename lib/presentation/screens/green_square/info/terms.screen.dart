import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';

class GreenSquareTermsScreen extends StatelessWidget {
  const GreenSquareTermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1E1E1E),
    );
    final metaLabelStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF2D2D2D),
      height: 1.6,
    );
    final metaValueStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w400,
      color: const Color(0xFF2D2D2D),
      height: 1.6,
    );
    final chapterStyle = theme.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
      height: 1.5,
    );
    final articleLabelStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
      color: const Color(0xFF1C1C1C),
      height: 1.5,
    );
    final articleBodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF3B3B3B),
      height: 1.75,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: const Color(0xFF3B3B3B),
      height: 1.75,
    );

    return GreenSquareInfoPage(
      title: '그린스퀘어 이용약관',
      backgroundColor: kPolicyPageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text('그린스퀘어 이용약관', style: titleStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: '운영사:', style: metaLabelStyle),
                    TextSpan(
                      text: ' 주식회사 리더스 오브 그린 소사이어티(이하 “회사”)',
                      style: metaValueStyle,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제1장 총칙', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제1조(목적)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 12),
              child: Text(
                '이 약관은 회사가 운영하는 그린스퀘어 및 관련 제반 서비스(이하 “서비스”)를 이용함에 있어 회사와 회원 간의 권리·의무 및 책임사항, 이용조건과 절차, 분쟁 해결 기준 등을 규정함을 목적으로 합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제2조(정의)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① “서비스”란 회원의 단말기(모바일, 태블릿PC 등 유무선 장치 포함)를 통하여 회사가 제공하는 그린스퀘어 관련 서비스 일체를 말합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② “회원”이란 이 약관에 동의하고 회사가 제공하는 가입수단(카카오/애플/직접가입 등)으로 이용계약을 체결하여 서비스를 이용하는 자를 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ “가입수단”이란 (1) 카카오 계정 연동, (2) 애플 계정 연동, (3) 직접 회원가입(이메일, 휴대전화번호 등 회사가 지정한 방식)을 말하며, 회사는 운영상 필요에 따라 가입수단을 추가·변경할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '④ “제휴사”란 회사와 계약을 통해 캠페인(미션) 운영, 리워드 제공, 상품 판매(입점) 등 서비스를 함께 제공하는 사업자·단체를 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑤ “제휴판매자”란 회사가 제공하는 통신판매중개 서비스를 통하여 상품·서비스 등을 판매할 목적으로 판매자 약관을 승인하거나 회사와 별도 계약을 체결한 자를 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑥ “직접판매 상품”이란 회사가 통신판매업자로서 판매하는 재화·용역을 말하고, “중개판매 상품”이란 제휴판매자가 판매하고 회사가 통신판매를 중개하는 재화·용역을 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑦ “캠페인/미션”이란 회원의 친환경 실천을 유도하기 위해 회사 또는 제휴사가 기획·운영하는 참여형 과제를 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑧ “인증자료”란 미션 수행을 확인하기 위해 회원이 제출하는 사진, 텍스트, (별도 동의한 경우) 위치정보, 기타 로그를 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑨ “마일리지”란 유상 구매/충전 없이 서비스 이용 및 미션 수행 등에 따라 부여되는 비현금성 포인트로서, 회사가 정한 사용처(자사몰·제휴 기프티콘 등)에서 사용할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑩ “쿠폰”이란 회사 또는 제휴판매자가 회원에게 할인·혜택 제공 목적 등으로 발급하는 것을 말합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑪ 이 약관에서 정하지 아니한 용어는 관계 법령 및 상관례에 따릅니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제3조(약관의 게시, 개정 및 효력)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 이 약관의 내용을 회원이 쉽게 알 수 있도록 서비스 화면에 게시합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 관련 법령을 위반하지 않는 범위에서 약관을 개정할 수 있으며, 적용일자 및 개정사유를 명시하여 적용일자 7일 전부터 공지합니다. 회원에게 불리한 변경은 최소 30일 전부터 사전 유예기간을 두고 공지하며, 개정 전·후 내용을 명확히 비교하여 표시합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 법령상 별도 동의가 필요한 변경(예: 개인정보 제3자 제공 항목·목적·보유기간 변경, 마케팅 채널 추가, 정밀 위치정보 처리 개시, 인증사진 2차 활용 목적 추가 등)이 포함되는 경우 회사는 별도의 동의를 받습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '④ 회원은 변경 약관에 동의하지 않을 수 있으며, 이 경우 서비스 이용을 중단하거나 탈퇴할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제2장 회원가입 및 계정', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제5조(회원가입)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 이용자는 약관 동의 및 회사가 정한 절차(가입수단 선택, 필수정보 입력, 본인/보호자 인증 등)를 완료함으로써 회원가입을 신청합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 다음 각 호에 해당하는 경우 가입 신청을 승낙하지 않거나 사후 이용계약을 해지할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('1. 타인의 명의 도용, 허위 정보 제공', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '2. 법령 또는 약관 위반 이력이 중대하여 재가입 제한이 필요한 경우',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '3. 만 14세 미만 아동이 법정대리인 동의·동의 확인을 완료하지 않은 경우(제6조)',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('4. 기타 합리적 사유로 승낙이 곤란한 경우', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '제6조(만 14세 미만 아동의 가입 및 법정대리인 동의)',
                style: articleLabelStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 만 14세 미만 아동의 가입을 허용합니다. 이 경우 회사는 법정대리인의 동의를 받고 동의 여부를 확인합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 동의 확인 방식은 보호자 휴대전화 본인인증을 기본으로 하며, 법령이 허용하는 범위에서 신용/직불카드, 서면, 전자우편 등 보완 수단을 병행할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회사는 법정대리인 동의를 위해 필요한 최소한의 정보만 수집하며, 아동에게 이해하기 쉬운 고지 화면을 제공합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제7조(계정의 관리)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원은 계정의 비밀번호·인증수단을 안전하게 관리할 책임이 있으며, 이를 제3자에게 양도·대여할 수 없습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 부정이용 방지 및 보안상 필요 시 추가 인증 또는 일부 기능 제한을 할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제8조(회원에 대한 통지)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사가 회원에 대한 통지를 하는 경우, 회원이 회사에 제공한 이메일, 휴대전화번호, 앱 푸시 등 합리적인 수단으로 할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 불특정 다수에 대한 통지는 서비스 내 공지사항 게시로 갈음할 수 있으나, 회원의 거래 또는 권리에 중대한 영향을 미치는 사항은 개별 통지를 원칙으로 합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제9조(회원탈퇴)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원은 서비스 내 설정에서 언제든 탈퇴할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 탈퇴 시 미사용 마일리지·쿠폰은 제23조에 따라 처리됩니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회사는 탈퇴 화면에서 ‘잔여 마일리지 즉시 소멸’을 명확히 고지하고, 회원의 확인을 받은 후 탈퇴를 완료합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제10조(이용 제한)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 회원의 약관 위반, 부정행위(어뷰징), 타인의 권리 침해, 법령 위반 등 정당한 사유가 있는 경우 이용을 제한할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 원칙적으로 이용 제한 전에 사전 통지하고 소명 기회를 부여합니다. 다만, 계정 탈취·사기 등 긴급한 위험을 방지하기 위한 경우 사후 통지할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 이용 제한의 기준·절차·기간은 운영정책에 따르며, 회원은 이의제기(제22조)를 할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제3장 서비스 제공', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제11조(서비스의 내용)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('회사는 다음 서비스를 제공합니다.', style: articleBodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '1. 캠페인/미션 참여 및 인증, 검수 결과 통지, 리워드 제공',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('2. 쇼핑 서비스(직접판매 및 통신판매중개 포함)', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('3. 마일리지 적립·사용, 쿠폰 발급·사용', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('4. 기타 회사가 정하는 서비스', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제12조(서비스의 변경 및 중단)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 운영상·기술상 필요에 따라 서비스의 전부 또는 일부를 변경할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 변경이 회원에게 중대한 불이익을 초래하는 경우 회사는 사전 공지 및 합리적 경과조치를 제공합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 설비 점검, 장애, 천재지변 등 사유로 서비스 제공이 일시 중단될 수 있으며, 회사는 가능한 범위에서 사전 안내합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제4장 전자상거래(직접판매 및 중개판매)', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제13조(직접판매와 중개판매의 구분·고지)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('① 직접판매 상품의 계약 당사자는 회사입니다.', style: articleBodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 중개판매 상품의 계약 당사자는 회원과 제휴판매자이며, 회사는 통신판매중개자입니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회사는 판매자 정보, 거래조건(가격, 배송비, 청약철회 조건 등)을 구매 전 단계에서 명확히 고지하고, 회사가 중개자임을 쉽게 알 수 있도록 표시합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제14조(구매신청 및 계약 성립)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('① 회원은 서비스 화면에서 구매를 신청합니다.', style: articleBodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사(직접판매) 또는 제휴판매자(중개판매)가 승낙 의사를 표시함으로써 계약이 성립합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회사는 미성년자와 계약을 체결하는 경우 법정대리인의 동의가 없으면 계약 취소가 가능함을 고지합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제15조(결제 및 PG 이용)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 결제는 PG사 등 결제대행을 통해 처리될 수 있으며, 회사는 원칙적으로 카드번호·비밀번호 등 결제수단 정보를 직접 저장하지 않습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 거래 확인 및 법정 의무 이행을 위해 필요한 범위에서 최소한의 거래 식별정보(승인번호/거래ID 등)를 보관할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제16조(청약철회·환불·반품)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원은 관계 법령 및 상품별 고지에 따라 청약철회(주문 취소), 환불, 반품을 요청할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 디지털 상품(기프티콘 등) 또는 즉시 사용형 상품 등은 법령이 허용하는 범위에서 청약철회가 제한될 수 있으며, 회사는 구매 전 해당 제한 사유를 명확히 고지합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 직접판매의 환불 책임은 회사가, 중개판매의 환불 책임은 제휴판매자가 원칙이나, 회사가 법령상 부담하는 책임은 예외로 합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제17조(배송 및 고객지원)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 배송/CS를 직접 수행하거나 제3자에게 위탁할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 배송 일정, 배송비 부담 주체, 반품 절차를 구매 전 고지합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제5장 캠페인/미션, 인증사진, 검수', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제18조(캠페인 운영)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사 또는 제휴사는 캠페인별 참여조건, 인증방법, 리워드, 검수기준(사유코드 포함) 등을 서비스 내 안내합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 캠페인 운영상 필요한 경우 회원에게 추가 고지·동의를 받을 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제19조(인증사진 및 식별정보 비노출)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원은 인증사진에 얼굴, 주거지, 차량번호 등 식별정보가 노출되지 않도록 주의해야 합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 가능한 범위에서 업로드 전 안내 및 자동 마스킹 기능을 제공할 수 있으며, 식별정보가 포함된 인증사진은 재업로드 요청 또는 일부 기능 제한이 있을 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '제20조(인증사진의 제휴사 제공 및 2차 활용)',
                style: articleLabelStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 캠페인 운영(검수·정산·성과확인) 목적상 필요한 경우, 회사는 인증사진을 제휴사에 제공할 수 있습니다. 이때 회사는 원본을 내부 보관하고, 제휴사에는 원칙적으로 마스킹본(식별정보 비노출)만 제공합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 홍보·외부 성과보고·2차 활용은 별도의 선택 동의로 하며, 미동의하더라도 캠페인 참여 자체는 제한되지 않습니다(단, 제휴사 제공이 캠페인 운영의 필수 요건인 경우 이를 참여 전 고지합니다).',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회사는 제휴사와 목적 제한, 재식별 금지, 보유기간 종료 후 파기, 재위탁 제한 및 보안조치를 계약으로 확보하도록 노력합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제21조(미션 검수 및 자동화된 결정)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 AI 자동화 검수 및 사람 검수를 병행할 수 있으며, 초기에는 사람 검수 비중이 포함됩니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 승인/거절 결과를 통지하고, 가능한 범위에서 거절 사유(사유코드 등)를 안내합니다. 다만, 부정행위 탐지·보안상 필요 등 정당한 사유가 있는 경우 일부 세부 사유는 제한될 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 자동화된 결정이 회원의 권리 또는 의무에 중대한 영향을 미치는 경우, 회원은 설명·검토 요구 또는 거부를 할 수 있으며 회사는 법령에 따른 필요한 조치를 합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제22조(이의제기)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원은 검수 결과 또는 이용제한 등에 대해 앱 내 기능 또는 고객센터를 통해 이의제기할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 미확인(영업일 7~14일) 내 처리 결과를 통지하도록 노력합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제6장 마일리지·쿠폰', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제23조(마일리지의 적립·사용·소멸)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 마일리지는 유상 구매/충전이 없으며 현금 환불되지 않습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 마일리지는 자사몰 결제 또는 제휴 기프티콘 등 회사가 지정한 사용처에서 사용할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('③ 마일리지는 적립일로부터 2년 후 소멸됩니다.', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '④ 회원 탈퇴 시 미사용 마일리지는 즉시 소멸하며 복구되지 않습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '⑤ 회사는 마일리지 소멸 예정 사실을 앱 내 알림 등 합리적 방식으로 사전 고지합니다(7일 전).',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제24조(오적립·부정적립의 정정 및 회수)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 시스템 오류 또는 부정행위로 발생한 오적립/부정적립 마일리지를 정정·회수할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회원은 적립 오류를 인지한 때 미확인(30일) 이내 정정을 신청할 수 있으며, 회사는 합리적 기간 내 처리합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제25조(쿠폰)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '쿠폰의 발급·사용·유효기간·회수·재발급은 쿠폰별 안내 및 운영정책에 따릅니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제7장 개인정보·마케팅·위탁', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제26조(개인정보 처리방침)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '개인정보의 수집·이용·보유기간·제3자 제공·위탁·권리행사 등은 개인정보 처리방침에 따릅니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제27조(동의의 구분 및 철회)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 수집·이용, 제3자 제공, 위탁, 마케팅, 위치정보, 인증사진 2차 활용 등 동의 사항을 구분하여 받습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회원은 회원탈퇴 없이 앱 내 설정에서 마케팅 수신 동의 및 인증사진 2차 활용 동의를 철회할 수 있습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 개인정보 처리정지 또는 동의 철회 등 권리행사는 개인정보 처리방침에서 정한 절차에 따릅니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제28조(마케팅 수신 동의)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 마케팅 수신 동의는 기본값 OFF이며, 푸시/SMS·LMS·MMS/이메일/카카오 알림톡 등 채널별 옵트인으로 받습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 마케팅 동의를 거부하거나 철회해도 서비스 이용은 제한되지 않습니다(단, 마케팅 동의가 전제된 별도 이벤트는 사전 고지).',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text('③ 회사는 수신거부/철회 요청을 지체 없이 반영합니다.', style: bodyStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제29조(위탁 및 재위탁)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 배송, CS, 캠페인 운영 등 업무를 위탁할 수 있으며, 수탁사 및 재위탁 현황은 개인정보 처리방침 또는 별도 공개 페이지에 게시합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 수탁사와 목적 외 처리금지, 기술적·관리적 보호조치, 재위탁 제한, 파기 등을 포함하는 계약을 체결하도록 노력합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제8장 위치기반서비스(별도 약관)', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제30조(위치기반서비스의 제공)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회사는 미션 검증 및 통계(탄소저감) 목적을 위해 정밀 개인위치정보를 수집·이용할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 위치기반서비스사업 신고 및 별도 위치기반서비스 이용약관 마련·공개 및 별도 동의 완료 전에는 정밀 개인위치정보 수집 기능을 제공하지 않습니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 원시 위치정보는 이벤트 종료 후 30일 보관 후 파기하며, 제공 이력 등 법정 기록은 별도로 보관합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '④ 제휴사 제공 좌표는 원칙적으로 격자화/라운딩 등으로 최소화합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제9장 게시물 및 지식재산권', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제31조(게시물의 이용)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '① 회원이 서비스에 게시한 콘텐츠는 서비스 제공·운영 및 프로모션에 필요한 한도에서 노출·편집될 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '② 회사는 회원 게시물을 제3자에게 제공하거나 2차 활용하고자 하는 경우, 관련 법령에 따라 사전 동의를 받습니다(제20조제2항 포함).',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '③ 회원은 게시물 삭제·비공개 등을 요청할 수 있으며, 회사는 관계 법령 및 운영정책에 따라 처리합니다.',
                style: bodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 14),
              child: Text('제10장 책임 및 분쟁해결', style: chapterStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제32조(회사의 의무)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '회사는 관계 법령 및 약관을 준수하며, 안정적인 서비스 제공을 위해 노력합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제33조(손해배상)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '회사의 고의 또는 과실로 회원에게 손해가 발생한 경우 회사는 관계 법령에 따라 손해를 배상합니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제34조(분쟁해결)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '분쟁이 발생한 경우 회사와 회원은 성실히 협의하여 해결하도록 노력합니다. 필요 시 관계 법령에 따른 소비자분쟁조정 절차를 이용할 수 있습니다.',
                style: articleBodyStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('제35조(준거법 및 관할)', style: articleLabelStyle),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, bottom: 8),
              child: Text(
                '본 약관은 대한민국 법령을 준거법으로 하며, 소송은 민사소송법 등 관계 법령에 따른 관할법원에 제기합니다.',
                style: articleBodyStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
