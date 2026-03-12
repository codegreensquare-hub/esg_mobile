import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/entities/blocked_report_comment_entry.dart';
import 'package:flutter/material.dart';

class BlockedReportHistoryScreen extends StatefulWidget {
  const BlockedReportHistoryScreen({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<BlockedReportHistoryScreen> createState() =>
      _BlockedReportHistoryScreenState();
}

class _BlockedReportHistoryScreenState extends State<BlockedReportHistoryScreen> {
  static const Color _appBarBg = Color(0xFFF5F3F1);
  static const Color _buttonBg = Color(0xFFB9B7B5);
  static const Color _pageBg = Color(0xFFF5F3F1);

  static const int _initialCount = 3;

  List<BlockedReportCommentEntry> _blocked = [];
  List<BlockedReportCommentEntry> _reported = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final blocked = await StoryService.instance.fetchBlockedCommentHistory(
      widget.userId,
      limit: _initialCount,
      offset: 0,
    );
    final reported = await StoryService.instance.fetchReportedCommentHistory(
      widget.userId,
      limit: _initialCount,
      offset: 0,
    );
    if (!mounted) return;
    setState(() {
      _blocked = blocked;
      _reported = reported;
      _loading = false;
    });
  }

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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 8),
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _SectionHeader(
                      title: '차단 내역',
                      onMore: () => _openListScreen(isBlocked: true),
                    ),
                    const SizedBox(height: 12),
                    ..._blocked.map(
                      (e) => _HistoryCard(
                        entry: e,
                        showUnblock: true,
                        onUnblock: () => _onUnblock(e.commentId),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _SectionHeader(
                      title: '신고 내역',
                      onMore: () => _openListScreen(isBlocked: false),
                    ),
                    const SizedBox(height: 6),
                    ..._reported.map(
                      (e) => _HistoryCard(
                        entry: e,
                        showUnblock: false,
                        onUnblock: null,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _openListScreen({required bool isBlocked}) {
    Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (context) => _BlockedOrReportedListScreen(
              isBlocked: isBlocked,
              userId: widget.userId,
            ),
          ),
        )
        .then((_) {
      if (!mounted) return;
      _load();
    });
  }

  Future<void> _onUnblock(String commentId) async {
    try {
      await StoryService.instance.unblockComment(
        commentId: commentId,
        userId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _blocked = _blocked.where((e) => e.commentId != commentId).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단이 해제되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('차단 해제에 실패했습니다. 다시 시도해 주세요.'),
        ),
      );
    }
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
    this.onUnblock,
  });

  final BlockedReportCommentEntry entry;
  final bool showUnblock;
  final VoidCallback? onUnblock;

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
                  entry.commentText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Noto Sans KR',
                    color: const Color(0xFF3B3733),
                  ),
                ),
              ],
            ),
          ),
          if (showUnblock && onUnblock != null)
            TextButton(
              onPressed: onUnblock,
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

class _BlockedOrReportedListScreenState
    extends State<_BlockedOrReportedListScreen> {
  static const Color _pageBg = Color(0xFFF5F3F1);
  static const Color _appBarBg = Color(0xFFF5F3F1);
  static const Color _buttonBg = Color(0xFFB9B7B5);

  static const int _pageSize = 5;
  static const int _maxFetch = 500;

  List<BlockedReportCommentEntry> _allEntries = [];
  bool _loading = true;
  int _currentPage = 1;

  int get _totalItems => _allEntries.length;
  int get _totalPages => (_totalItems / _pageSize).ceil().clamp(1, 999);

  List<BlockedReportCommentEntry> get _pageItems {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _totalItems);
    if (start >= _totalItems) return [];
    return _allEntries.sublist(start, end);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = widget.isBlocked
        ? await StoryService.instance.fetchBlockedCommentHistory(
            widget.userId,
            limit: _maxFetch,
            offset: 0,
          )
        : await StoryService.instance.fetchReportedCommentHistory(
            widget.userId,
            limit: _maxFetch,
            offset: 0,
          );
    if (!mounted) return;
    setState(() {
      _allEntries = list;
      _loading = false;
      _currentPage = 1;
    });
  }

  Future<void> _onUnblock(String commentId) async {
    try {
      await StoryService.instance.unblockComment(
        commentId: commentId,
        userId: widget.userId,
      );
      if (!mounted) return;
      setState(() {
        _allEntries =
            _allEntries.where((e) => e.commentId != commentId).toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('차단이 해제되었습니다.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('차단 해제에 실패했습니다. 다시 시도해 주세요.'),
        ),
      );
    }
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
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
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
                    child: _allEntries.isEmpty
                        ? Center(
                            child: Text(
                              '표시할 내역이 없습니다.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Noto Sans KR',
                                color: const Color(0xFF4E4E4E),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _pageItems.length,
                            itemBuilder: (context, index) {
                              final entry = _pageItems[index];
                              return _HistoryCard(
                                entry: entry,
                                showUnblock: widget.isBlocked,
                                onUnblock: widget.isBlocked
                                    ? () => _onUnblock(entry.commentId)
                                    : null,
                              );
                            },
                          ),
                  ),
                  if (_totalItems > 0)
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
