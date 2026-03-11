import 'package:esg_mobile/core/constants/green_square_navigation.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/core/services/profile.service.dart';
import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/about_cog.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/brand_story.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/contact.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/esg_campaign_inquiry.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/faq.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/mission_request.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/notices.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_inquiry.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/partnership_request.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/terms.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/my_orders.screen.dart';
import 'package:flutter/material.dart';
import 'package:esg_mobile/presentation/widgets/green_square/cart/cart_bottom_sheet.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer.widget.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen where the user selects a profile (e.g. 권세연, 프로필 2, ...).
class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  static const route = '/greensquare/profile-select';

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _nameController = TextEditingController();
  List<String> _profiles = List<String>.from(ProfileService.defaultProfiles);
  int? _selectedIndex;
  bool _isDeleteMode = false;
  bool _isCreatingProfile = false;
  final Set<int> _deleteSelectedIndices = {};

  String get _mainProfileName => UserAuthService.instance.displayName;
  int get _profileCount => _profiles.length + 1;
  String get _nextProfilePlaceholder => '프로필 ${_profileCount + 1}';
  bool get _canAddProfile =>
      _profiles.length < ProfileService.maxCustomProfiles;

  @override
  void initState() {
    super.initState();
    final profileService = ProfileService.instance;
    _profiles = profileService.cachedProfiles;
    _selectedIndex = _resolveSelectedIndex(
      selectedProfileIndex: profileService.cachedSelectedProfileIndex,
      isMainProfileSelected: profileService.cachedIsMainProfileSelected,
    );
    _loadProfiles();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    final profileService = ProfileService.instance;
    await profileService.refresh();
    if (!mounted) return;

    final profiles = profileService.profiles;
    final selectedIndex = _resolveSelectedIndex(
      selectedProfileIndex: profileService.selectedProfileIndex,
      isMainProfileSelected: profileService.isMainProfileSelected,
    );
    final hasChanged =
        profiles.length != _profiles.length ||
        !_profiles.asMap().entries.every(
          (entry) => entry.value == profiles[entry.key],
        ) ||
        _selectedIndex != selectedIndex;

    if (!hasChanged) return;

    setState(() {
      _profiles = profiles;
      _selectedIndex = selectedIndex;
    });
  }

  int? _resolveSelectedIndex({
    required int? selectedProfileIndex,
    required bool isMainProfileSelected,
  }) {
    if (isMainProfileSelected) return 0;
    if (selectedProfileIndex == null) return null;
    return selectedProfileIndex + 1;
  }

  Future<void> _handleAddProfile() async {
    if (_profiles.length >= ProfileService.maxCustomProfiles) return;
    setState(() {
      _isCreatingProfile = true;
      _isDeleteMode = false;
      _deleteSelectedIndices.clear();
      _nameController.clear();
    });
  }

  Future<void> _handleCreateProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty || !mounted) return;

    final profileService = ProfileService.instance;
    try {
      await profileService.addProfile(name);
    } on ProfileServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필을 만들 수 없습니다. 다시 시도해주세요.')),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _profiles = profileService.profiles;
      _selectedIndex = _profiles.length;
      _isCreatingProfile = false;
      _nameController.clear();
    });
  }

  void _handleBackFromCreate() {
    setState(() {
      _isCreatingProfile = false;
      _nameController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      endDrawer: GreenSquareRightDrawer(
        onSelect: _handleGreenSquareDrawerSelection,
      ),
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            initialValue: MainTab.greenSquare,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: '메뉴',
                onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
          if (_isCreatingProfile)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.person_outline,
                        size: 72,
                        color: primary,
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '프로필 이름',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Noto Sans KR',
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        autofocus: true,
                        onChanged: (_) => setState(() {}),
                        onSubmitted: (_) => _handleCreateProfile(),
                        decoration: InputDecoration(
                          hintText: _nextProfilePlaceholder,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Color(0xFFDDDDDD)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(
                              color: primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (_profiles.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '프로필을 선택해 주세요.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Noto Sans KR',
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Expanded(
                        child: Center(
                          child: _buildProfileContent(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        '프로필을 선택해 주세요.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Noto Sans KR',
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildProfileContent(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!_isCreatingProfile)
                Center(
                  child: InkWell(
                    onTap: _toggleDeleteMode,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 12, 0, 72),
                      child: Text(
                        '프로필 삭제하기',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Noto Sans KR',
                          color: theme.colorScheme.onSurfaceVariant,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isCreatingProfile)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _handleBackFromCreate,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('뒤로가기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _nameController.text.trim().isNotEmpty
                            ? _handleCreateProfile
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: onPrimary,
                          disabledBackgroundColor: Colors.grey.shade400,
                          disabledForegroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('만들기'),
                      ),
                    ),
                  ],
                )
              else if (_isDeleteMode)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _toggleDeleteMode,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primary,
                          side: BorderSide(color: primary),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('뒤로가기'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _deleteSelectedIndices.isNotEmpty
                            ? _handleDeleteConfirm
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('삭제'),
                      ),
                    ),
                  ],
                )
              else
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    disabledBackgroundColor: Colors.grey.shade400,
                    disabledForegroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed:
                      _selectedIndex != null && _selectedIndex! < _profileCount
                      ? _handleNext
                      : null,
                  child: const Text('다음'),
                ),
            ],
          ),
        ),
      ),
    );
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
      case GreenSquareDrawerTarget.partnershipRequest:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquarePartnershipRequestScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.missionRequest:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareMissionRequestScreen(),
          ),
        );
        break;
      case GreenSquareDrawerTarget.esgCampaignInquiry:
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const GreenSquareEsgCampaignInquiryScreen(),
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
        await _launchExternal(Uri.parse('https://pf.kakao.com/_taxoxdG'));
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

  Future<void> _showCartBottomSheet() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
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

  Widget _buildProfileContent() {
    Widget tile(int index) => _ProfileTile(
      name: index == 0 ? _mainProfileName : _profiles[index - 1],
      onTap: () {
        setState(() {
          if (_isDeleteMode && index == 0) {
            return;
          }

          if (_isDeleteMode) {
            if (_deleteSelectedIndices.contains(index)) {
              _deleteSelectedIndices.remove(index);
            } else {
              _deleteSelectedIndices.add(index);
            }
          } else {
            _selectedIndex = index;
          }
        });
      },
      isSelected: !_isDeleteMode && _selectedIndex == index,
      isDeleteSelected:
          index != 0 && _isDeleteMode && _deleteSelectedIndices.contains(index),
    );
    Widget addTile() => _AddProfileTile(onTap: _handleAddProfile);
    // Height matches one tile (icon 72 + gap 28 + text ~24) so divider is not full container
    Widget divider() => const SizedBox(
      height: 124,
      child: VerticalDivider(width: 32, thickness: 1, color: _dividerColor),
    );

    final tileWidgets = List<Widget>.generate(
      _profileCount,
      tile,
      growable: true,
    )..addAll(_canAddProfile ? [addTile()] : const <Widget>[]);

    final rows = List<Widget>.generate((tileWidgets.length / 2).ceil(), (
      rowIndex,
    ) {
      final leftIndex = rowIndex * 2;
      final rightIndex = leftIndex + 1;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: tileWidgets[leftIndex]),
          if (rightIndex < tileWidgets.length) ...[
            divider(),
            Expanded(child: tileWidgets[rightIndex]),
          ] else
            const Expanded(child: SizedBox.shrink()),
        ],
      );
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }

  Future<void> _handleNext() async {
    final selectedIndex = _selectedIndex;
    if (selectedIndex == null) return;

    try {
      if (selectedIndex == 0) {
        await ProfileService.instance.selectMainProfile();
      } else {
        await ProfileService.instance.selectProfile(selectedIndex - 1);
      }

      if (!mounted || !Navigator.of(context).canPop()) return;
      Navigator.of(context).pop(
        selectedIndex == 0 ? _mainProfileName : _profiles[selectedIndex - 1],
      );
    } on ProfileServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필을 선택할 수 없습니다. 다시 시도해주세요.')),
      );
    }
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _deleteSelectedIndices.clear();
    });
  }

  Future<void> _handleDeleteConfirm() async {
    if (_deleteSelectedIndices.isEmpty) return;
    final selectedIndices = _deleteSelectedIndices
        .where((index) => index > 0)
        .map((index) => index - 1)
        .toSet();
    if (selectedIndices.isEmpty) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);

        return AlertDialog(
          title: const Text('프로필 삭제'),
          content: const Text('선택한 프로필을 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                '취소',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || !mounted) return;

    try {
      await ProfileService.instance.removeProfiles(selectedIndices);
      if (!mounted) return;

      setState(() {
        _profiles = ProfileService.instance.profiles;
        _selectedIndex = _resolveSelectedIndex(
          selectedProfileIndex: ProfileService.instance.selectedProfileIndex,
          isMainProfileSelected: ProfileService.instance.isMainProfileSelected,
        );
        _isDeleteMode = false;
        _deleteSelectedIndices.clear();
      });
    } on ProfileServiceException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필을 삭제할 수 없습니다. 다시 시도해주세요.')),
      );
    }
  }
}

const _dividerColor = Color(0xFFDDDDDD);

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.onTap,
    this.isSelected = false,
    this.isDeleteSelected = false,
  });

  final String name;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isDeleteSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final highlightColor = primary;
    final color = isDeleteSelected
        ? Colors.red
        : isSelected
        ? highlightColor
        : primary;
    final textColor = isDeleteSelected
        ? Colors.red
        : isSelected
        ? highlightColor
        : theme.colorScheme.onSurface;

    return Material(
      color: isSelected
          ? highlightColor.withValues(alpha: 0.08)
          : Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? highlightColor : Colors.transparent,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person_outline, size: 72, color: color),
              const SizedBox(height: 28),
              Text(
                name,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddProfileTile extends StatelessWidget {
  const _AddProfileTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 72,
                color: primary,
              ),
              const SizedBox(height: 28),
              Text(
                '새 프로필 만들기',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Noto Sans KR',
                  fontWeight: FontWeight.w500,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
