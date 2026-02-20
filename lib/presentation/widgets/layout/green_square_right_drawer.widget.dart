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

    final destinations = greenSquareDrawerDestinations;

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
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: UserAuthService.instance.isLoggedIn
                    ? destinations.length + 1
                    : destinations.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final showLogout =
                      UserAuthService.instance.isLoggedIn &&
                      index == destinations.length;
                  if (showLogout) {
                    return ListTile(
                      title: Align(
                        alignment: Alignment.centerRight,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.logout,
                              color: cs.onSurfaceVariant,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '로그아웃',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                    );
                  }
                  final destination = destinations[index];
                  final isExternal =
                      destination.target == GreenSquareDrawerTarget.openInApp ||
                      destination.target ==
                          GreenSquareDrawerTarget.kakaoContact;
                  final Color iconColor = isExternal
                      ? cs.primary
                      : cs.onSurfaceVariant;
                  final Color textColor = isExternal
                      ? cs.primary
                      : cs.onSurface;
                  return ListTile(
                    leading: Icon(
                      destination.icon,
                      color: iconColor,
                    ),
                    title: Text(
                      destination.label,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: textColor,
                      ),
                    ),
                    trailing: isExternal
                        ? Icon(
                            Icons.open_in_new,
                            size: 18,
                            color: iconColor,
                          )
                        : null,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(destination);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
