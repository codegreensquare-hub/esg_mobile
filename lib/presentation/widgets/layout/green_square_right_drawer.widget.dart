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
    const bottomTextColor = Color(0xFF878583);
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

                  // Bottom section — scrolls with the list
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      horizontalPadding,
                      24,
                      horizontalPadding,
                      20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Terms row — centered
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to terms
                              },
                              child: Text(
                                '스퀘어 이용 약관',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: bottomTextColor,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                '|',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: bottomTextColor,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to privacy policy
                              },
                              child: Text(
                                '개인정보 처리 방침',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: bottomTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Settings and Logout row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Settings
                            GestureDetector(
                              onTap: () {
                                // TODO: navigate to settings
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings_outlined,
                                    size: 18,
                                    color: bottomTextColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '설정',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: bottomTextColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Logout
                            if (isLoggedIn)
                              GestureDetector(
                                onTap: () async {
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  final navigator = Navigator.of(context);
                                  await UserAuthService.instance.signOut();
                                  if (!context.mounted) return;
                                  navigator.pop();
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('로그아웃되었습니다.'),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      size: 18,
                                      color: bottomTextColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '로그아웃',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: bottomTextColor,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
