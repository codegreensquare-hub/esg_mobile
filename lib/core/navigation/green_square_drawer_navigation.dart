import 'package:esg_mobile/core/constants/green_square_navigation.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/about_cog.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/brand_story.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/contact.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/esg_campaign_inquiry.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/faq.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/mission_request.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/notices.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_inquiry.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_request.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/terms.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Handles [GreenSquareRightDrawer] item taps from contexts outside [MainScreen]
/// (e.g. signup flow), matching main/profile drawer behavior.
Future<void> navigateFromGreenSquareDrawer(
  BuildContext context,
  GreenSquareDrawerDestination destination,
) async {
  if (!context.mounted) return;

  switch (destination.target) {
    case GreenSquareDrawerTarget.brandStory:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareBrandStoryScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.partnershipInquiry:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquarePartnershipInquiryScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.partnershipRequest:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquarePartnershipRequestScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.missionRequest:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareMissionRequestScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.esgCampaignInquiry:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareEsgCampaignInquiryScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.aboutCog:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareAboutCogScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.squareTerms:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareTermsScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.privacyPolicy:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquarePrivacyPolicyScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.notices:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareNoticesScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.faq:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareFaqScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.openInApp:
      await _launchExternal(
        context,
        Uri.parse(
          'https://apps.apple.com/kr/app/%EC%BD%94%EB%93%9C%EA%B7%B8%EB%A6%B0%EC%8A%A4%ED%80%98%EC%96%B4/id1597090322',
        ),
      );
      break;
    case GreenSquareDrawerTarget.contact:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const GreenSquareContactScreen(),
        ),
      );
      break;
    case GreenSquareDrawerTarget.kakaoContact:
      await _launchExternal(
        context,
        Uri.parse('https://pf.kakao.com/_taxoxdG'),
      );
      break;
    case GreenSquareDrawerTarget.cart:
      await _showCartBottomSheet(context);
      break;
    case GreenSquareDrawerTarget.myOrders:
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const MyOrdersScreen(),
        ),
      );
      break;
  }
}

Future<void> _showCartBottomSheet(BuildContext context) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('로그인이 필요합니다.')),
    );
    return;
  }

  final items = await CartService.instance.fetchCartItems(userId);
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => CartBottomSheet(items: items),
  );
}

Future<void> _launchExternal(BuildContext context, Uri uri) async {
  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
        ),
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
      ),
    );
  }
}
