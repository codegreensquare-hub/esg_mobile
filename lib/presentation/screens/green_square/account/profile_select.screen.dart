import 'package:esg_mobile/core/enums/navigations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:esg_mobile/presentation/screens/green_square/account/profile_creation.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/top_header.widget.dart';

/// Screen where the user selects a profile (e.g. 권세연, 프로필 2, ...).
class ProfileSelectScreen extends StatefulWidget {
  const ProfileSelectScreen({super.key});

  static const route = '/greensquare/profile-select';

  @override
  State<ProfileSelectScreen> createState() => _ProfileSelectScreenState();
}

class _ProfileSelectScreenState extends State<ProfileSelectScreen> {
  List<String> _profiles = ['권세연', '프로필 2', '프로필 3'];
  int? _selectedIndex;
  bool _isDeleteMode = false;
  final Set<int> _deleteSelectedIndices = {};

  Future<void> _handleAddProfile() async {
    if (_profiles.length >= 4) return;
    final name = await context.push<String>(ProfileCreationScreen.route);
    if (name == null || name.isEmpty || !mounted) return;
    if (_profiles.length >= 4) return;
    setState(() => _profiles.add(name));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          CodeGreenTopHeader(
            initialValue: MainTab.greenSquare,
            actions: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                tooltip: '메뉴',
                onPressed: () {
                  if (context.canPop()) context.pop();
                },
              ),
            ],
          ),
          if (_profiles.isEmpty)
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
                          child: _AddProfileTile(onTap: _handleAddProfile),
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
              if (_isDeleteMode)
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _selectedIndex != null &&
                          _selectedIndex! < _profiles.length
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

  Widget _buildProfileContent() {
    final count = _profiles.length;
    Widget tile(int index) => _ProfileTile(
          name: _profiles[index],
          onTap: () {
            setState(() {
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
          isDeleteSelected: _isDeleteMode && _deleteSelectedIndices.contains(index),
        );
    Widget addTile() => _AddProfileTile(onTap: _handleAddProfile);
    // Height matches one tile (icon 72 + gap 28 + text ~24) so divider is not full container
    Widget divider() => const SizedBox(
          height: 124,
          child: VerticalDivider(width: 32, thickness: 1, color: _dividerColor),
        );

    if (count == 1) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: tile(0)),
          divider(),
          Expanded(child: addTile()),
        ],
      );
    }
    if (count == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: tile(0)),
              divider(),
              Expanded(child: tile(1)),
            ],
          ),
          addTile(),
        ],
      );
    }
    if (count == 3) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: tile(0)),
              divider(),
              Expanded(child: tile(1)),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: tile(2)),
              divider(),
              Expanded(child: addTile()),
            ],
          ),
        ],
      );
    }
    // count == 4
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: tile(0)),
            divider(),
            Expanded(child: tile(1)),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: tile(2)),
            divider(),
            Expanded(child: tile(3)),
          ],
        ),
      ],
    );
  }

  void _handleNext() {
    if (_selectedIndex == null) return;
    if (context.canPop()) context.pop();
  }

  void _toggleDeleteMode() {
    setState(() {
      _isDeleteMode = !_isDeleteMode;
      _deleteSelectedIndices.clear();
    });
  }

  void _handleDeleteConfirm() {
    if (_deleteSelectedIndices.isEmpty) return;
    final removedSet = Set<int>.from(_deleteSelectedIndices);
    final indices = _deleteSelectedIndices.toList()..sort((a, b) => b.compareTo(a));
    setState(() {
      for (final idx in indices) {
        _profiles.removeAt(idx);
      }
      _isDeleteMode = false;
      _deleteSelectedIndices.clear();
      if (_selectedIndex != null) {
        if (removedSet.contains(_selectedIndex)) {
          _selectedIndex = _profiles.isEmpty ? null : 0;
        } else {
          int decrement = 0;
          for (final idx in removedSet) {
            if (idx < _selectedIndex!) decrement++;
          }
          _selectedIndex = _selectedIndex! - decrement;
          if (_selectedIndex! >= _profiles.length) {
            _selectedIndex = _profiles.isEmpty ? null : _profiles.length - 1;
          }
        }
      }
    });
  }
}

const _dividerColor = Color(0xFFDDDDDD);

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.name,
    required this.onTap,
    this.isDeleteSelected = false,
  });

  final String name;
  final VoidCallback onTap;
  final bool isDeleteSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final color = isDeleteSelected ? Colors.red : primary;
    final textColor = isDeleteSelected ? Colors.red : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
