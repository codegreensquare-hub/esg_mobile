import 'package:esg_mobile/core/enums/device.dart';
import 'package:flutter/material.dart';

/// "사용한 마일리지 확인하기" dialog – shows used mileage history
/// for a selected period (date range, summary, list of transactions).
class UsedMileageDialog extends StatelessWidget {
  const UsedMileageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxWidth = Device.largeMobile.breakpoint;
    final maxHeight = MediaQuery.of(context).size.height * 0.75;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, textTheme),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  '2026.01.01 ~ 2026.01.31',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text.rich(
                  TextSpan(
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF464646),
                    ),
                    children: [
                      const TextSpan(text: '한 달 동안 '),
                      TextSpan(
                        text: '60',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const TextSpan(text: 'M 사용했어요!'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: 2,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => _UsedMileageEntryCard(
                    date: '2026.01.13',
                    item: '텀블러 구매',
                    category: '쇼핑몰',
                    points: '30점',
                    textTheme: textTheme,
                    colorScheme: cs,
                  ),
                ),
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
          '사용한 마일리지 확인하기',
          style: textTheme.titleLarge?.copyWith(
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

class _UsedMileageEntryCard extends StatelessWidget {
  const _UsedMileageEntryCard({
    required this.date,
    required this.item,
    required this.category,
    required this.points,
    required this.textTheme,
    required this.colorScheme,
  });

  final String date;
  final String item;
  final String category;
  final String points;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  static const _cardBorder = Color(0xFF959595);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Sans KR',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  category,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            points,
            style: textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
