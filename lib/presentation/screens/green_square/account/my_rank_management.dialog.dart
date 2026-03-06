import 'package:esg_mobile/core/enums/device.dart';
import 'package:flutter/material.dart';

enum _DialogState { rankManagement, earningHistory, usedMileage }

const _grayText = Color(0xFF464646);

/// "나의 등급 관리" dialog shown when tapping Level 1 on the account screen.
/// Shows fulfillment conditions and benefits; tapping "적립 내역 확인하기" or
/// "사용한 마일리지 확인하기" replaces content with that view (chevron back).
class MyRankManagementDialog extends StatefulWidget {
  const MyRankManagementDialog({super.key});

  @override
  State<MyRankManagementDialog> createState() => _MyRankManagementDialogState();
}

class _MyRankManagementDialogState extends State<MyRankManagementDialog> {
  _DialogState _state = _DialogState.rankManagement;

  void _goBack() {
    setState(() => _state = _DialogState.rankManagement);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxWidth = Device.largeMobile.breakpoint;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;

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
              const SizedBox(height: 20),
              Flexible(
                child: _state == _DialogState.rankManagement
                    ? _buildRankContent(context, theme, cs, textTheme)
                    : _state == _DialogState.earningHistory
                        ? _buildEarningHistoryContent(context, theme, cs, textTheme)
                        : _buildUsedMileageContent(context, theme, cs, textTheme),
              ),
              if (_state == _DialogState.rankManagement) ...[
                const SizedBox(height: 20),
                _buildBottomLinks(context, textTheme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final isSubState = _state != _DialogState.rankManagement;
    final title = _state == _DialogState.rankManagement
        ? '나의 등급 관리'
        : _state == _DialogState.earningHistory
            ? '적립 내역 확인하기'
            : '사용한 마일리지 확인하기';

    return Stack(
      alignment: Alignment.center,
      children: [
        if (isSubState)
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _goBack,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ),
        Text(
          title,
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

  Widget _buildRankContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _LevelSection(
            levelLabel: 'Level 1',
            conditions: const [
              '물 - 스토리 좋아요 45회',
              '햇빛 - 미션인증 100회',
            ],
            conditionProgress: const ['', '110/100'],
            benefits: const [
              _BenefitItem(
                text: '미션 27회, 적립 마일리지 28,000',
                boldNumbers: ['27', '28,000'],
              ),
              _BenefitItem(
                text: '쇼핑몰 이용 1회, 쇼핑몰 구매 15,800원',
                boldNumbers: ['1', '15,800'],
              ),
              _BenefitItem(
                text: '제품 구매 시 마일리지 1% 적립',
                boldNumbers: ['1'],
              ),
            ],
            primaryColor: cs.primary,
            textTheme: textTheme,
          ),
          const SizedBox(height: 24),
          _LevelSection(
            levelLabel: 'Level 2',
            subLabel: '내가 해낸 미션',
            conditions: const [
              '분리배출 좋아요 45회',
              '장바구니 사용 100회',
              '텀블러 사용하기',
            ],
            conditionProgress: const [
              '1회(400점)',
              '1회(100점)',
              '1회(700점)',
            ],
            benefits: const [
              _BenefitItem(
                text: '제품 구매 시 마일리지 1% 적립',
                boldNumbers: ['1'],
              ),
            ],
            primaryColor: cs.primary,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildEarningHistoryContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                color: _grayText,
              ),
              children: [
                const TextSpan(text: '한 달 동안 '),
                TextSpan(
                  text: '1,600',
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const TextSpan(text: 'M 모았어요!'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Flexible(
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) => _EarningEntryCard(
              date: '2026.01.13',
              action: '텀블러 사용하기',
              category: '미션',
              points: '30점',
              textTheme: textTheme,
              colorScheme: cs,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUsedMileageContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
                color: _grayText,
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
    );
  }

  Widget _buildBottomLinks(BuildContext context, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _state = _DialogState.earningHistory),
            child: Text(
              '적립 내역 확인하기',
              style: textTheme.bodyMedium?.copyWith(
                color: _grayText,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                decorationColor: _grayText,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _state = _DialogState.usedMileage),
            child: Text(
              '사용한 마일리지 확인하기',
              style: textTheme.bodyMedium?.copyWith(
                color: _grayText,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                decorationColor: _grayText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LevelSection extends StatelessWidget {
  const _LevelSection({
    required this.levelLabel,
    this.subLabel,
    required this.conditions,
    required this.conditionProgress,
    required this.benefits,
    required this.primaryColor,
    required this.textTheme,
  });

  final String levelLabel;
  final String? subLabel;
  final List<String> conditions;
  final List<String> conditionProgress;
  final List<_BenefitItem> benefits;
  final Color primaryColor;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              levelLabel,
              style: textTheme.titleMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                decorationColor: primaryColor,
              ),
            ),
            if (subLabel != null) ...[
              const SizedBox(width: 8),
              Text(
                subLabel!,
                style: textTheme.bodySmall?.copyWith(
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '충족 조건',
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryColor.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        ...conditions.asMap().entries.map((e) {
          final progress = e.key < conditionProgress.length
              ? conditionProgress[e.key]
              : '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: textTheme.bodyMedium,
                ),
                Expanded(
                  child: Text(
                    e.value,
                    style: textTheme.bodyMedium,
                  ),
                ),
                if (progress.isNotEmpty)
                  Text(
                    progress,
                    style: textTheme.bodySmall?.copyWith(
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          );
        }),
        const SizedBox(height: 12),
        Text(
          '혜택',
          style: textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: primaryColor.withValues(alpha: 0.9),
          ),
        ),
        const SizedBox(height: 6),
        ...benefits.map(
          (b) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: textTheme.bodyMedium),
                Expanded(child: b.build(textTheme, primaryColor)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BenefitItem {
  const _BenefitItem({
    required this.text,
    this.boldNumbers = const [],
  });

  final String text;
  final List<String> boldNumbers;

  Widget build(TextTheme textTheme, Color primaryColor) {
    String remaining = text;
    final spans = <TextSpan>[];
    for (final numStr in boldNumbers) {
      final idx = remaining.indexOf(numStr);
      if (idx == -1) continue;
      if (idx > 0) {
        spans.add(TextSpan(
          text: remaining.substring(0, idx),
          style: textTheme.bodyMedium,
        ));
      }
      spans.add(TextSpan(
        text: numStr,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ));
      remaining = remaining.substring(idx + numStr.length);
    }
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining, style: textTheme.bodyMedium));
    }
    if (spans.isEmpty) {
      return Text(text, style: textTheme.bodyMedium);
    }
    return Text.rich(
      TextSpan(
        style: textTheme.bodyMedium,
        children: spans,
      ),
    );
  }
}

class _EarningEntryCard extends StatelessWidget {
  const _EarningEntryCard({
    required this.date,
    required this.action,
    required this.category,
    required this.points,
    required this.textTheme,
    required this.colorScheme,
  });

  final String date;
  final String action;
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
                  action,
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
