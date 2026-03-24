import 'package:esg_mobile/data/models/supabase/tables/announcement.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _pageSize = 20;

class GreenSquareNoticesScreen extends StatefulWidget {
  const GreenSquareNoticesScreen({super.key});

  @override
  State<GreenSquareNoticesScreen> createState() =>
      _GreenSquareNoticesScreenState();
}

class _GreenSquareNoticesScreenState extends State<GreenSquareNoticesScreen> {
  final List<AnnouncementRow> _items = [];
  bool _isLoading = true;
  bool _hasMore = true;
  String? _error;

  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchPage();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _fetchPage();
    }
  }

  Future<void> _fetchPage() async {
    setState(() => _isLoading = true);

    try {
      final raw = await Supabase.instance.client
          .from(AnnouncementTable().tableName)
          .select()
          .eq(AnnouncementRow.isDeletedField, false)
          .order(AnnouncementRow.createdAtField)
          .range(_items.length, _items.length + _pageSize - 1);

      final list = (raw as List).cast<Map<String, dynamic>>();
      final rows = list.map((json) => AnnouncementRow.fromJson(json)).toList();

      if (!mounted) return;
      setState(() {
        _items.addAll(rows);
        _hasMore = rows.length == _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching announcements: $e');
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GreenSquareInfoPage(
      title: '공지사항',
      body: _buildBody(theme, cs),
    );
  }

  Widget _buildBody(ThemeData theme, ColorScheme cs) {
    if (_items.isEmpty && _isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_items.isEmpty && _error != null) {
      return Center(
        child: Text(
          _error!,
          style: theme.textTheme.bodyMedium?.copyWith(color: cs.error),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Text(
          '등록된 공지사항이 없습니다.',
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _items.length + (_hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = _items[index];
        final dateStr = DateFormat('yyyy.MM.dd').format(item.createdAt);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.campaign_outlined,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const TextSpan(text: '  '),
                    TextSpan(
                      text: item.title ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateStr,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (item.body != null) ...[
                const SizedBox(height: 12),
                Text(
                  item.body!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
