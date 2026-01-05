import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/login/code_green_login.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/product_detail.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/account.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/mission_participation.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/shopping_mall.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/story/story.tab.dart';
import 'package:esg_mobile/presentation/widgets/green_square/story_dialog.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/code_green/code_green_hero_banner.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_detail.dialog.dart';
import 'package:esg_mobile/presentation/widgets/layout/footer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/left_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/nav_header.delegate.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
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

class MainScreen extends StatefulWidget {
  static const String route = '/';
  final ScrollController? controller;

  const MainScreen({super.key, this.controller});

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
  late final CodeGreenProductDetailTabController _productDetailController;
  int _codeGreenLastNonProductTabIndex = 0;

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
    _curationShopController = CurationShopTabController();
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _curationShopController.dispose();
    _productDetailController.dispose();
    super.dispose();
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
      drawer: CodeGreenLeftDrawer(
        tabs: codeGreenTabs,
        selectedIndex: _selectedIndex,
        labels: codeGreenLabels,
        homeTab: HomeTab.tab,
        onSelect: (index) {
          if (index != _selectedIndex) {
            setState(() => _selectedIndex = index);
          }
        },
        onTapGreenSquare: () {
          setState(() => _selectedMainTab = MainTab.greenSquare);
        },
        onTapLogin: _openCodeGreenLogin,
        onSelectSubTab: _handleCodeGreenSubTab,
      ),
      endDrawer: isGreenSquare
          ? GreenSquareRightDrawer(
              onSelect: _handleGreenSquareDrawerSelection,
            )
          : null,
      floatingActionButton: isGreenSquare
          ? FloatingActionButton(
              heroTag: 'green-square-knock-fab',
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32),
              ),
              onPressed: _onTapKnock,
              tooltip: 'Knock',
              child: const Text(
                "콕!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: isGreenSquare
          ? FloatingActionButtonLocation.centerDocked
          : null,
      bottomNavigationBar: isGreenSquare
          ? BottomAppBar(
              shape: const CircularNotchedRectangle(),
              notchMargin: 6,
              child: SizedBox(
                height: 64,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildGsItem(
                      context,
                      index: 0,
                      icon: Icons.auto_stories_outlined,
                      label: '스토리',
                    ),
                    _buildGsItem(
                      context,
                      index: 1,
                      icon: Icons.storefront_outlined,
                      label: '쇼핑몰',
                    ),
                    const SizedBox(width: 56), // space for FAB notch
                    _buildGsItem(
                      context,
                      index: 2,
                      icon: Icons.group_outlined,
                      label: '미션 참여',
                    ),
                    _buildGsItem(
                      context,
                      index: 3,
                      icon: Icons.person_outline,
                      label: '나의 콕',
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: CustomScrollView(
        controller: _scrollController,

        physics: ClampingScrollPhysics(),
        slivers: [
          CodeGreenTopHeader(
            initialValue: _selectedMainTab,
            onChanged: (tab) => setState(() => _selectedMainTab = tab),
            actions: [
              if (_selectedMainTab == MainTab.greenSquare)
                IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.white,
                  ),
                  tooltip: '그린스퀘어 메뉴',
                  onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
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
                  }
                },
                onTapMenu: () => _scaffoldKey.currentState?.openDrawer(),
                onTapLogin: _openCodeGreenLogin,
                onTapCart: _showCartBottomSheet,
                onSelectSubTab: _handleCodeGreenSubTab,
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
                  constraints: const BoxConstraints(minHeight: 600),
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
        return const OriginalShopTab(key: PageStorageKey(OriginalShopTab.tab));
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
        return const AboutTab(key: PageStorageKey(AboutTab.tab));
      case LookBookTab.tab:
        return const LookBookTab(key: PageStorageKey(LookBookTab.tab));
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

  void _openGreenSquare() {
    setState(() {
      _selectedMainTab = MainTab.greenSquare;
      _selectedIndex = 0;
    });
  }

  void _openGreenSquareStory(StoryWithTags storyWithTags) {
    setState(() {
      _selectedMainTab = MainTab.greenSquare;
      _selectedIndex = 0;
      _greenIndex = 0; // ensure Green Square "스토리" tab
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => StoryDialog(
            story: storyWithTags.story,
            tags: storyWithTags.tags,
          ),
        ),
      );
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
    if (parentTab == CurationShopTab.tab) {
      _curationShopController.selectById(subTab);
      final idx = codeGreenTabs.indexOf(parentTab);
      if (idx >= 0 && idx != _selectedIndex) {
        setState(() => _selectedIndex = idx);
      }
    }
  }

  Widget _buildGsItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
  }) {
    final cs = Theme.of(context).colorScheme;
    final bool selected = _greenIndex == index;
    final Color color = selected ? cs.primary : cs.onSurfaceVariant;
    return InkWell(
      customBorder: const StadiumBorder(),
      onTap: () => setState(() => _greenIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
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
      builder: (_) => CartBottomSheet(items: items),
    );
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
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) => MissionAvailableListTile(
                mission: missions[index],
                onTap: (mission) {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MissionDetailDialog(mission: mission),
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

  Widget _buildGreenSquareContent(int index) {
    switch (index) {
      case 0:
        return const StoryTab(); // Story placeholder for now
      case 1:
        return const ShoppingMallTab();
      case 2:
        return MissionParticipationTab();
      case 3:
        return const AccountTab();
      default:
        return const SizedBox.shrink();
    }
  }
}
