import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/services/database/story.service.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/login/code_green_login.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/lookbook_entry_viewer.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/mission_participation.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/wishlisted_products.dialog.dart';
import 'package:esg_mobile/presentation/screens/green_square/shopping_mall.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/story/story.tab.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_dialog.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/code_green/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/code_green/code_green_hero_banner.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_detail.dialog.dart';
import 'package:esg_mobile/presentation/widgets/layout/footer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/left_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/nav_header.delegate.dart';
import 'package:go_router/go_router.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/core/constants/navigation.dart';
import 'package:esg_mobile/core/constants/green_square_navigation.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/brand_story.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_inquiry.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/about_cog.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/terms.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/notices.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/faq.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/contact.screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/web_updater.dart'
    if (dart.library.html) 'dart:js'
    as js;
import 'package:flutter/foundation.dart';

class MainScreen extends StatefulWidget {
  static const String route = '/';
  final ScrollController? controller;
  final MainTab initialTab;
  final GoRouterState? state;

  const MainScreen({
    super.key,
    this.controller,
    this.initialTab = MainTab.greenSquare,
    this.state,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final ScrollController _scrollController;
  double _scrollOffset = 0.0;
  int _selectedIndex = 0; // active tab index
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  MainTab _selectedMainTab = MainTab.greenSquare;
  int _greenIndex = 0; // 0: Story, 1: Shopping, 2: Participate, 3: Account
  late final CurationShopTabController _curationShopController;
  late final OriginalShopTabController _originalShopController;
  late final CodeGreenProductDetailTabController _productDetailController;
  String? _productIdToOpen;
  String? _storyIdToOpen;
  String? _missionIdToOpen;
  int _codeGreenLastNonProductTabIndex = 0;

  String? _selectedLookbookId;
  String? _selectedLookbookTitle;
  List<String> _lookbookTitles = ['All', 'Loading lookbooks...'];

  // Badge counts for floating buttons
  int _cartItemCount = 0;
  int _wishlistItemCount = 0;

  static const Set<String> _codeGreenHeroTabs = {
    HomeTab.tab,
    CurationShopTab.tab,
    OriginalShopTab.tab,
  };

  static const double _topHeaderHeight =
      72; // header height excluding status bar
  static const double _toolbarHeight = 72; // floating bar height

  @override
  void initState() {
    super.initState();
    debugPrint('MainScreen initialized with initialTab: ${widget.initialTab}');
    _selectedMainTab = widget.initialTab;
    if (_selectedMainTab == MainTab.codeGreen && widget.state != null) {
      final path = widget.state!.uri.path;
      switch (path) {
        case '/codegreen/original':
          _selectedIndex = 1;
          break;
        case '/codegreen/curation':
          _selectedIndex = 2;
          break;
        case '/codegreen/about':
          _selectedIndex = 3;
          break;
        case '/codegreen/lookbook':
          _selectedIndex = 4;
          break;
        case '/codegreen/event':
          _selectedIndex = 6;
          break;
        default:
          _selectedIndex = 0;
      }
    } else if (_selectedMainTab == MainTab.greenSquare &&
        widget.state != null) {
      final path = widget.state!.uri.path;
      if (path == '/greensquare/store') {
        _greenIndex = 1;
        _productIdToOpen = widget.state!.uri.queryParameters['product'];
      } else if (path == '/greensquare/missions') {
        _greenIndex = 2;
        _missionIdToOpen = widget.state!.uri.queryParameters['mission'];
      } else if (path == '/greensquare/account') {
        _greenIndex = 3;
      } else {
        _greenIndex = 0;
        _storyIdToOpen = widget.state!.uri.queryParameters['story'];
      }
    }
    if (_storyIdToOpen != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openStoryById(_storyIdToOpen!),
      );
    }
    if (_missionIdToOpen != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _openMissionById(_missionIdToOpen!),
      );
    }
    _curationShopController = CurationShopTabController();
    _originalShopController = OriginalShopTabController();
    _productDetailController = CodeGreenProductDetailTabController();
    _scrollController = widget.controller ?? ScrollController();
    _scrollController.addListener(() {
      final offset = _scrollController.hasClients
          ? _scrollController.position.pixels
          : 0.0;
      if (offset != _scrollOffset) {
        setState(() => _scrollOffset = offset);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateBadgeCounts());
    _fetchLookbookTitles();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _curationShopController.dispose();
    _originalShopController.dispose();
    _productDetailController.dispose();
    super.dispose();
  }

  Future<void> _updateBadgeCounts() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _cartItemCount = 0;
        _wishlistItemCount = 0;
      });
      return;
    }

    try {
      final cartItems = await CartService.instance.fetchCartItems(userId);
      final wishlistedProducts = await ProductService.instance
          .fetchWishlistedProducts(userId);

      if (mounted) {
        setState(() {
          _cartItemCount = cartItems.length;
          _wishlistItemCount = wishlistedProducts.length;
        });
      }
    } catch (e) {
      debugPrint('Error updating badge counts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeTop = MediaQuery.of(context).padding.top;

    // Compute how much of the status bar padding the floating header should include.
    //  - At scrollOffset = 0 (not floating): topPad = 0.
    //  - After scrolling past the top header + safeTop (floating at top): topPad = safeTop.
    final double removalEnd = safeTop + _topHeaderHeight;
    final double t = removalEnd <= 0
        ? 1.0
        : (_scrollOffset / removalEnd).clamp(0.0, 1.0);
    final double topPad = safeTop * t;

    // Active tab id derived from selected index.
    final String activeTabId = codeGreenTabs[_selectedIndex];

    final bool isGreenSquare = _selectedMainTab == MainTab.greenSquare;
    final bool shouldShowHeroBanner =
        _selectedMainTab == MainTab.codeGreen &&
        _codeGreenHeroTabs.contains(activeTabId);

    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainer,
      key: _scaffoldKey,
      drawer: _selectedMainTab == MainTab.codeGreen
          ? CodeGreenLeftDrawer(
              tabs: codeGreenTabs,
              selectedIndex: _selectedIndex,
              labels: codeGreenLabels,
              homeTab: HomeTab.tab,
              onSelect: (index) {
                if (index != _selectedIndex) {
                  setState(() => _selectedIndex = index);
                  _updateUrlForCodeGreenTab(index);
                }
              },
              onTapGreenSquare: () {
                setState(() => _selectedMainTab = MainTab.greenSquare);
                _updateUrl(MainTab.greenSquare);
              },
              onTapLogin: _openCodeGreenLogin,
              onSelectSubTab: _handleCodeGreenSubTab,
            )
          : null,
      endDrawer: isGreenSquare
          ? GreenSquareRightDrawer(
              onSelect: _handleGreenSquareDrawerSelection,
            )
          : null,
      bottomNavigationBar: isGreenSquare
          ? GreenSquareBottomNavBar(
              selectedIndex: _greenIndex,
              onItemSelected: (index) {
                setState(() => _greenIndex = index);
                _updateUrlForGreenSquareTab(index);
              },
              onGreenButtonPressed: _onTapKnock,
            )
          : null,
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,

            physics: ClampingScrollPhysics(),
            slivers: [
              CodeGreenTopHeader(
                initialValue: _selectedMainTab,
                onChanged: (tab) {
                  setState(() => _selectedMainTab = tab);
                  _updateUrl(tab);
                },
                actions: [
                  if (_selectedMainTab == MainTab.greenSquare)
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      tooltip: '그린스퀘어 메뉴',
                      onPressed: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                ],
              ),
              if (_selectedMainTab == MainTab.codeGreen)
                SliverPersistentHeader(
                  floating: true,
                  pinned: false,
                  delegate: CodeGreenNavHeaderDelegate(
                    tabs: codeGreenTabs,
                    theme: theme,
                    toolbarHeight: _toolbarHeight,
                    topPad: topPad,
                    labels: codeGreenLabels,
                    currentWidth: width,
                    homeTab: HomeTab.tab,
                    selectedIndex: _selectedIndex,
                    onTabSelected: (index, _) {
                      if (index != _selectedIndex) {
                        setState(() => _selectedIndex = index);
                        _updateUrlForCodeGreenTab(index);
                      }
                    },
                    onTapMenu: () => _scaffoldKey.currentState?.openDrawer(),
                    onTapLogin: _openCodeGreenLogin,
                    onTapCart: _showCartBottomSheet,
                    onTapGreenSquare: () {
                      setState(() => _selectedMainTab = MainTab.greenSquare);
                      _updateUrl(MainTab.greenSquare);
                    },
                    onSelectSubTab: _handleCodeGreenSubTab,
                    dynamicSubTabs: {LookBookTab.tab: _lookbookTitles},
                  ),
                ),
              if (shouldShowHeroBanner)
                SliverToBoxAdapter(
                  child: CodeGreenHeroBanner(),
                ),
              if (_selectedMainTab == MainTab.greenSquare)
                SliverToBoxAdapter(
                  child: Container(
                    // constraints: const BoxConstraints(minHeight: 600),
                    padding: EdgeInsets.zero,
                    margin: EdgeInsets.zero,
                    width: double.infinity,
                    color: theme.colorScheme.surfaceContainer,
                    child: _buildGreenSquareContent(_greenIndex),
                  ),
                ),

              if (_selectedMainTab == MainTab.codeGreen)
                SliverToBoxAdapter(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.zero,
                      key: ValueKey(activeTabId),
                      color: theme.colorScheme.surface,
                      width: double.infinity,
                      child: _buildTabContent(activeTabId),
                    ),
                  ),
                ),

              if (_selectedMainTab == MainTab.codeGreen)
                SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: const CodeGreenFooter(),
                ),
            ],
          ),
          if (_selectedMainTab == MainTab.greenSquare)
            SafeArea(
              top: false,
              bottom: false,
              child: Container(
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,

                  children: [
                    if (_scrollOffset > 100)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScrollUpButton(
                            onPressed: _scrollToTop,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    FloatingActionButtonWithBadge(
                      icon: Icons.shopping_cart,
                      badgeCount: _cartItemCount,
                      tooltip: '장바구니',
                      backgroundColor: Colors.grey[800],
                      iconColor: Colors.white,
                      onPressed: _showCartBottomSheet,
                    ),
                    const SizedBox(height: 8),
                    KakaoTalkButton(
                      onPressed: _launchKakaoTalk,
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButtonWithBadge(
                      icon: Icons.favorite,
                      badgeCount: _wishlistItemCount,
                      tooltip: '찜 목록',
                      backgroundColor: Colors.grey[800],
                      iconColor: Colors.red,
                      onPressed: _showWishlistDialog,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Returns the widget for the given tab id. Uses keys to preserve state.
  Widget _buildTabContent(String tabId) {
    switch (tabId) {
      case HomeTab.tab:
        return HomeTab(
          key: const PageStorageKey(HomeTab.tab),
          onTapNatureMaterial: _openOriginalShop,
          onTapVeganMaterial: _openOriginalShop,
          onTapBiodegradableMaterial: _openOriginalShop,
          onTapGreenSquare: _openGreenSquare,
          onTapProduct: _openCodeGreenProduct,
          onTapStory: _openGreenSquareStory,
        );
      case OriginalShopTab.tab:
        return OriginalShopTab(
          key: const PageStorageKey(OriginalShopTab.tab),
          controller: _originalShopController,
          onTapProduct: _openCodeGreenProduct,
        );
      case CurationShopTab.tab:
        return CurationShopTab(
          key: const PageStorageKey(CurationShopTab.tab),
          controller: _curationShopController,
          onTapProduct: _openCodeGreenProduct,
        );
      case CodeGreenProductDetailTab.tab:
        return CodeGreenProductDetailTab(
          key: const PageStorageKey(CodeGreenProductDetailTab.tab),
          controller: _productDetailController,
          onBack: _closeCodeGreenProduct,
        );
      case AboutTab.tab:
        return AboutTab(
          key: const PageStorageKey(AboutTab.tab),
          onTapCodeGreenProducts: _openCurationShop,
          onTapGreenSquare: _openGreenSquare,
        );
      case LookBookTab.tab:
        return LookBookTab(
          key: const PageStorageKey(LookBookTab.tab),
          onOpenLookbook: (lookbookId, lookbookTitle) {
            final idx = codeGreenTabs.indexOf(lookbookEntryViewerTabId);
            if (idx < 0) return;

            setState(() {
              _selectedLookbookId = lookbookId;
              _selectedLookbookTitle = lookbookTitle;
              _selectedMainTab = MainTab.codeGreen;
              _selectedIndex = idx;
            });

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              if (!_scrollController.hasClients) return;
              _scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOut,
              );
            });
          },
        );
      case lookbookEntryViewerTabId:
        return LookbookEntryViewerTab(
          key: const PageStorageKey(LookbookEntryViewerTab.tab),
          lookbookId: _selectedLookbookId,
          lookbookTitle: _selectedLookbookTitle,
          onOpenProduct: _openCodeGreenProduct,
        );
      case EventTab.tab:
        return const EventTab(key: PageStorageKey(EventTab.tab));
      case codeGreenLoginTabId:
        return const CodeGreenLoginTab(
          key: PageStorageKey(codeGreenLoginTabId),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _openCodeGreenProduct(ProductWithOtherDetails product) {
    final idx = codeGreenTabs.indexOf(CodeGreenProductDetailTab.tab);
    if (idx < 0) return;

    final homeIdx = codeGreenTabs.indexOf(HomeTab.tab);
    final fallbackIdx = homeIdx >= 0 ? homeIdx : 0;
    _codeGreenLastNonProductTabIndex =
        (_selectedMainTab == MainTab.codeGreen && _selectedIndex != idx)
        ? _selectedIndex
        : fallbackIdx;

    _productDetailController.select(product);
    setState(() {
      _selectedMainTab = MainTab.codeGreen;
      _selectedIndex = idx;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  void _closeCodeGreenProduct() {
    _productDetailController.clear();
    setState(() {
      _selectedMainTab = MainTab.codeGreen;
      _selectedIndex = _codeGreenLastNonProductTabIndex;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _openOriginalShop() {
    final idx = codeGreenTabs.indexOf(OriginalShopTab.tab);
    if (idx < 0) return;
    if (idx == _selectedIndex) return;
    setState(() {
      _selectedMainTab = MainTab.codeGreen;
      _selectedIndex = idx;
    });
  }

  void _openCurationShop() {
    final idx = codeGreenTabs.indexOf(CurationShopTab.tab);
    if (idx < 0) return;
    if (idx == _selectedIndex) return;
    setState(() {
      _selectedMainTab = MainTab.codeGreen;
      _selectedIndex = idx;
    });
  }

  void _openGreenSquare() {
    setState(() {
      _selectedMainTab = MainTab.greenSquare;
      _selectedIndex = 0;
    });
    _updateBadgeCounts();
  }

  void _openGreenSquareStory(StoryWithTags storyWithTags) {
    setState(() {
      _selectedMainTab = MainTab.greenSquare;
      _selectedIndex = 0;
      _greenIndex = 0; // ensure Green Square "스토리" tab
    });
    _updateBadgeCounts();
    _updateUrlForStory(storyWithTags.story.id);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context)
          .push(
            MaterialPageRoute(
              fullscreenDialog: true,
              builder: (context) => StoryDialog(
                story: storyWithTags.story,
                tags: storyWithTags.tags,
              ),
            ),
          )
          .then((_) {
            if (mounted) {
              _updateUrl(MainTab.greenSquare);
            }
          });
    });
  }

  Future<void> _openStoryById(String storyId) async {
    try {
      final story = await StoryService.instance.fetchStoryWithTagsById(storyId);
      if (story != null && mounted) {
        _openGreenSquareStory(story);
      }
    } catch (e) {
      debugPrint('Error fetching story: $e');
    }
  }

  Future<void> _openMissionById(String missionId) async {
    try {
      final mission = await MissionService.instance.fetchById(missionId);
      if (mission != null && mounted) {
        _openMissionDetail(mission);
      }
    } catch (e) {
      debugPrint('Error fetching mission: $e');
    }
  }

  Future<LookbookRow?> _fetchLookbookByTitle(String title) async {
    try {
      final response = await Supabase.instance.client
          .from(LookbookTable().tableName)
          .select()
          .eq(LookbookRow.nameField, title)
          .maybeSingle();
      if (response != null) {
        return LookbookRow.fromJson(response);
      }
    } catch (e) {
      debugPrint('Error fetching lookbook by title: $e');
    }
    return null;
  }

  Future<void> _fetchLookbookTitles() async {
    try {
      final response = await Supabase.instance.client
          .from(LookbookTable().tableName)
          .select(LookbookRow.nameField)
          .order(LookbookRow.createdAtField, ascending: false);
      final titles = (response as List)
          .map((e) => e[LookbookRow.nameField] as String)
          .toList();
      final effectiveTitles = titles.isEmpty
          ? ['All', 'No lookbooks available']
          : ['All', ...titles];
      if (mounted) {
        setState(() => _lookbookTitles = effectiveTitles);
      }
    } catch (e) {
      debugPrint('Error fetching lookbook titles: $e');
      if (mounted) {
        setState(() => _lookbookTitles = ['All', 'Error: $e']);
      }
    }
  }

  void _openMissionDetail(MissionRow mission) {
    _updateUrlForMission(mission.id);
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => MissionDetailDialog(mission: mission),
          ),
        )
        .then((_) {
          if (mounted) {
            _updateUrl(MainTab.greenSquare);
          }
        });
  }

  void _openCodeGreenLogin() {
    final idx = codeGreenTabs.indexOf(codeGreenLoginTabId);
    if (idx < 0) return;
    setState(() {
      _selectedMainTab = MainTab.codeGreen;
      _selectedIndex = idx;
    });
  }

  void _handleCodeGreenSubTab(String parentTab, String subTab) {
    if (parentTab == 'look_book') {
      if (subTab == 'All') {
        final idx = codeGreenTabs.indexOf(LookBookTab.tab);
        if (idx >= 0) {
          setState(() => _selectedIndex = idx);
        }
      } else {
        _fetchLookbookByTitle(subTab).then((lookbook) {
          if (lookbook != null && mounted) {
            setState(() {
              _selectedLookbookId = lookbook.id;
              _selectedLookbookTitle = lookbook.name;
              _selectedIndex = codeGreenTabs.indexOf(lookbookEntryViewerTabId);
            });
          }
        });
      }
    } else if (parentTab == OriginalShopTab.tab) {
      _curationShopController.selectById(subTab);
      final idx = codeGreenTabs.indexOf(parentTab);
      if (idx >= 0 && idx != _selectedIndex) {
        setState(() => _selectedIndex = idx);
      }
    } else if (parentTab == OriginalShopTab.tab) {
      _originalShopController.selectById(subTab);
      final idx = codeGreenTabs.indexOf(parentTab);
      if (idx >= 0 && idx != _selectedIndex) {
        setState(() => _selectedIndex = idx);
      }
    }
  }

  Future<void> _showCartBottomSheet() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    final items = await CartService.instance.fetchCartItems(userId);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _selectedMainTab == MainTab.greenSquare
          ? CartBottomSheet(items: items)
          : CodeGreenCartBottomSheet(items: items),
    );
  }

  Future<void> _showWishlistDialog() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      return;
    }

    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => WishlistedProductsDialog(
          userId: userId,
          onBadgeUpdate: _updateBadgeCounts,
        ),
      ),
    );
  }

  Future<void> _launchKakaoTalk() async {
    await _launchExternal(
      Uri.parse('https://pf.kakao.com/_taxoxdG'),
    );
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _onTapKnock() async {
    try {
      final missions = await MissionService.instance.fetchList(
        isPublished: true,
        status: MissionStatus.current,
        publicity: MissionPublicity.public,
      );

      if (!mounted) return;

      await showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (ctx) {
          if (missions.isEmpty) {
            return SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  '현재 진행 중인 미션이 없습니다.',
                  style: Theme.of(ctx).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: missions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, index) => MissionAvailableListTile(
                mission: missions[index],
                onTap: (mission) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MissionDetailDialog(mission: mission),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('미션 정보를 불러오지 못했습니다. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> _handleGreenSquareDrawerSelection(
    GreenSquareDrawerDestination destination,
  ) async {
    if (!mounted) return;

    switch (destination.target) {
      case GreenSquareDrawerTarget.brandStory:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareBrandStoryScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.partnershipInquiry:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquarePartnershipInquiryScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.aboutCog:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareAboutCogScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.squareTerms:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareTermsScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.privacyPolicy:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquarePrivacyPolicyScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.notices:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareNoticesScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.faq:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareFaqScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.openInApp:
        await _launchExternal(
          Uri.parse(
            'https://apps.apple.com/kr/app/%EC%BD%94%EB%93%9C%EA%B7%B8%EB%A6%B0%EC%8A%A4%ED%80%98%EC%96%B4/id1597090322',
          ),
        );
        break;
      case GreenSquareDrawerTarget.contact:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareContactScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.kakaoContact:
        await _launchExternal(
          Uri.parse('https://pf.kakao.com/_taxoxdG'),
        );
        break;
      case GreenSquareDrawerTarget.cart:
        await _showCartBottomSheet();
        break;
      case GreenSquareDrawerTarget.myOrders:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const MyOrdersScreen(),
          ),
        );
        break;
    }
  }

  Future<void> _launchExternal(Uri uri) async {
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('링크를 열 수 없습니다. 다시 시도해주세요.'),
        ),
      );
    }
  }

  void _updateUrl(MainTab tab) {
    if (kIsWeb) {
      final path = tab == MainTab.codeGreen ? '/codegreen' : '/greensquare';
      js.context['history'].callMethod('pushState', [null, '', path]);
    }
  }

  void _updateUrlForStory(String storyId) {
    if (kIsWeb) {
      js.context['history'].callMethod('pushState', [
        null,
        '',
        '/greensquare?story=$storyId',
      ]);
    }
  }

  void _updateUrlForMission(String missionId) {
    if (kIsWeb) {
      js.context['history'].callMethod('pushState', [
        null,
        '',
        '/greensquare/missions?mission=$missionId',
      ]);
    }
  }

  void _updateUrlForGreenSquareTab(int index) {
    if (kIsWeb) {
      String path = '/greensquare';
      if (index == 1) {
        path = '/greensquare/store';
      } else if (index == 2) {
        path = '/greensquare/missions';
      } else if (index == 3) {
        path = '/greensquare/account';
      }
      js.context['history'].callMethod('pushState', [null, '', path]);
    }
  }

  void _updateUrlForCodeGreenTab(int index) {
    if (kIsWeb) {
      String path = '/codegreen';
      if (index == 1) {
        path = '/codegreen/original';
      } else if (index == 2) {
        path = '/codegreen/curation';
      } else if (index == 3) {
        path = '/codegreen/about';
      } else if (index == 4) {
        path = '/codegreen/lookbook';
      } else if (index == 6) {
        path = '/codegreen/event';
      }
      js.context['history'].callMethod('pushState', [null, '', path]);
    }
  }

  Widget _buildGreenSquareContent(int index) {
    switch (index) {
      case 0:
        return StoryTab(onTapStory: _openGreenSquareStory);
      case 1:
        return ShoppingMallTab(
          onBadgeUpdate: _updateBadgeCounts,
          productIdToOpen: _productIdToOpen,
        );
      case 2:
        return MissionParticipationTab(onMissionTap: _openMissionDetail);
      case 3:
        return const AccountTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
