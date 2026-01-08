import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/lookbook_grid_item.widget.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LookBookTab extends StatefulWidget {
  static const tab = 'look_book';
  const LookBookTab({super.key});

  @override
  State<LookBookTab> createState() => _LookBookTabState();
}

class _LookBookTabState extends State<LookBookTab> {
  late final Future<List<({LookbookRow row, String? coverUrl})>> _lookbooks;

  @override
  void initState() {
    super.initState();
    _lookbooks = _fetchLookbooks();
  }

  String? _resolveCoverUrl(LookbookRow row) {
    final bucket = row.coverBucket;
    final fileName = row.coverFileName;

    if (bucket == null || bucket.trim().isEmpty) return null;
    if (fileName == null || fileName.trim().isEmpty) return null;

    return getImageLink(
      bucket.trim(),
      fileName.trim(),
      folderPath: row.coverFolderPath?.trim().isEmpty ?? true
          ? null
          : row.coverFolderPath!.trim(),
    );
  }

  Future<List<({LookbookRow row, String? coverUrl})>> _fetchLookbooks() async {
    final client = Supabase.instance.client;

    final rows = await client
        .from(LookbookTable().tableName)
        .select()
        .order(LookbookRow.createdAtField, ascending: false);

    return (rows as List)
        .whereType<Map<String, dynamic>>()
        .map((data) {
          try {
            return LookbookRow.fromJson(data);
          } catch (e) {
            debugPrint('Error parsing lookbook row: $e');
            return null;
          }
        })
        .whereType<LookbookRow>()
        .where((e) => (e.name ?? '').trim().isNotEmpty)
        .map((row) => (row: row, coverUrl: _resolveCoverUrl(row)))
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 600 ? 3 : 2;

    return Container(
      color: theme.colorScheme.surface,
      child: FutureBuilder<List<({LookbookRow row, String? coverUrl})>>(
        future: _lookbooks,
        builder: (context, snapshot) {
          final body = switch (snapshot.connectionState) {
            ConnectionState.waiting => const Padding(
              padding: EdgeInsets.only(top: 48),
              child: Center(child: CircularProgressIndicator()),
            ),
            _ when snapshot.hasError => Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Center(
                child: Text(
                  '룩북을 불러오지 못했습니다.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            _ =>
              (snapshot.data ?? const []).isEmpty
                  ? Padding(
                      padding: const EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text(
                          '룩북이 없습니다.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      primary: false,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 2 / 3,
                      ),
                      itemCount: (snapshot.data ?? const []).length,
                      itemBuilder: (context, index) {
                        final item = (snapshot.data ?? const [])[index];
                        final title = (item.row.name ?? '').trim();
                        final coverUrl = item.coverUrl;

                        return LookbookGridItem(
                          id: item.row.id,
                          title: title,
                          coverUrl: coverUrl,
                        );
                      },
                    ),
          };

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Lookbook',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              body,
            ],
          );
        },
      ),
    );
  }
}
