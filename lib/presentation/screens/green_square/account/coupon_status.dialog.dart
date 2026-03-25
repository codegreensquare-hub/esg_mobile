import 'package:esg_mobile/core/enums/device.dart';
import 'package:flutter/material.dart';

const _cardBorder = Color(0xFF959595);
const _dialogBackground = Color(0xFFFFFFFF);

/// "보유 쿠폰 현황" dialog – shows available coupons with title and validity.
class CouponStatusDialog extends StatelessWidget {
  const CouponStatusDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxWidth = Device.largeMobile.breakpoint;

    return Dialog(
      backgroundColor: _dialogBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, textTheme),
              const SizedBox(height: 20),
              Text(
                '사용 가능한 쿠폰 : 2매',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              _CouponCard(
                title: '(Lv3) 자사 쇼핑몰 3,000원 할인',
                validity: '2026.01.01 - 2026.06.30',
                textTheme: textTheme,
                colorScheme: cs,
              ),
              const SizedBox(height: 8),
              _CouponCard(
                title: '(Lv3) 자사 쇼핑몰 3,000원 할인',
                validity: '2026.01.01 - 2026.06.30',
                textTheme: textTheme,
                colorScheme: cs,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          '보유 쿠폰 현황',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: 'Noto Sans KR',
          ),
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  const _CouponCard({
    required this.title,
    required this.validity,
    required this.textTheme,
    required this.colorScheme,
  });

  final String title;
  final String validity;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Noto Sans KR',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            validity,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
