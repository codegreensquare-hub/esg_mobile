import 'package:cached_network_image/cached_network_image.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/settings.service.dart';
import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/format_number_into_krw.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/core/utils/product_pricing.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/login.dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/product_detail.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/text.story.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_detail.dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:esg_mobile/web_updater.dart'
    if (dart.library.html) 'dart:js'
    as js;

String _formatDateYyyyMmDd(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}

const String _kCommentProfileSvg =
    'assets/images/story_comments/comment_profile.svg';

const Color _kCommentNameColor = Color(0xFF4E4E4E);
const Color _kCommentDateColor = Color(0xFFB3B3B3);
const Color _kCommentBodyColor = Color(0xFF3B3733);
const Color _kCommentActionColor = Color(0xFF4E4E4E);
const Color _kCommentDividerColor = Color(0xFFE5E5E5);

/// Horizontal inset matches screen edge; vertical is symmetric between dividers.
const EdgeInsets _kCommentRowPadding =
    EdgeInsets.symmetric(horizontal: 16, vertical: 16);

Widget _commentDefaultProfileAvatar() {
  return SvgPicture.asset(
    _kCommentProfileSvg,
    width: 36,
    height: 36,
  );
}

TextStyle? _commentActionButtonStyle(ThemeData theme) {
  return theme.textTheme.bodySmall?.copyWith(
    color: _kCommentActionColor,
    fontWeight: FontWeight.w400,
  );
}

class StoryDialog extends StatefulWidget {
  const StoryDialog({
    super.key,
    required this.story,
    required this.tags,
  });

  final StoryRow story;
  final List<StoryTagRow> tags;

  @override
  State<StoryDialog> createState() => _StoryDialogState();
}

class _StoryDialogState extends State<StoryDialog> {
  late List<StoryCommentWithUser> comments = [];
  late int likeCount = 0;
  late bool hasLiked = false;
  late bool isBlocked = false;
  late List<ProductWithOtherDetails> recommendedProducts = [];
  late List<MissionRow> recommendedMissions = [];
  late List<StoryWithTags> previousStories = [];
  bool isLoadingRecommendations = true;
  bool isLoadingPreviousStories = true;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _editCommentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerCardKey = GlobalKey();
  double _headerCardHeight = 0;
  bool _showTopAppBar = false;
  double _photoHeightThreshold = 0;
  String? userId;
  double _baseDiscountRate = 0.0;
  String? _editingCommentId;
  Set<String> _blockedCommentIds = {};

  @override
  void initState() {
    super.initState();
    userId = Supabase.instance.client.auth.currentUser?.id;
    if (kIsWeb) {
      js.context['history'].callMethod('pushState', [
        null,
        '',
        '/greensquare?story=${widget.story.id}',
      ]);
    }
    _loadData();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderCardHeight();
    });

    _scrollController.addListener(() {
      final shouldShow =
          widget.story.title != null &&
          _photoHeightThreshold > 0 &&
          _scrollController.offset >= _photoHeightThreshold;
      if (mounted && shouldShow != _showTopAppBar) {
        setState(() {
          _showTopAppBar = shouldShow;
        });
      }
    });

    // Listen for auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.signedIn && userId == null) {
        setState(() {
          userId = event.session?.user.id;
        });
        _loadData();
      }
    });
  }

  Future<void> _loadData() async {
    final storyId = widget.story.id;
    final fetchedComments = await StoryService.instance.fetchComments(storyId);
    final count = await StoryService.instance.getLikeCount(storyId);
    final liked = userId == null
        ? false
        : await StoryService.instance.hasUserLiked(storyId, userId!);
    final blocked = userId == null
        ? false
        : (await StoryService.instance.fetchBlockedStoryIds(
            userId!,
          )).contains(storyId);
    final blockedCommentIds = userId == null
        ? <String>[]
        : await StoryService.instance.fetchBlockedCommentIds(userId!);

    if (!mounted) return;
    setState(() {
      isLoadingRecommendations = true;
      isLoadingPreviousStories = true;
    });

    final fetchedProducts = await StoryService.instance.fetchRelatedProducts(
      storyId,
      userId: userId,
    );
    final fetchedMissions = await StoryService.instance.fetchRelatedMissions(
      storyId,
    );

    final fetchedPreviousStories = await StoryService.instance
        .fetchPreviousStories(widget.story);
    final baseRate = await SettingsService.instance.getBaseDiscountRate();

    if (!mounted) return;
    setState(() {
      comments = fetchedComments;
      likeCount = count;
      hasLiked = liked;
      isBlocked = blocked;
      _blockedCommentIds = Set<String>.from(blockedCommentIds);
      recommendedProducts = fetchedProducts;
      recommendedMissions = fetchedMissions;
      isLoadingRecommendations = false;
      previousStories = fetchedPreviousStories;
      isLoadingPreviousStories = false;
      _baseDiscountRate = baseRate;
    });
  }

  Future<bool?> _confirmDeleteComment(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '댓글을 삭제하시겠습니까?',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('아니요'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6C3E),
                    ),
                    child: const Text('예'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteCompletedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '삭제가 완료되었습니다.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBlockCompletedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '차단되었습니다.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReportCompletedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '신고가 접수되었습니다.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBlockedCommentRow(
    BuildContext context,
    String commentId,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _commentDefaultProfileAvatar(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      '*차단한 댓글입니다',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _kCommentNameColor,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final uid = userId;
                      if (uid == null) return;
                      try {
                        await StoryService.instance.unblockComment(
                          commentId: commentId,
                          userId: uid,
                        );
                        if (!mounted) return;
                        setState(() => _blockedCommentIds.remove(commentId));
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('차단이 해제되었습니다.'),
                          ),
                        );
                      } catch (_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('차단 해제에 실패했습니다. 다시 시도해 주세요.'),
                          ),
                        );
                      }
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: _kCommentActionColor,
                      textStyle: _commentActionButtonStyle(theme),
                    ),
                    child: const Text('차단 해제'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _confirmReportComment(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '댓글을 신고하시겠습니까?\n신고는 취소할 수 없습니다.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('아니요'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6C3E),
                    ),
                    child: const Text('예'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmBlockComment(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '해당 댓글을 차단하시겠습니까?',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actionsPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFC6C6C6),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('아니요'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6C3E),
                    ),
                    child: const Text('예'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToProductDetail(ProductWithOtherDetails productWithDetails) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(
          productWithDetails: productWithDetails,
        ),
      ),
    );
  }

  void _updateHeaderCardHeight() {
    final context = _headerCardKey.currentContext;
    if (context == null) return;

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) return;

    final nextHeight = renderObject.size.height;
    if (!mounted) return;

    if ((nextHeight - _headerCardHeight).abs() > 0.5) {
      setState(() {
        _headerCardHeight = nextHeight;
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _editCommentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('Please login to like and comment on stories.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (context) => const LoginDialog(),
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.story;
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final topPadding = MediaQuery.paddingOf(context).top;
    const headerOverlap = 56.0;
    // photo's height is either 400 or screenWidth, whichever is smaller
    final photoHeight = screenWidth < 200 + topPadding
        ? screenWidth
        : 200.0 + topPadding;
    _photoHeightThreshold = photoHeight;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderCardHeight();
    });

    debugPrint('topPadding: $topPadding, photoHeight: $photoHeight');
    return SizedBox.expand(
      child: Scaffold(
        backgroundColor: cs.surfaceContainerHigh,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height:
                                  photoHeight +
                                  (_headerCardHeight - headerOverlap).clamp(
                                    0,
                                    double.infinity,
                                  ),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 0,
                                    height: photoHeight,
                                    child: Stack(
                                      children: [
                                        if (story.thumbnailBucket != null &&
                                            story.thumbnailFileName != null)
                                          Hero(
                                            tag:
                                                'green-square-story-image-${story.id}',
                                            child: CachedNetworkImage(
                                              imageUrl: getImageLink(
                                                story.thumbnailBucket!,
                                                story.thumbnailFileName!,
                                                folderPath:
                                                    story.thumbnailFolderPath!,
                                              ),
                                              height: photoHeight,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Container(
                                                        height: photoHeight,
                                                        width: double.infinity,
                                                        color: Colors.grey[300],
                                                      ),
                                            ),
                                          )
                                        else
                                          Container(
                                            height: photoHeight,
                                            width: double.infinity,
                                            color: Colors.grey[300],
                                          ),
                                        SafeArea(
                                          bottom: false,
                                          child: Align(
                                            alignment: Alignment.topLeft,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    16,
                                                    4,
                                                    0,
                                                    0,
                                                  ),
                                              child: IconButton(
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                                icon: const Icon(
                                                  Icons.arrow_back,
                                                  color: Colors.white,
                                                ),
                                                style: IconButton.styleFrom(
                                                  backgroundColor: Colors.black
                                                      .withValues(
                                                        alpha: 0.5,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    left: 24,
                                    right: 24,
                                    top: photoHeight - headerOverlap,
                                    child: Container(
                                      key: _headerCardKey,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 24,
                                        horizontal: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            story.title ?? '',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.titleLarge,
                                          ),
                                          if (story.subtitle != null &&
                                              story.subtitle!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 16,
                                              ),
                                              child: Text(
                                                story.subtitle!,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodyMedium,
                                              ),
                                            ),

                                          // Add date here separated by dots, YYYY.MM.DD
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 24,
                                            ),
                                            child: Text(
                                              '${story.createdAt.year.toString().padLeft(4, '0')}.${story.createdAt.month.toString().padLeft(2, '0')}.${story.createdAt.day.toString().padLeft(2, '0')}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant
                                                        .withAlpha(
                                                          180,
                                                        ),
                                                  ),
                                            ),
                                          ),

                                          if (widget.tags.isNotEmpty) ...[
                                            const SizedBox(height: 16),
                                            Wrap(
                                              spacing: 8,
                                              children: widget.tags
                                                  .map(
                                                    (tag) => InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      onTap: () {
                                                        final raw =
                                                            (tag.tag ?? '')
                                                                .trim();
                                                        if (raw.isEmpty) return;
                                                        Navigator.of(
                                                          context,
                                                        ).pop('#$raw');
                                                      },
                                                      child: Chip(
                                                        label: Text(
                                                          '#${tag.tag ?? ''}',
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (story.content != null &&
                                story.content!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  26,
                                  32,
                                  26,
                                  0,
                                ),
                                child: TextStory(
                                  content: story.content,
                                ),
                              ),

                            const SizedBox(height: 24),
                            Center(
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: Divider(
                                  height: 2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                spacing: 8,
                                children: [
                                  Text(
                                    '본 콘텐츠는 친환경 소비는 마땅히 즐겁고',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    '행복해야 한다는 생각으로,',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    '친환경&친자연 제품과 서비스,',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    '공간을 널리 알리고 이롭게 하는',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: cs.primary,
                                    ),
                                  ),
                                  Text(
                                    'Code Green Square 가 지속적으로 발행합니다.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 40),
                            Row(
                              children: [
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(
                                    hasLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: hasLiked ? Colors.red : null,
                                  ),
                                  onPressed: userId == null
                                      ? () => _showLoginDialog(context)
                                      : () async {
                                          await StoryService.instance
                                              .toggleLike(
                                                story.id,
                                                userId!,
                                              );
                                          setState(() {
                                            hasLiked = !hasLiked;
                                            likeCount += hasLiked ? 1 : -1;
                                          });
                                        },
                                ),
                                Text('$likeCount'),

                                const SizedBox(width: 16),
                                IconButton(
                                  icon: const Icon(Icons.comment_outlined),
                                  onPressed: () {
                                    if (userId != null) {
                                      _commentFocusNode.requestFocus();
                                    }
                                  },
                                ),
                                Text('${comments.length}'),
                                Spacer(),
                                // Share button
                                IconButton(
                                  icon: const Icon(Icons.share_outlined),
                                  onPressed: () {},
                                ),
                                PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (context) => [
                                    PopupMenuItem<String>(
                                      value: isBlocked ? 'unblock' : 'block',
                                      child: Text(isBlocked ? '차단 해제' : '차단하기'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'report',
                                      child: Text('신고하기'),
                                    ),
                                  ],
                                  onSelected: (value) async {
                                    if (value == 'block') {
                                      final userId = this.userId;
                                      if (userId == null) return;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('스토리 차단'),
                                          content: const Text(
                                            '이 스토리를 차단하시겠습니까?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('차단'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await StoryService.instance.blockStory(
                                          storyId: widget.story.id,
                                          userId: userId,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('스토리가 차단되었습니다.'),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          isBlocked = true;
                                        });
                                      }
                                    } else if (value == 'unblock') {
                                      final userId = this.userId;
                                      if (userId == null) return;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('스토리 차단 해제'),
                                          content: const Text(
                                            '이 스토리의 차단을 해제하시겠습니까?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('해제'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await StoryService.instance
                                            .unblockStory(
                                              storyId: widget.story.id,
                                              userId: userId,
                                            );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('스토리 차단이 해제되었습니다.'),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          isBlocked = false;
                                        });
                                      }
                                    } else if (value == 'report') {
                                      final userId = this.userId;
                                      if (userId == null) return;

                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('스토리 신고'),
                                          content: const Text(
                                            '이 스토리를 신고하시겠습니까?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('취소'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              child: const Text('신고'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true) {
                                        await StoryService.instance.reportStory(
                                          storyId: widget.story.id,
                                          userId: userId,
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('신고가 접수되었습니다.'),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: _kCommentDividerColor,
                            ),
                            ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: _kCommentDividerColor,
                                  ),
                              itemBuilder: (context, index) {
                                final commentWithUser = comments[index];
                                final isBlockedComment = _blockedCommentIds
                                    .contains(
                                      commentWithUser.comment.id,
                                    );
                                if (isBlockedComment) {
                                  return Padding(
                                    padding: _kCommentRowPadding,
                                    child: _buildBlockedCommentRow(
                                      context,
                                      commentWithUser.comment.id,
                                      theme,
                                    ),
                                  );
                                }
                                final isOwner =
                                    userId != null &&
                                    commentWithUser.comment.commentBy.trim() ==
                                        userId!.trim();
                                return Padding(
                                  padding: _kCommentRowPadding,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      _commentDefaultProfileAvatar(),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    commentWithUser
                                                            .commentBy
                                                            .username ??
                                                        commentWithUser
                                                            .commentBy
                                                            .email ??
                                                        'Anonymous',
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              _kCommentNameColor,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _formatDateYyyyMmDd(
                                                    commentWithUser
                                                        .comment
                                                        .createdAt,
                                                  ),
                                                  style: theme
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color:
                                                            _kCommentDateColor,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                ),
                                                const Spacer(),
                                                if (userId != null &&
                                                    isOwner) ...[
                                                  TextButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        _editingCommentId =
                                                            commentWithUser
                                                                .comment
                                                                .id;
                                                        _editCommentController
                                                                .text =
                                                            commentWithUser
                                                                .comment
                                                                .comment ??
                                                            '';
                                                      });
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      foregroundColor:
                                                          _kCommentActionColor,
                                                      textStyle:
                                                          _commentActionButtonStyle(
                                                            theme,
                                                          ),
                                                    ),
                                                    child: const Text('수정'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    onPressed: () async {
                                                      final confirmed =
                                                          await _confirmDeleteComment(
                                                            context,
                                                          );
                                                      if (confirmed == true) {
                                                        await StoryService
                                                            .instance
                                                            .deleteComment(
                                                              commentWithUser
                                                                  .comment
                                                                  .id,
                                                            );
                                                        if (!mounted) return;
                                                        setState(() {
                                                          comments.removeAt(
                                                            index,
                                                          );
                                                        });
                                                        await _showDeleteCompletedDialog(
                                                          context,
                                                        );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      foregroundColor:
                                                          _kCommentActionColor,
                                                      textStyle:
                                                          _commentActionButtonStyle(
                                                            theme,
                                                          ),
                                                    ),
                                                    child: const Text('삭제'),
                                                  ),
                                                ] else if (userId != null &&
                                                    !isOwner) ...[
                                                  TextButton(
                                                    onPressed: () async {
                                                      final confirmed =
                                                          await _confirmBlockComment(
                                                            context,
                                                          );
                                                      if (confirmed != true)
                                                        return;
                                                      try {
                                                        await StoryService
                                                            .instance
                                                            .blockComment(
                                                              commentId:
                                                                  commentWithUser
                                                                      .comment
                                                                      .id,
                                                              userId: userId!,
                                                            );
                                                        if (!mounted) return;
                                                        setState(() {
                                                          _blockedCommentIds
                                                              .add(
                                                                commentWithUser
                                                                    .comment
                                                                    .id,
                                                              );
                                                        });
                                                        await _showBlockCompletedDialog(
                                                          context,
                                                        );
                                                      } catch (_) {
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              '차단에 실패했습니다. 다시 시도해 주세요.',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      foregroundColor:
                                                          _kCommentActionColor,
                                                      textStyle:
                                                          _commentActionButtonStyle(
                                                            theme,
                                                          ),
                                                    ),
                                                    child: const Text('차단'),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  TextButton(
                                                    onPressed: () async {
                                                      final confirmed =
                                                          await _confirmReportComment(
                                                            context,
                                                          );
                                                      if (confirmed != true)
                                                        return;
                                                      try {
                                                        await StoryService
                                                            .instance
                                                            .reportComment(
                                                              commentId:
                                                                  commentWithUser
                                                                      .comment
                                                                      .id,
                                                              userId: userId!,
                                                            );
                                                        if (!mounted) return;
                                                        await _showReportCompletedDialog(
                                                          context,
                                                        );
                                                      } catch (_) {
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                              '신고에 실패했습니다. 다시 시도해 주세요.',
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                      foregroundColor:
                                                          _kCommentActionColor,
                                                      textStyle:
                                                          _commentActionButtonStyle(
                                                            theme,
                                                          ),
                                                    ),
                                                    child: const Text('신고'),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            if (isOwner &&
                                                commentWithUser.comment.id ==
                                                    _editingCommentId)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _editCommentController,
                                                    maxLines: null,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color:
                                                              _kCommentBodyColor,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                    decoration: const InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                            vertical: 8,
                                                          ),
                                                      border:
                                                          UnderlineInputBorder(),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _editingCommentId =
                                                                null;
                                                            _editCommentController
                                                                .clear();
                                                          });
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor:
                                                              _kCommentActionColor,
                                                          textStyle:
                                                              _commentActionButtonStyle(
                                                                theme,
                                                              ),
                                                        ),
                                                        child: const Text('취소'),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      TextButton(
                                                        onPressed: () async {
                                                          final updatedText =
                                                              _editCommentController
                                                                  .text
                                                                  .trim();
                                                          if (updatedText
                                                              .isEmpty) {
                                                            return;
                                                          }

                                                          await StoryService
                                                              .instance
                                                              .updateComment(
                                                                commentWithUser
                                                                    .comment
                                                                    .id,
                                                                updatedText,
                                                              );
                                                          if (!mounted) {
                                                            return;
                                                          }
                                                          setState(() {
                                                            comments[index] = StoryCommentWithUser(
                                                              comment:
                                                                  commentWithUser
                                                                      .comment
                                                                      .copyWith(
                                                                        comment:
                                                                            updatedText,
                                                                      ),
                                                              commentBy:
                                                                  commentWithUser
                                                                      .commentBy,
                                                            );
                                                            _editingCommentId =
                                                                null;
                                                          });
                                                        },
                                                        style: TextButton.styleFrom(
                                                          foregroundColor:
                                                              _kCommentActionColor,
                                                          textStyle:
                                                              _commentActionButtonStyle(
                                                                theme,
                                                              ),
                                                        ),
                                                        child: const Text('저장'),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                commentWithUser
                                                        .comment
                                                        .comment ??
                                                    '',
                                                style: theme
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: _kCommentBodyColor,
                                                      fontWeight:
                                                          FontWeight.w300,
                                                    ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            if (comments.isNotEmpty)
                              const Divider(
                                height: 1,
                                thickness: 1,
                                color: _kCommentDividerColor,
                              ),
                            if (userId == null)
                              const Padding(
                                padding: _kCommentRowPadding,
                                child: Text(
                                  'Login to comment',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              Padding(
                                padding: _kCommentRowPadding,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    _commentDefaultProfileAvatar(),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            UserAuthService
                                                .instance
                                                .displayName,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: _kCommentNameColor,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          TextField(
                                            controller: _commentController,
                                            focusNode: _commentFocusNode,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: _kCommentBodyColor,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                            decoration: const InputDecoration(
                                              hintText: 'Add a comment',
                                              border: OutlineInputBorder(),
                                            ),
                                            onSubmitted: (value) async {
                                              if (value.isNotEmpty) {
                                                await StoryService.instance
                                                    .addComment(
                                                      story.id,
                                                      userId!,
                                                      value,
                                                    );
                                                _commentController.clear();
                                                await _loadData(); // refetch
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
                if (!isLoadingRecommendations &&
                    recommendedProducts.isNotEmpty) ...[
                  // Recommended Products
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text(
                              '추천 상품',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...recommendedProducts.asMap().entries.expand(
                            (entry) {
                              final index = entry.key;
                              final productWithDetails = entry.value;
                              return [
                                if (index > 0)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Divider(
                                      height: 1,
                                      thickness: 1,
                                      color: cs.outlineVariant,
                                    ),
                                  ),
                                _RecommendedProductListTile(
                                  productWithDetails: productWithDetails,
                                  baseDiscountRate: _baseDiscountRate,
                                  onTap: () => _navigateToProductDetail(
                                    productWithDetails,
                                  ),
                                ),
                              ];
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
                if (!isLoadingRecommendations &&
                    recommendedMissions.isNotEmpty) ...[
                  // Recommended Missions
                  SliverToBoxAdapter(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                            child: Text(
                              '추천 미션',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ...recommendedMissions.map(
                            (mission) => MissionAvailableListTile(
                              mission: mission,
                              onTap: (mission) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MissionDetailDialog(
                                      mission: mission,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 16),
                  ),
                ],
                // Other Interesting Stories
                SliverToBoxAdapter(
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Text(
                            '흥미로운 다른 이야기들',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isLoadingPreviousStories)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (previousStories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Text(
                              '다른 이야기가 없습니다.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 0.78,
                                  ),
                              itemCount: previousStories.take(4).length,
                              itemBuilder: (context, index) {
                                final storyWithTags = previousStories[index];
                                return _RecommendedStoryGridTile(
                                  storyWithTags: storyWithTags,
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomPadding + 16),
                ),
              ],
            ),
            if (story.title != null)
              IgnorePointer(
                ignoring: !_showTopAppBar,
                child: AnimatedSlide(
                  offset: _showTopAppBar ? Offset.zero : const Offset(0, -0.1),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: AnimatedOpacity(
                    opacity: _showTopAppBar ? 1 : 0,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: Material(
                      color: theme.scaffoldBackgroundColor,
                      child: Padding(
                        padding: EdgeInsets.only(top: topPadding),
                        child: SizedBox(
                          height: kToolbarHeight,
                          child: Row(
                            children: [
                              SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: Text(
                                  story.title!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedStoryGridTile extends StatelessWidget {
  const _RecommendedStoryGridTile({
    required this.storyWithTags,
  });

  final StoryWithTags storyWithTags;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final story = storyWithTags.story;

    final imageUrl =
        story.thumbnailBucket != null && story.thumbnailFileName != null
        ? getImageLink(
            story.thumbnailBucket!,
            story.thumbnailFileName!,
            folderPath: story.thumbnailFolderPath!,
          )
        : null;

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => StoryDialog(
            story: storyWithTags.story,
            tags: storyWithTags.tags,
          ),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        elevation: 0.1,
        color: cs.surfaceContainerLowest,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: imageUrl == null
                  ? Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_outlined,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  : Hero(
                      tag: 'green-square-story-image-${story.id}',
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                story.title ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedProductListTile extends StatelessWidget {
  const _RecommendedProductListTile({
    required this.productWithDetails,
    required this.baseDiscountRate,
    required this.onTap,
  });

  final ProductWithOtherDetails productWithDetails;
  final double baseDiscountRate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final product = productWithDetails.product;

    final double? regularPrice = product.regularPrice;
    final int? discountedPrice = regularPrice == null
        ? null
        : minimumPriceAmount(
            regularPrice: regularPrice,
            baseDiscountRate: baseDiscountRate,
            platformDiscountRate: product.platformDiscountRate ?? 0.0,
            vendorDiscountRate: product.vendorDiscountRate ?? 0.0,
          );
    final hasDiscount =
        regularPrice != null &&
        discountedPrice != null &&
        regularPrice > 0 &&
        discountedPrice < regularPrice;
    final int? discountPercentage = hasDiscount
        ? (((regularPrice - discountedPrice) / regularPrice) * 100).round()
        : null;

    final imageUrl =
        product.mainImageBucket != null && product.mainImageFileName != null
        ? getImageLink(
            product.mainImageBucket!,
            product.mainImageFileName!,
            folderPath: product.mainImageFolderPath,
          )
        : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRect(
                child: imageUrl == null
                    ? Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(
                          Icons.image_outlined,
                          color: cs.onSurfaceVariant,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => Container(
                          color: cs.surfaceContainerHighest,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.title ?? '제품명 없음',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (product.name != null && product.name!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    formatKRW(regularPrice ?? 0),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (discountPercentage != null) ...[
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          const TextSpan(text: '친환경 소비자라면, '),
                          TextSpan(
                            text: '$discountPercentage%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.secondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const TextSpan(text: '↓'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formatKRW(discountedPrice!),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: cs.secondary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
