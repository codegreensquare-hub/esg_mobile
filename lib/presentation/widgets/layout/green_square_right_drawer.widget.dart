import 'package:esg_mobile/core/constants/green_square_navigation.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:flutter/material.dart';

class GreenSquareRightDrawer extends StatelessWidget {
  const GreenSquareRightDrawer({
    super.key,
    required this.onSelect,
  });

  final Future<void> Function(GreenSquareDrawerDestination destination)
  onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const drawerTextColor = Color(0xFF3B3733);
    const horizontalPadding = 24.0;
    const separatorColor = Color(0xFF000000);
    const separatorVerticalPadding = 6.0;

    final destinations = greenSquareDrawerDestinations;
    final postLogoutDestinations = greenSquareDrawerPostLogoutDestinations;
    final isLoggedIn = UserAuthService.instance.isLoggedIn;

    ListTile buildTile({
      required String label,
      required VoidCallback onTap,
    }) {
      return ListTile(
        dense: true,
        minVerticalPadding: 4,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: horizontalPadding,
        ),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: drawerTextColor,
          ),
        ),
        onTap: onTap,
      );
    }

    return Drawer(
      elevation: 16,
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(
                  Icons.close,
                  color: cs.onSurfaceVariant,
                ),
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  for (final destination in destinations)
                    buildTile(
                      label: destination.label,
                      onTap: () async {
                        await Navigator.of(context).maybePop();
                        await onSelect(destination);
                      },
                    ),
                  if (isLoggedIn) ...[
                    buildTile(
                      label: '로그아웃',
                      onTap: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);
                        await UserAuthService.instance.signOut();
                        if (!context.mounted) return;
                        navigator.pop();
                        messenger.showSnackBar(
                          const SnackBar(content: Text('로그아웃되었습니다.')),
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: separatorVerticalPadding,
                      ),
                      child: Divider(
                        height: 1,
                        thickness: 1,
                        color: separatorColor,
                        indent: horizontalPadding,
                        endIndent: horizontalPadding,
                      ),
                    ),
                  ],
                  for (final destination in postLogoutDestinations)
                    buildTile(
                      label: destination.label,
                      onTap: () async {
                        await Navigator.of(context).maybePop();
                        await onSelect(destination);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
