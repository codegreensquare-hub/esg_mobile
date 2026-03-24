import 'package:esg_mobile/core/enums/device.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/rank_management.service.dart';
import 'package:esg_mobile/core/services/profile.service.dart';
import 'package:esg_mobile/data/entities/rank_management.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;

enum _DialogState { rankManagement, earningHistory, usedMileage }

const _grayText = Color(0xFF464646);
const _statsLabelColor = Color(0xFFB1AFAB);
const _missionsAndLinkColor = Color(0xFF5A5A5A);

/// "나의 등급 관리" dialog shown when tapping Level on the account screen.
/// Loads rank, mission aggregates, and mileage history from Supabase.
class MyRankManagementDialog extends StatefulWidget {
  const MyRankManagementDialog({super.key});

  @override
  State<MyRankManagementDialog> createState() => _MyRankManagementDialogState();
}

class _MyRankManagementDialogState extends State<MyRankManagementDialog> {
  _DialogState _state = _DialogState.rankManagement;

  bool _snapshotLoading = true;
  String? _snapshotError;
  RankManagementSnapshot? _snapshot;

  bool _historyLoading = false;
  String? _historyError;
  List<RankMileageHistoryEntry> _earningEntries = [];
  List<RankMileageHistoryEntry> _usedEntries = [];

  /// Calendar month (local) used for history lists.
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
    _loadSnapshot();
  }

  Future<void> _loadSnapshot() async {
    setState(() {
      _snapshotLoading = true;
      _snapshotError = null;
    });

    try {
      final user = UserAuthService.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        setState(() {
          _snapshotLoading = false;
          _snapshotError = '로그인이 필요합니다.';
        });
        return;
      }

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

      final snapshot = await RankManagementService.instance.fetchSnapshot(
        userId: user.id,
        isMainProfile: isMainProfile,
        selectedProfileId: selectedProfileId,
      );

      if (!mounted) return;
      setState(() {
        _userId = user.id;
        _isMainProfile = isMainProfile;
        _selectedProfileId = selectedProfileId;
        _snapshot = snapshot;
        _snapshotLoading = false;
      });

      if (_state != _DialogState.rankManagement) {
        await _loadHistory();
      }
    } catch (e, st) {
      debugPrint('MyRankManagementDialog snapshot error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _snapshotLoading = false;
        _snapshotError = '정보를 불러오지 못했습니다.';
      });
    }
  }

  Future<void> _loadHistory() async {
    final userId = _userId;
    if (userId == null) return;

    setState(() {
      _historyLoading = true;
      _historyError = null;
    });

    try {
      if (_state == _DialogState.earningHistory) {
        final list = await RankManagementService.instance
            .fetchEarningHistoryForMonth(
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
      } else if (_state == _DialogState.usedMileage) {
        final list = await RankManagementService.instance
            .fetchUsedMileageForMonth(
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
      debugPrint('MyRankManagementDialog history error: $e\n$st');
      if (!mounted) return;
      setState(() {
        _historyLoading = false;
        _historyError = '내역을 불러오지 못했습니다.';
      });
    }
  }

  void _goBack() {
    setState(() => _state = _DialogState.rankManagement);
  }

  Future<void> _openEarningHistory() async {
    setState(() => _state = _DialogState.earningHistory);
    await _loadHistory();
  }

  Future<void> _openUsedMileage() async {
    setState(() => _state = _DialogState.usedMileage);
    await _loadHistory();
  }

  String _monthRangeLabel() {
    final start = DateTime(_historyMonth.year, _historyMonth.month, 1);
    final end = DateTime(_historyMonth.year, _historyMonth.month + 1, 0);
    return '${_monthTitleFormat.format(start)} ~ ${_monthTitleFormat.format(end)}';
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
              const SizedBox(height: 24),
              Flexible(
                child: _state == _DialogState.rankManagement
                    ? _buildRankContent(context, theme, cs, textTheme)
                    : _state == _DialogState.earningHistory
                    ? _buildEarningHistoryContent(context, theme, cs, textTheme)
                    : _buildUsedMileageContent(context, theme, cs, textTheme),
              ),
              if (_state == _DialogState.rankManagement) ...[
                const SizedBox(height: 28),
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
            fontWeight: isSubState ? FontWeight.bold : FontWeight.w400,
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
    if (_snapshotLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_snapshotError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _snapshotError!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadSnapshot,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final snap = _snapshot!;
    final progress = snap.progressToNextLevel.clamp(0.0, 1.0);
    final missions = snap.missionsByType;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Level ${snap.currentLevel}',
            style: textTheme.titleMedium?.copyWith(
              fontFamily: 'EB Garamond',
              fontWeight: FontWeight.w600,
              color: cs.primary,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
          ),
          const SizedBox(height: 18),
          _RankProgressBar(
            progress: progress,
            minLabel: '0',
            maxLabel: '100',
            textTheme: textTheme,
          ),
          const SizedBox(height: 28),
          _RankStatsSummary(
            textTheme: textTheme,
            missionCount: snap.approvedMissionCount,
            lifetimeMileage: snap.lifetimeMissionMileage,
            shoppingOrderCount: snap.shoppingOrderCount,
            shoppingPurchaseKrw: snap.shoppingPurchaseTotalKrw,
            numberFormat: _numberFormat,
          ),
          const SizedBox(height: 32),
          _CompletedMissionsHeader(textTheme: textTheme),
          const SizedBox(height: 16),
          if (missions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                '완료한 미션이 아직 없어요.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: _missionsAndLinkColor,
                  fontFamily: 'Noto Sans KR',
                ),
              ),
            )
          else
            ...[
              for (var i = 0; i < missions.length; i++) ...[
                _MissionRow(
                  name: missions[i].title,
                  times: missions[i].count,
                  points: missions[i].totalPoints,
                ),
                if (i < missions.length - 1) const SizedBox(height: 12),
              ],
            ],
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _historyError!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadHistory,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final total = RankManagementService.instance.sumPoints(_earningEntries);

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
                color: _grayText,
              ),
              children: [
                const TextSpan(text: '한 달 동안 '),
                TextSpan(
                  text: _numberFormat.format(total),
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
        Expanded(
          child: _earningEntries.isEmpty
              ? Center(
                  child: Text(
                    '이번 달 적립 내역이 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(color: _grayText),
                  ),
                )
              : ListView.separated(
                  itemCount: _earningEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final e = _earningEntries[index];
                    return _EarningEntryCard(
                      date: DateFormat('yyyy.MM.dd').format(e.date),
                      action: e.title,
                      category: e.category,
                      points: '${_numberFormat.format(e.points)}점',
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
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _historyError!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadHistory,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final total = RankManagementService.instance.sumPoints(_usedEntries);

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
                color: _grayText,
              ),
              children: [
                const TextSpan(text: '한 달 동안 '),
                TextSpan(
                  text: _numberFormat.format(total),
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
        Expanded(
          child: _usedEntries.isEmpty
              ? Center(
                  child: Text(
                    '이번 달 사용 내역이 없습니다.',
                    style: textTheme.bodyMedium?.copyWith(color: _grayText),
                  ),
                )
              : ListView.separated(
                  itemCount: _usedEntries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final e = _usedEntries[index];
                    return _UsedMileageEntryCard(
                      date: DateFormat('yyyy.MM.dd').format(e.date),
                      item: e.title,
                      category: e.category,
                      points: '${_numberFormat.format(e.points)}점',
                      textTheme: textTheme,
                      colorScheme: cs,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomLinks(BuildContext context, TextTheme textTheme) {
    final linkStyle = textTheme.bodyMedium?.copyWith(
      color: _missionsAndLinkColor,
      fontWeight: FontWeight.w400,
      decoration: TextDecoration.underline,
      decorationColor: _missionsAndLinkColor,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 20,
      runSpacing: 10,
      children: [
        InkWell(
          onTap: _openEarningHistory,
          child: Text('적립 내역 확인하기', style: linkStyle, textAlign: TextAlign.center),
        ),
        InkWell(
          onTap: _openUsedMileage,
          child: Text(
            '사용한 마일리지 확인하기',
            style: linkStyle,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// Glossy track + fill + circular thumb; labels under the ends.
class _RankProgressBar extends StatelessWidget {
  const _RankProgressBar({
    required this.progress,
    required this.minLabel,
    required this.maxLabel,
    required this.textTheme,
  });

  final double progress;
  final String minLabel;
  final String maxLabel;
  final TextTheme textTheme;

  static const _trackH = 12.0;
  static const _thumbD = 18.0;
  static const _trackUnfilled = Color(0xFFD5D9DC);

  @override
  Widget build(BuildContext context) {
    final labelStyle = textTheme.bodySmall?.copyWith(
      color: _missionsAndLinkColor,
      fontSize: 12,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final p = progress.clamp(0.0, 1.0);
            final thumbR = _thumbD / 2;
            final thumbLeft = (w * p - thumbR).clamp(0.0, w - _thumbD);

            return Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                height: 24,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.centerLeft,
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 5,
                      child: Container(
                        height: _trackH,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_trackH / 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.85),
                              offset: const Offset(0, -1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_trackH / 2),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              const ColoredBox(color: _trackUnfilled),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: SizedBox(
                                  width: (w * p).clamp(0.0, w),
                                  height: _trackH,
                                  child: const ColoredBox(
                                    color: Color(0xFF2FBC2E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: thumbLeft,
                      top: 3,
                      child: Container(
                        width: _thumbD,
                        height: _thumbD,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF2FBC2E),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2FBC2E)
                                  .withValues(alpha: 0.45),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            );
          },
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: labelStyle),
            Text(maxLabel, style: labelStyle),
          ],
        ),
      ],
    );
  }
}

class _RankStatsSummary extends StatelessWidget {
  const _RankStatsSummary({
    required this.textTheme,
    required this.missionCount,
    required this.lifetimeMileage,
    required this.shoppingOrderCount,
    required this.shoppingPurchaseKrw,
    required this.numberFormat,
  });

  final TextTheme textTheme;
  final int missionCount;
  final int lifetimeMileage;
  final int shoppingOrderCount;
  final int shoppingPurchaseKrw;
  final NumberFormat numberFormat;

  @override
  Widget build(BuildContext context) {
    final base = textTheme.bodyMedium?.copyWith(
      color: _statsLabelColor,
      height: 1.45,
      fontFamily: 'Noto Sans KR',
    );
    final emphasis = base?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            style: base,
            children: [
              const TextSpan(text: '미션 '),
              TextSpan(text: numberFormat.format(missionCount), style: emphasis),
              const TextSpan(text: '회, 적립 마일리지 '),
              TextSpan(
                text: numberFormat.format(lifetimeMileage),
                style: emphasis,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            style: base,
            children: [
              const TextSpan(text: '쇼핑몰 이용 '),
              TextSpan(
                text: numberFormat.format(shoppingOrderCount),
                style: emphasis,
              ),
              const TextSpan(text: '회, 쇼핑몰 구매 '),
              TextSpan(
                text: numberFormat.format(shoppingPurchaseKrw),
                style: emphasis,
              ),
              const TextSpan(text: '원'),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          '남았어요!',
          textAlign: TextAlign.center,
          style: base,
        ),
      ],
    );
  }
}

class _CompletedMissionsHeader extends StatelessWidget {
  const _CompletedMissionsHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Text(
      '내가 해낸 미션',
      textAlign: TextAlign.center,
      style: textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        fontFamily: 'Noto Sans KR',
        color: _missionsAndLinkColor,
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.name,
    required this.times,
    required this.points,
  });

  final String name;
  final int times;
  final int points;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final labelStyle = textTheme.bodyMedium?.copyWith(
      color: _missionsAndLinkColor,
      fontFamily: 'Noto Sans KR',
    );
    final numberStyle = labelStyle?.copyWith(
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: labelStyle,
          ),
        ),
        Text.rich(
          TextSpan(
            style: labelStyle,
            children: [
              TextSpan(text: '$times', style: numberStyle),
              const TextSpan(text: '회('),
              TextSpan(text: '$points', style: numberStyle),
              const TextSpan(text: '점)'),
            ],
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
