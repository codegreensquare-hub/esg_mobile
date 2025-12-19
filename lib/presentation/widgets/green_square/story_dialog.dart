import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/story_comment_with_user.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:esg_mobile/presentation/screens/auth/login.screen.dart';
import 'package:esg_mobile/presentation/widgets/green_square/text.story.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerCardKey = GlobalKey();
  double _headerCardHeight = 0;
  bool _showTopAppBar = false;
  double _photoHeightThreshold = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = Supabase.instance.client.auth.currentUser?.id;
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
    bool liked = false;
    if (userId != null) {
      liked = await StoryService.instance.hasUserLiked(storyId, userId!);
    }
    setState(() {
      comments = fetchedComments;
      likeCount = count;
      hasLiked = liked;
    });
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
              // Navigate to login screen
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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
                    color: cs.surface,
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
                                            child: Image.network(
                                              getImageLink(
                                                story.thumbnailBucket!,
                                                story.thumbnailFileName!,
                                                folderPath:
                                                    story.thumbnailFolderPath!,
                                              ),
                                              height: photoHeight,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
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
                                                    (tag) => Chip(
                                                      label: Text(
                                                        '#${tag.tag ?? ''}',
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
                                SizedBox(width: 10),
                              ],
                            ),
                            Divider(
                              height: 1,
                            ),

                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final commentWithUser = comments[index];
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    16,
                                    16,
                                    0,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: const CircleAvatar(
                                          child: Icon(
                                            Icons.person,
                                          ), // placeholder
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              commentWithUser
                                                      .commentBy
                                                      .username ??
                                                  commentWithUser
                                                      .commentBy
                                                      .email ??
                                                  'Anonymous',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              commentWithUser.comment.comment ??
                                                  '',
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              commentWithUser.comment.createdAt
                                                  .toString(),
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color: cs.onSurfaceVariant,
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
                            if (userId == null)
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 24,
                                ),
                                child: Text(
                                  'Login to comment',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            else
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  16,
                                  16,
                                  0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: 4.0,
                                      ),
                                      child: const CircleAvatar(
                                        child: Icon(
                                          Icons.person,
                                        ), // placeholder
                                      ),
                                    ),
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
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          SizedBox(height: 4),
                                          TextField(
                                            controller: _commentController,
                                            focusNode: _commentFocusNode,
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
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 12),
                ),
                SliverToBoxAdapter(
                  child: Container(
                    color: cs.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text("Second container")],
                    ),
                  ),
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
