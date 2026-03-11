import 'package:esg_mobile/core/constants/navigation.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/presentation/widgets/logo/code_green.logo.dart';
import 'package:esg_mobile/presentation/widgets/logo/green_square.logo.dart';
import 'package:flutter/material.dart';

class CodeGreenLeftDrawer extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Map<String, String> labels;
  final ValueChanged<int>? onSelect;
  final String? homeTab;
  final VoidCallback? onTapGreenSquare;
  final VoidCallback? onTapLogin;
  final void Function(String tab, String subTab)? onSelectSubTab;

  const CodeGreenLeftDrawer({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.labels,
    this.onSelect,
    this.homeTab,
    this.onTapGreenSquare,
    this.onTapLogin,
    this.onSelectSubTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final authService = UserAuthService.instance;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              InkWell(
                onTap: () {
                  if (homeTab == null) return;
                  final idx = tabs.indexOf(homeTab!);
                  if (idx >= 0) {
                    Navigator.of(context).pop();
                    if (idx != selectedIndex) {
                      onSelect?.call(idx);
                    }
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  color: cs.surfaceContainer,
                  child: SafeArea(bottom: false, child: CodeGreenLogo()),
                ),
              ),
              const Divider(height: 1),
            ],
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(0, 16, 0, 16),
              children: [
                AnimatedBuilder(
                  animation: authService,
                  builder: (context, _) {
                    if (authService.isLoggedIn) {
                      return ListTile(
                        onTap: () {
                          Navigator.of(context).pop();
                          // TODO: navigate to profile when available
                        },
                        title: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '${authService.displayName} 님',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(
                                text: ', 안녕하세요.',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                      );
                    }
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).pop();
                        onTapLogin?.call();
                      },
                      title: Text(
                        '로그인',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  },
                ),

                ...tabs
                    .asMap()
                    .entries
                    .where(
                      (e) =>
                          !(homeTab != null && e.value == homeTab) &&
                          e.value != lookbookEntryViewerTabId &&
                          e.value != codeGreenProductTabId &&
                          e.value != codeGreenLoginTabId,
                    )
                    .map<Widget>((e) {
                      final index = e.key;
                      final id = e.value;
                      final isSelected = index == selectedIndex;
                      final subTabs =
                          (codeGreenSubTabs[id] as List?)?.cast<String>() ??
                          const [];

                      // If no sub-tabs, render a simple ListTile.
                      if (subTabs.isEmpty) {
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: cs.surfaceContainer,
                          title: Text(
                            labels[id] ?? id,
                            style: theme.textTheme.titleMedium,
                          ),
                          onTap: () {
                            Navigator.of(context).pop();
                            onSelect?.call(index);
                          },
                        );
                      }

                      // With sub-tabs: render an ExpansionTile (dropdown)
                      return Theme(
                        data: theme.copyWith(
                          dividerColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: ExpansionTile(
                          initiallyExpanded: isSelected,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          childrenPadding: const EdgeInsets.only(left: 24),
                          collapsedBackgroundColor: isSelected
                              ? cs.surfaceContainer
                              : null,
                          backgroundColor: isSelected
                              ? cs.surfaceContainer
                              : null,
                          title: Text(
                            labels[id] ?? id,
                            style: theme.textTheme.titleMedium,
                          ),
                          onExpansionChanged: (_) {},
                          children: subTabs
                              .map(
                                (sub) => ListTile(
                                  dense: true,
                                  title: Text(
                                    _toTitleCase(sub),
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    onSelect?.call(index);
                                    onSelectSubTab?.call(id, sub);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }),

                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onTapGreenSquare?.call();
                  },
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                      child: GreenSquareLogo(),
                    ),
                  ),
                ),

                AnimatedBuilder(
                  animation: authService,
                  builder: (context, _) {
                    if (!authService.isLoggedIn) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await authService.signOut();
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('로그아웃되었습니다.')),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          'Log out',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _toTitleCase(String id) {
  if (id.isEmpty) return id;
  final parts = id.split('_').where((p) => p.isNotEmpty);
  return parts
      .map((p) => p[0].toUpperCase() + (p.length > 1 ? p.substring(1) : ''))
      .join(' ');
}
