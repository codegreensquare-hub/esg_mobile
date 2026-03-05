import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/presentation/screens/auth/login.dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductQnaSection extends StatefulWidget {
  const ProductQnaSection({
    super.key,
    required this.productId,
  });

  final String productId;

  @override
  State<ProductQnaSection> createState() => _ProductQnaSectionState();
}

class _ProductQnaSectionState extends State<ProductQnaSection> {
  final TextEditingController _questionController = TextEditingController();
  final Map<String, TextEditingController> _replyControllers = {};

  bool _isLoading = true;
  VoidCallback? _authListener;

  bool get _isQnaReplyAdmin => UserAuthService.instance.isQnaReplyAdmin;
  bool _isPosting = false;
  int _limit = 10;
  bool _hasMore = false;

  List<Map<String, dynamic>> _questions = const [];

  String? get _userId => Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _load();
    _authListener = () {
      if (mounted) setState(() {});
    };
    UserAuthService.instance.addListener(_authListener!);
  }

  @override
  void didUpdateWidget(covariant ProductQnaSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      _limit = 10;
      _questions = const [];
      _hasMore = false;
      _load();
    }
  }

  @override
  void dispose() {
    if (_authListener != null) {
      UserAuthService.instance.removeListener(_authListener!);
    }
    _questionController.dispose();
    _replyControllers.values.forEach(_disposeTextController);
    super.dispose();
  }

  void _disposeTextController(TextEditingController controller) {
    controller.dispose();
  }

  TextEditingController _replyControllerFor(String questionId) {
    return _replyControllers.putIfAbsent(
      questionId,
      () => TextEditingController(),
    );
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);

    try {
      final client = Supabase.instance.client;

      final raw = await client
          .from('product_question')
          .select('*, user:question_by(username)')
          .eq('product', widget.productId)
          .order('created_at', ascending: false)
          .limit(_limit + 1);

      final rawList = (raw as List).cast<Map<String, dynamic>>();
      final hasMore = rawList.length > _limit;
      final visible = (hasMore ? rawList.take(_limit) : rawList).toList(
        growable: false,
      );

      final questionIds = visible
          .map((q) => (q['id'] as String?)?.trim() ?? '')
          .where((id) => id.isNotEmpty)
          .toList(growable: false);

      final repliesRaw = questionIds.isEmpty
          ? const <Map<String, dynamic>>[]
          : (await client
                        .from('product_question_reply')
                        .select('*, user:reply_by(username)')
                        .inFilter('replying_to', questionIds)
                        .order('created_at', ascending: true)
                    as List)
                .cast<Map<String, dynamic>>();

      final repliesByQuestion = repliesRaw
          .fold<Map<String, List<Map<String, dynamic>>>>(
            <String, List<Map<String, dynamic>>>{},
            (acc, reply) {
              final qid = (reply['replying_to'] as String?)?.trim() ?? '';
              if (qid.isEmpty) return acc;

              final next = <String, List<Map<String, dynamic>>>{...acc};
              final existing = next[qid] ?? const <Map<String, dynamic>>[];
              next[qid] = [...existing, reply];
              return next;
            },
          );

      final enriched = visible
          .map(
            (q) => {
              ...q,
              'replies':
                  repliesByQuestion[(q['id'] as String?)?.trim() ?? ''] ??
                  const <Map<String, dynamic>>[],
            },
          )
          .toList(growable: false);

      if (!mounted) return;
      setState(() {
        _questions = enriched;
        _hasMore = hasMore;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading QnA: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode ? 'QnA 로딩 중 오류가 발생했습니다.\n$e' : 'QnA 로딩 중 오류가 발생했습니다.',
          ),
        ),
      );
    }
  }

  Future<void> _postQuestion() async {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;

    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) {
      showDialog<void>(context: context, barrierDismissible: false, builder: (context) => const LoginDialog());
      return;
    }

    setState(() => _isPosting = true);
    try {
      await Supabase.instance.client.from('product_question').insert({
        'question_by': userId,
        'product': widget.productId,
        'question': text,
      });

      if (!mounted) return;
      _questionController.clear();
      await _load();
    } catch (e) {
      debugPrint('Error posting question: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode ? '질문 등록 중 오류가 발생했습니다.\n$e' : '질문 등록 중 오류가 발생했습니다.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _postReply(String questionId) async {
    final controller = _replyControllerFor(questionId);
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final userId = _userId;
    if (userId == null || userId.trim().isEmpty) {
      showDialog<void>(context: context, barrierDismissible: false, builder: (context) => const LoginDialog());
      return;
    }

    setState(() => _isPosting = true);
    try {
      await Supabase.instance.client.from('product_question_reply').insert({
        'reply_by': userId,
        'replying_to': questionId,
        'reply': text,
      });

      if (!mounted) return;
      controller.clear();
      await _load();
    } catch (e) {
      debugPrint('Error posting reply: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            kDebugMode ? '답변 등록 중 오류가 발생했습니다.\n$e' : '답변 등록 중 오류가 발생했습니다.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  String _usernameFromJoinedUser(Map<String, dynamic> row, String fallback) {
    final user = row['user'];
    if (user is Map<String, dynamic>) {
      final name = (user['username'] as String?)?.trim();
      if (name != null && name.isNotEmpty) return name;
    }
    return fallback;
  }

  String _formatCreatedAt(dynamic createdAt) {
    try {
      if (createdAt is DateTime) {
        return DateFormat('yyyy.MM.dd').format(createdAt.toLocal());
      }
      if (createdAt is String) {
        final parsed = DateTime.tryParse(createdAt);
        if (parsed != null) {
          return DateFormat('yyyy.MM.dd').format(parsed.toLocal());
        }
      }
    } catch (_) {}
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final userId = _userId;
    final isLoggedIn = userId != null && userId.trim().isNotEmpty;

    final askBox = Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'QnA',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                onPressed: _isLoading ? null : _load,
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!isLoggedIn)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '로그인 후 질문과 답변을 남길 수 있어요.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: () => showDialog<void>(context: context, barrierDismissible: false, builder: (context) => const LoginDialog()),
                    child: const Text('Login'),
                  ),
                ],
              ),
            )
          else
            TextField(
              controller: _questionController,
              minLines: 2,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: '질문을 입력해주세요',
                filled: true,
                fillColor: cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          if (isLoggedIn) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _isPosting ? null : _postQuestion,
                icon: _isPosting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send, size: 18),
                label: const Text('Ask'),
              ),
            ),
          ],
        ],
      ),
    );

    final emptyState = Container(
      padding: const EdgeInsets.symmetric(
        vertical: 36,
      ),
      alignment: Alignment.center,
      child: Text(
        _isLoading ? 'Loading...' : '아직 질문이 없어요. 첫 질문을 남겨보세요!',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );

    final list = _questions.isEmpty
        ? emptyState
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _questions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final q = _questions[index];
              final qid = (q['id'] as String?)?.trim() ?? '';
              final question = (q['question'] as String?)?.trim() ?? '';
              final createdAt = _formatCreatedAt(q['created_at']);
              final username = _usernameFromJoinedUser(q, 'User');
              final replies =
                  (q['replies'] as List?)?.cast<Map<String, dynamic>>() ??
                  const <Map<String, dynamic>>[];

              final initials = username.trim().isEmpty
                  ? '?'
                  : username.trim().substring(0, 1).toUpperCase();

              final replyController = _replyControllerFor(qid);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: cs.primaryContainer,
                          foregroundColor: cs.onPrimaryContainer,
                          child: Text(
                            initials,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      username,
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                  ),
                                  if (createdAt.isNotEmpty)
                                    Text(
                                      createdAt,
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: cs.onSurfaceVariant,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                question.isEmpty ? '(내용 없음)' : question,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (replies.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: replies
                              .map((r) {
                                final replyText =
                                    (r['reply'] as String?)?.trim() ?? '';
                                final replyBy = _usernameFromJoinedUser(
                                  r,
                                  'User',
                                );
                                final replyAt = _formatCreatedAt(
                                  r['created_at'],
                                );
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.subdirectory_arrow_right,
                                        size: 18,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        replyBy,
                                                        style: theme
                                                            .textTheme
                                                            .labelLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w800,
                                                              color: cs
                                                                  .onSurface,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: cs.primaryContainer,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Text(
                                                          '관리자',
                                                          style: theme
                                                              .textTheme
                                                              .labelSmall
                                                              ?.copyWith(
                                                                color: cs
                                                                    .onPrimaryContainer,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (replyAt.isNotEmpty)
                                                  Text(
                                                    replyAt,
                                                    style: theme
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          color: cs
                                                              .onSurfaceVariant,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              replyText.isEmpty
                                                  ? '(내용 없음)'
                                                  : replyText,
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
                                                    height: 1.35,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_isQnaReplyAdmin)
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              enabled: isLoggedIn && !_isPosting,
                              minLines: 1,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: isLoggedIn
                                    ? '답변을 입력해주세요'
                                    : '로그인 후 답변을 남길 수 있어요',
                                filled: true,
                                fillColor: cs.surfaceContainerHighest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          FilledButton(
                            onPressed: (!isLoggedIn ||
                                    _isPosting ||
                                    qid.isEmpty)
                                ? null
                                : () => _postReply(qid),
                            child: _isPosting
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Reply'),
                          ),
                        ],
                      )
                    else if (isLoggedIn)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '답변은 관리자만 등록할 수 있어요',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          );

    final seeMore = _hasMore
        ? Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton.icon(
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() => _limit += 10);
                        _load();
                      },
                icon: const Icon(Icons.expand_more),
                label: const Text('See more'),
              ),
            ),
          )
        : const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          list,
          seeMore,
          const SizedBox(height: 16),
          askBox,
        ],
      ),
    );
  }
}
