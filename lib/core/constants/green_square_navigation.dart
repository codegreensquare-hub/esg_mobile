import 'package:flutter/material.dart';

class GreenSquareNavItem {
  const GreenSquareNavItem({
    required this.index,
    required this.label,
    required this.icon,
  });

  final int index;
  final String label;
  final IconData icon;
}

const greenSquareNavItems = <GreenSquareNavItem>[
  GreenSquareNavItem(
    index: 0,
    label: '스토리',
    icon: Icons.auto_stories_outlined,
  ),
  GreenSquareNavItem(
    index: 1,
    label: '쇼핑몰',
    icon: Icons.storefront_outlined,
  ),
  GreenSquareNavItem(
    index: 2,
    label: '미션 참여',
    icon: Icons.group_outlined,
  ),
  GreenSquareNavItem(
    index: 3,
    label: '나의 콕',
    icon: Icons.person_outline,
  ),
];

enum GreenSquareDrawerTarget {
  brandStory,
  partnershipInquiry,
  aboutCog,
  squareTerms,
  privacyPolicy,
  notices,
  faq,
  openInApp,
  contact,
  kakaoContact,
}

class GreenSquareDrawerDestination {
  const GreenSquareDrawerDestination({
    required this.label,
    required this.icon,
    required this.target,
  });

  final String label;
  final IconData icon;
  final GreenSquareDrawerTarget target;
}

const greenSquareDrawerDestinations = <GreenSquareDrawerDestination>[
  GreenSquareDrawerDestination(
    label: '브랜드 스토리',
    icon: Icons.auto_stories_outlined,
    target: GreenSquareDrawerTarget.brandStory,
  ),
  GreenSquareDrawerDestination(
    label: '입점 문의',
    icon: Icons.store_mall_directory_outlined,
    target: GreenSquareDrawerTarget.partnershipInquiry,
  ),
  GreenSquareDrawerDestination(
    label: '콕(cog) 에 관하여',
    icon: Icons.info_outline,
    target: GreenSquareDrawerTarget.aboutCog,
  ),
  GreenSquareDrawerDestination(
    label: '스퀘어 이용 약관',
    icon: Icons.article_outlined,
    target: GreenSquareDrawerTarget.squareTerms,
  ),
  GreenSquareDrawerDestination(
    label: '개인정보 처리방침',
    icon: Icons.privacy_tip_outlined,
    target: GreenSquareDrawerTarget.privacyPolicy,
  ),
  GreenSquareDrawerDestination(
    label: '공지사항',
    icon: Icons.campaign_outlined,
    target: GreenSquareDrawerTarget.notices,
  ),
  GreenSquareDrawerDestination(
    label: '자주 묻는 질문(FAQ)',
    icon: Icons.help_outline,
    target: GreenSquareDrawerTarget.faq,
  ),
  GreenSquareDrawerDestination(
    label: '문의하기',
    icon: Icons.mail_outline,
    target: GreenSquareDrawerTarget.contact,
  ),
  GreenSquareDrawerDestination(
    label: '카카오톡으로 문의하기',
    icon: Icons.chat_bubble_outline,
    target: GreenSquareDrawerTarget.kakaoContact,
  ),
  GreenSquareDrawerDestination(
    label: '앱에서 보기',
    icon: Icons.phone_iphone,
    target: GreenSquareDrawerTarget.openInApp,
  ),
];
