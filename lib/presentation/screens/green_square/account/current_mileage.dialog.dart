import 'package:esg_mobile/core/enums/device.dart';
import 'package:flutter/material.dart';

enum _MileageDialogState { main, earningHistory, usedMileage }

const _grayLink = Color(0xFF464646);
const _cardBorder = Color(0xFF959595);
const _mileageGreen = Color(0xFF3F615D);

/// "현재 보유 마일리지" dialog. Main view shows balance + two links;
/// tapping a link replaces content with earning or used-mileage view (chevron back).
class CurrentMileageDialog extends StatefulWidget {
  const CurrentMileageDialog({
    super.key,
    required this.mileageText,
  });

  final String mileageText;

  @override
  State<CurrentMileageDialog> createState() => _CurrentMileageDialogState();
}

class _CurrentMileageDialogState extends State<CurrentMileageDialog> {
  _MileageDialogState _state = _MileageDialogState.main;

  void _goBack() {
    setState(() => _state = _MileageDialogState.main);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxWidth = Device.largeMobile.breakpoint;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final isMainState = _state == _MileageDialogState.main;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          maxHeight: isMainState ? double.infinity : maxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, textTheme),
              const SizedBox(height: 20),
              if (isMainState) ...[
                _buildMainContent(context, theme, cs, textTheme),
                const SizedBox(height: 20),
                _buildBottomLinks(context, textTheme),
              ] else
                Flexible(
                  child: _state == _MileageDialogState.earningHistory
                      ? _buildEarningHistoryContent(context, theme, cs, textTheme)
                      : _buildUsedMileageContent(context, theme, cs, textTheme),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, TextTheme textTheme) {
    final isSubState = _state != _MileageDialogState.main;
    final title = _state == _MileageDialogState.main
        ? '현재 보유 마일리지'
        : _state == _MileageDialogState.earningHistory
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

  Widget _buildMainContent(
    BuildContext context,
    ThemeData theme,
    ColorScheme cs,
    TextTheme textTheme,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: _mileageGreen,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Text(
                  'C',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.mileageText,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: _mileageGreen,
                ),
              ),
            ],
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
                color: _grayLink,
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
                color: _grayLink,
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
            onTap: () => setState(() => _state = _MileageDialogState.earningHistory),
            child: Text(
              '적립 내역 확인하기',
              style: textTheme.bodyMedium?.copyWith(
                color: _grayLink,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                decorationColor: _grayLink,
              ),
            ),
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () => setState(() => _state = _MileageDialogState.usedMileage),
            child: Text(
              '사용한 마일리지 확인하기',
              style: textTheme.bodyMedium?.copyWith(
                color: _grayLink,
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.underline,
                decorationColor: _grayLink,
              ),
            ),
          ),
        ),
      ],
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
