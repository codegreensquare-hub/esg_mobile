import 'package:esg_mobile/data/models/supabase/tables/faq.dart';
import 'package:esg_mobile/presentation/widgets/green_square/faq_card.dart';
import 'package:esg_mobile/presentation/widgets/green_square/green_square_info_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GreenSquareFaqScreen extends StatefulWidget {
  const GreenSquareFaqScreen({super.key});

  @override
  State<GreenSquareFaqScreen> createState() => _GreenSquareFaqScreenState();
}

class _GreenSquareFaqScreenState extends State<GreenSquareFaqScreen> {
  late final Future<List<FaqRow>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchFaqs();
  }

  Future<List<FaqRow>> _fetchFaqs() async {
    final raw = await Supabase.instance.client
        .from(FaqTable().tableName)
        .select()
        .order(FaqRow.createdAtField);

    final list = (raw as List).cast<Map<String, dynamic>>();
    return list.map((json) => FaqRow.fromJson(json)).toList().reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return GreenSquareInfoPage(
      title: '자주 묻는 질문(FAQ)',
      body: FutureBuilder<List<FaqRow>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint('Error fetching FAQ: ${snapshot.error}');
            return Center(
              child: Text(
                '${snapshot.error}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.error,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }

          final items = snapshot.data ?? const <FaqRow>[];

          if (items.isEmpty) {
            return Center(
              child: Text(
                '등록된 FAQ가 없습니다.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Noto Sans KR',
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++)
                  FaqCard(
                    question: items[i].question ?? '',
                    answer: items[i].answer ?? '',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
