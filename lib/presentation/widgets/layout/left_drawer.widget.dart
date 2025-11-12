import 'package:flutter/material.dart';
import 'package:esg_mobile/core/constants/navigation.dart';

class CodeGreenLeftDrawer extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final Map<String, String> labels;
  final ValueChanged<int>? onSelect;
  final String? homeTab;

  const CodeGreenLeftDrawer({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.labels,
    this.onSelect,
    this.homeTab,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DrawerHeader(
              cs: cs,
              theme: theme,
              onTapHome: () {
                if (homeTab == null) return;
                final idx = tabs.indexOf(homeTab!);
                if (idx >= 0) {
                  Navigator.of(context).pop();
                  if (idx != selectedIndex) {
                    onSelect?.call(idx);
                  }
                }
              },
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                children: [
                  for (int index = 0; index < tabs.length; index++) ...[
                    if (!(homeTab != null && tabs[index] == homeTab))
                      _buildParentTile(
                        context: context,
                        theme: theme,
                        cs: cs,
                        id: tabs[index],
                        index: index,
                        selected: index == selectedIndex,
                        label: labels[tabs[index]] ?? tabs[index],
                      ),
                    if (codeGreenSubTabs.containsKey(tabs[index]))
                      ..._buildSubTabs(
                        context: context,
                        theme: theme,
                        cs: cs,
                        parentIndex: index,
                        subs: (codeGreenSubTabs[tabs[index]] as List)
                            .cast<String>(),
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

  Widget _buildParentTile({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme cs,
    required String id,
    required int index,
    required bool selected,
    required String label,
  }) {
    return ListTile(
      selected: selected,
      selectedColor: cs.onPrimaryContainer,
      selectedTileColor: cs.primaryContainer,
      leading: selected
          ? Icon(Icons.check, color: cs.primary)
          : const SizedBox(),
      title: Text(label, style: theme.textTheme.titleMedium),
      onTap: () {
        Navigator.of(context).pop();
        onSelect?.call(index);
      },
    );
  }

  List<Widget> _buildSubTabs({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme cs,
    required int parentIndex,
    required List<String> subs,
  }) {
    return [
      for (final sub in subs)
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: ListTile(
            dense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const SizedBox(width: 24),
            title: Text(_toTitleCase(sub), style: theme.textTheme.bodyMedium),
            onTap: () {
              Navigator.of(context).pop();
              onSelect?.call(parentIndex);
            },
          ),
        ),
    ];
  }
}

class _DrawerHeader extends StatelessWidget {
  final ColorScheme cs;
  final ThemeData theme;
  final VoidCallback? onTapHome;
  const _DrawerHeader({required this.cs, required this.theme, this.onTapHome});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cs.surfaceContainer,
      child: InkWell(
        onTap: onTapHome,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: cs.primary,
                child: Icon(Icons.eco, color: cs.onPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Code Green',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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
