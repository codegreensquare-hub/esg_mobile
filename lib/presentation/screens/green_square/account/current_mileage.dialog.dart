import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/rank_management.service.dart';
import 'package:esg_mobile/core/services/profile.service.dart';
import 'package:esg_mobile/data/entities/rank_management.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

enum _MileageDialogState { main, earningHistory, usedMileage }

const _grayLink = Color(0xFF464646);
const _cardBorder = Color(0xFF959595);
const _mileageGreen = Color(0xFF3F615D);
const _dialogBackground = Color(0xFFFFFFFF);

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
  bool _historyLoading = false;
  String? _historyError;
  List<RankMileageHistoryEntry> _earningEntries = [];
  List<RankMileageHistoryEntry> _usedEntries = [];
  late DateTime _historyMonth;
  String? _userId;
  bool _isMainProfile = true;
  String? _selectedProfileId;
  final _monthTitleFormat = DateFormat('yyyy.MM.dd');
  final _numberFormat = NumberFormat.decimalPattern('ko');

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _historyMonth = DateTime(now.year, now.month, 1);
    _initUserContext();
  }

  Future<void> _initUserContext() async {
    final user = UserAuthService.instance.currentUser;
    if (user == null) return;

    try {
      await ProfileService.instance.refresh();
      final allowMultiple =
          UserAuthService.instance.userRow?.allowMultipleProfiles ?? false;
      if (!allowMultiple) {
        await ProfileService.instance.selectMainProfile();
      }

      final selectedProfileId = allowMultiple
          ? ProfileService.instance.selectedProfileId
          : null;
      final isMainProfile =
          !allowMultiple ||
          ProfileService.instance.isMainProfileSelected ||
          selectedProfileId == null;

      if (!mounted) return;
      setState(() {
        _userId = user.id;
        _isMainProfile = isMainProfile;
        _selectedProfileId = selectedProfileId;
      });
    } catch (e, st) {
      debugPrint('CurrentMileageDialog init context error: $e\n$st');
    }
  }

  void _goBack() {
    setState(() => _state = _MileageDialogState.main);
  }

  Future<void> _openEarningHistory() async {
    setState(() => _state = _MileageDialogState.earningHistory);
    await _loadHistory();
  }

  Future<void> _openUsedMileage() async {
    setState(() => _state = _MileageDialogState.usedMileage);
    await _loadHistory();
  }

  Future<void> _loadHistory() async {
    if (_userId == null) {
      await _initUserContext();
    }
    final userId = _userId ?? UserAuthService.instance.currentUser?.id;
    if (userId == null) {
      setState(() {
        _historyError = '로그인이 필요합니다.';
      });
      return;
    }

    setState(() {
      _historyLoading = true;
      _historyError = null;
    });

    try {
      if (_state == _MileageDialogState.earningHistory) {
        final list = await RankManagementService.instance.fetchEarningHistoryForMonth(
          userId: userId,
          isMainProfile: _isMainProfile,
          selectedProfileId: _selectedProfileId,
          month: _historyMonth,
        );
        if (!mounted) return;
        setState(() {
          _earningEntries = list;
          _historyLoading = false;
        });
      } else if (_state == _MileageDialogState.usedMileage) {
        final list = await RankManagementService.instance.fetchUsedMileageForMonth(
          userId: userId,
          isMainProfile: _isMainProfile,
          selectedProfileId: _selectedProfileId,
          month: _historyMonth,
        );
        if (!mounted) return;
        setState(() {
          _usedEntries = list;
          _historyLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() => _historyLoading = false);
      }
    } catch (e, st) {
      debugPrint('CurrentMileageDialog history error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _historyLoading = false;
        _historyError = '내역을 불러오지 못했습니다.';
      });
    }
  }

  String _monthRangeLabel() {
    final start = DateTime(_historyMonth.year, _historyMonth.month, 1);
    final end = DateTime(_historyMonth.year, _historyMonth.month + 1, 0);
    return '${_monthTitleFormat.format(start)} ~ ${_monthTitleFormat.format(end)}';
  }

  int _earningMonthTotal() =>
      _earningEntries.fold(0, (sum, item) => sum + item.points);

  int _usedMonthTotal() => _usedEntries.fold(0, (sum, item) => sum + item.points);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final maxWidth = Device.largeMobile.breakpoint;
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    final isMainState = _state == _MileageDialogState.main;

    return Dialog(
      backgroundColor: _dialogBackground,
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
    if (_historyLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_historyError != null) {
      return Center(
        child: Text(
          _historyError!,
          style: textTheme.bodyMedium?.copyWith(color: cs.error),
        ),
      );
    }

    final monthTotal = _numberFormat.format(_earningMonthTotal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            _monthRangeLabel(),
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
                  text: monthTotal,
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
          child: _earningEntries.isEmpty
              ? Center(
                  child: Text(
                    '적립 내역이 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(color: _grayLink),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _earningEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = _earningEntries[index];
                    return _EarningEntryCard(
                      date: _monthTitleFormat.format(entry.date),
                      action: entry.title,
                      category: entry.category,
                      points: '${_numberFormat.format(entry.points)}점',
                      textTheme: textTheme,
                      colorScheme: cs,
                    );
                  },
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
    if (_historyLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_historyError != null) {
      return Center(
        child: Text(
          _historyError!,
          style: textTheme.bodyMedium?.copyWith(color: cs.error),
        ),
      );
    }

    final monthTotal = _numberFormat.format(_usedMonthTotal());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Text(
            _monthRangeLabel(),
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
                  text: monthTotal,
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
          child: _usedEntries.isEmpty
              ? Center(
                  child: Text(
                    '사용한 마일리지가 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(color: _grayLink),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _usedEntries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = _usedEntries[index];
                    return _UsedMileageEntryCard(
                      date: _monthTitleFormat.format(entry.date),
                      item: entry.title,
                      category: entry.category,
                      points: '${_numberFormat.format(entry.points)}점',
                      textTheme: textTheme,
                      colorScheme: cs,
                    );
                  },
                ),
        ),
      ],
    );
  }

  TextStyle? _bottomLinkTextStyle(TextTheme textTheme) {
    final mediumSize = textTheme.bodyMedium?.fontSize ?? 14.0;
    final smallSize = textTheme.bodySmall?.fontSize ?? 12.0;
    final midSize = (mediumSize + smallSize) / 2.0;
    return textTheme.bodyMedium?.copyWith(
      fontSize: midSize,
      color: _grayLink,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.underline,
      decorationColor: _grayLink,
    );
  }

  Widget _buildBottomLinks(BuildContext context, TextTheme textTheme) {
    final linkStyle = _bottomLinkTextStyle(textTheme);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: InkWell(
            onTap: _openEarningHistory,
            child: Text(
              '적립 내역 확인하기',
              textAlign: TextAlign.center,
              style: linkStyle,
            ),
          ),
        ),
        Flexible(
          child: InkWell(
            onTap: _openUsedMileage,
            child: Text(
              '사용한 마일리지 확인하기',
              textAlign: TextAlign.center,
              style: linkStyle,
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
