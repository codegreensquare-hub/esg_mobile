import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/core/enums/mission_status.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/services/database/mission.row.service.dart';
import 'package:esg_mobile/presentation/screens/code_green/about.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/curation_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/event.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/home.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/look_book.tab.dart';
import 'package:esg_mobile/presentation/screens/code_green/original_shop.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/account.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/mission_participation.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/shopping_mall.tab.dart';
import 'package:esg_mobile/presentation/screens/green_square/story/story.tab.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_available.list_tile.dart';
import 'package:esg_mobile/presentation/widgets/mission/mission_detail.dialog.dart';
import 'package:esg_mobile/presentation/widgets/layout/footer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/left_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/nav_header.delegate.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/core/constants/navigation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:esg_mobile/data/models/supabase/database.dart';

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

  static const double _topHeaderHeight =
      72; // header height excluding status bar
  static const double _toolbarHeight = 72; // floating bar height

  @override
  void initState() {
    super.initState();
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

    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
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
      ),
      floatingActionButton: isGreenSquare
          ? FloatingActionButton(
              heroTag: 'green-square-knock-fab',
              onPressed: _onTapKnock,
              tooltip: 'Knock',
              child: const Icon(Icons.campaign_outlined),
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
        // physics: ClampingScrollPhysics(),
        slivers: [
          CodeGreenTopHeader(
            initialValue: _selectedMainTab,
            onChanged: (tab) => setState(() => _selectedMainTab = tab),
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
                onTapCart: _showCartBottomSheet,
              ),
            ),
          if (_selectedMainTab == MainTab.greenSquare)
            SliverToBoxAdapter(
              child: Container(
                constraints: const BoxConstraints(minHeight: 600),
                width: double.infinity,
                color: theme.colorScheme.surface,
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
        return const HomeTab(key: PageStorageKey(HomeTab.tab));
      case OriginalShopTab.tab:
        return const OriginalShopTab(key: PageStorageKey(OriginalShopTab.tab));
      case CurationShopTab.tab:
        return const CurationShopTab(key: PageStorageKey(CurationShopTab.tab));
      case AboutTab.tab:
        return const AboutTab(key: PageStorageKey(AboutTab.tab));
      case LookBookTab.tab:
        return const LookBookTab(key: PageStorageKey(LookBookTab.tab));
      case EventTab.tab:
        return const EventTab(key: PageStorageKey(EventTab.tab));
      default:
        return const SizedBox.shrink();
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
