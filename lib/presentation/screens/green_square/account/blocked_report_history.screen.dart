import 'package:flutter/material.dart';

/// Mock entry for blocked or reported history list.
class _HistoryEntry {
  const _HistoryEntry({
    required this.maskedName,
    required this.date,
    required this.comment,
  });

  final String maskedName;
  final String date;
  final String comment;
}

class BlockedReportHistoryScreen extends StatelessWidget {
  const BlockedReportHistoryScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  static const Color _appBarBg = Color(0xFFF5F3F1);
  static const Color _buttonBg = Color(0xFFB9B7B5);
  static const Color _pageBg = Color(0xFFF5F3F1);

  static const List<_HistoryEntry> _mockBlocked = [
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.02.01',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.11.03',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.11.03',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
  ];

  static const List<_HistoryEntry> _mockReported = [
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.11.03',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.11.03',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
    _HistoryEntry(
      maskedName: '김**',
      date: '2020.11.03',
      comment: '우와 꼭 한번 가보고 싶네요',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: _appBarBg,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SafeArea(
            bottom: false,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                    decoration: BoxDecoration(
                      color: _buttonBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '차단 내역 상세 보기',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        color: Colors.black87,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 40,
                      minHeight: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              _SectionHeader(
                title: '차단 내역',
                onMore: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => _BlockedOrReportedListScreen(
                        isBlocked: true,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              ..._mockBlocked.map((e) => _HistoryCard(entry: e, showUnblock: true)),
              const SizedBox(height: 24),
              _SectionHeader(
                title: '신고 내역',
                onMore: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => _BlockedOrReportedListScreen(
                        isBlocked: false,
                        userId: userId,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 6),
              ..._mockReported.map((e) => _HistoryCard(entry: e, showUnblock: false)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onMore,
  });

  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontFamily: 'Noto Sans KR',
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onMore,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              '더보기>',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'Noto Sans KR',
                color: const Color(0xFF4E4E4E),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.entry,
    required this.showUnblock,
  });

  final _HistoryEntry entry;
  final bool showUnblock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF355149),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      entry.maskedName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF4E4E4E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      entry.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Noto Sans KR',
                        color: const Color(0xFFB3B3B3),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  entry.comment,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Noto Sans KR',
                    color: const Color(0xFF3B3733),
                  ),
                ),
              ],
            ),
          ),
          if (showUnblock)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: Colors.black87,
              ),
              child: Text(
                '차단 해제',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'Noto Sans KR',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-list screen for either blocked or reported items, with back button and pagination.
class _BlockedOrReportedListScreen extends StatefulWidget {
  const _BlockedOrReportedListScreen({
    required this.isBlocked,
    required this.userId,
  });

  final bool isBlocked;
  final String userId;

  @override
  State<_BlockedOrReportedListScreen> createState() =>
      _BlockedOrReportedListScreenState();
}

class _BlockedOrReportedListScreenState extends State<_BlockedOrReportedListScreen> {
  static const Color _pageBg = Color(0xFFF5F3F1);
  static const Color _appBarBg = Color(0xFFF5F3F1);
  static const Color _buttonBg = Color(0xFFB9B7B5);

  static const List<_HistoryEntry> _mockAllBlocked = [
    _HistoryEntry(maskedName: '김**', date: '2020.02.01', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '김**', date: '2020.11.03', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '이**', date: '2020.10.01', comment: '좋은 정보 감사해요'),
    _HistoryEntry(maskedName: '박**', date: '2020.09.15', comment: '다음에 가봐야겠어요'),
    _HistoryEntry(maskedName: '최**', date: '2020.08.20', comment: '추천해주셔서 감사합니다'),
    _HistoryEntry(maskedName: '정**', date: '2020.07.10', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '강**', date: '2020.06.05', comment: '유익한 글이에요'),
    _HistoryEntry(maskedName: '조**', date: '2020.05.22', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '윤**', date: '2020.04.18', comment: '다음에 참여해볼게요'),
    _HistoryEntry(maskedName: '장**', date: '2020.03.12', comment: '좋은 정보 감사해요'),
    _HistoryEntry(maskedName: '임**', date: '2020.02.28', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '한**', date: '2020.01.15', comment: '유익한 글이에요'),
    _HistoryEntry(maskedName: '오**', date: '2019.12.01', comment: '다음에 가봐야겠어요'),
    _HistoryEntry(maskedName: '서**', date: '2019.11.20', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '신**', date: '2019.10.10', comment: '추천해주셔서 감사합니다'),
    _HistoryEntry(maskedName: '김**', date: '2019.09.05', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '이**', date: '2019.08.12', comment: '좋은 정보 감사해요'),
    _HistoryEntry(maskedName: '박**', date: '2019.07.20', comment: '다음에 가봐야겠어요'),
    _HistoryEntry(maskedName: '최**', date: '2019.06.08', comment: '유익한 글이에요'),
    _HistoryEntry(maskedName: '정**', date: '2019.05.15', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '강**', date: '2019.04.22', comment: '추천해주셔서 감사합니다'),
    _HistoryEntry(maskedName: '조**', date: '2019.03.10', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '윤**', date: '2019.02.01', comment: '다음에 참여해볼게요'),
    _HistoryEntry(maskedName: '장**', date: '2019.01.18', comment: '좋은 정보 감사해요'),
  ];

  static const List<_HistoryEntry> _mockAllReported = [
    _HistoryEntry(maskedName: '김**', date: '2020.11.03', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '이**', date: '2020.10.25', comment: '부적절한 댓글입니다'),
    _HistoryEntry(maskedName: '박**', date: '2020.09.30', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '최**', date: '2020.08.15', comment: '스팸으로 신고합니다'),
    _HistoryEntry(maskedName: '정**', date: '2020.07.08', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '강**', date: '2020.06.12', comment: '부적절한 내용'),
    _HistoryEntry(maskedName: '조**', date: '2020.05.20', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '윤**', date: '2020.04.05', comment: '신고합니다'),
    _HistoryEntry(maskedName: '장**', date: '2020.03.18', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '임**', date: '2020.02.22', comment: '부적절한 댓글'),
    _HistoryEntry(maskedName: '한**', date: '2020.01.10', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '오**', date: '2019.12.15', comment: '스팸 신고'),
    _HistoryEntry(maskedName: '서**', date: '2019.11.08', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '신**', date: '2019.10.20', comment: '부적절한 글'),
    _HistoryEntry(maskedName: '홍**', date: '2019.09.01', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '김**', date: '2019.08.12', comment: '부적절한 댓글입니다'),
    _HistoryEntry(maskedName: '이**', date: '2019.07.20', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '박**', date: '2019.06.08', comment: '스팸으로 신고합니다'),
    _HistoryEntry(maskedName: '최**', date: '2019.05.15', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '정**', date: '2019.04.22', comment: '부적절한 내용'),
    _HistoryEntry(maskedName: '강**', date: '2019.03.10', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '조**', date: '2019.02.01', comment: '신고합니다'),
    _HistoryEntry(maskedName: '윤**', date: '2019.01.18', comment: '우와 꼭 한번 가보고 싶네요'),
    _HistoryEntry(maskedName: '장**', date: '2018.12.05', comment: '부적절한 댓글'),
  ];

  static const int _pageSize = 5;

  int _currentPage = 1;

  List<_HistoryEntry> get _allEntries =>
      widget.isBlocked ? _mockAllBlocked : _mockAllReported;

  int get _totalItems => _allEntries.length;
  int get _totalPages => (_totalItems / _pageSize).ceil().clamp(1, 999);

  List<_HistoryEntry> get _pageItems {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _totalItems);
    if (start >= _totalItems) return [];
    return _allEntries.sublist(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = widget.isBlocked
        ? '전체 기간 내 차단한 댓글입니다.'
        : '전체 기간 내 신고한 댓글입니다.';

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildSameAppBar(context, theme),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '< 이전 페이지',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Noto Sans KR',
                      color: const Color(0xFF4E4E4E),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Noto Sans KR',
                    color: const Color(0xFF3B3733),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _pageItems.length,
                itemBuilder: (context, index) {
                  final entry = _pageItems[index];
                  return _HistoryCard(
                    entry: entry,
                    showUnblock: widget.isBlocked,
                  );
                },
              ),
            ),
            _PaginationBar(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildSameAppBar(BuildContext context, ThemeData theme) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        color: _appBarBg,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SafeArea(
          bottom: false,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                  decoration: BoxDecoration(
                    color: _buttonBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '차단 내역 상세 보기',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Noto Sans KR',
                      color: Colors.black87,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaginationBar extends StatelessWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final void Function(int) onPageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const color = Color(0xFF4E4E4E);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PaginateIcon(
            icon: '«',
            onTap: () => onPageChanged(1),
          ),
          const SizedBox(width: 12),
          _PaginateIcon(
            icon: '<',
            onTap: () => onPageChanged((currentPage - 1).clamp(1, totalPages)),
          ),
          const SizedBox(width: 16),
          ...List.generate(totalPages, (i) {
            final page = i + 1;
            final isActive = page == currentPage;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () => onPageChanged(page),
                child: Text(
                  '$page',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Noto Sans KR',
                    color: color,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(width: 16),
          _PaginateIcon(
            icon: '>',
            onTap: () => onPageChanged((currentPage + 1).clamp(1, totalPages)),
          ),
          const SizedBox(width: 12),
          _PaginateIcon(
            icon: '»',
            onTap: () => onPageChanged(totalPages),
          ),
        ],
      ),
    );
  }
}

class _PaginateIcon extends StatelessWidget {
  const _PaginateIcon({required this.icon, required this.onTap});

  final String icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Text(
        icon,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontFamily: 'Noto Sans KR',
          color: const Color(0xFF4E4E4E),
        ),
      ),
    );
  }
}
