import 'package:esg_mobile/core/constants/green_square_navigation.dart';
import 'package:esg_mobile/core/services/auth/user_auth.service.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/privacy_policy.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/settings.screen.dart';
import 'package:esg_mobile/presentation/screens/green_square/info/terms.screen.dart';
import 'package:esg_mobile/presentation/widgets/layout/green_square_right_drawer_tile.widget.dart';
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
    const bottomTextColor = Color(0xFF878583);
    const horizontalPadding = 24.0;
    const separatorColor = Color(0xFF000000);
    const separatorVerticalPadding = 6.0;

    final isLoggedIn = UserAuthService.instance.isLoggedIn;

    return Drawer(
      elevation: 16,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  GreenSquareRightDrawerTile(
                    label: "서비스 스토리",
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[0]);
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: "콕(Cog)에 관하여",
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[1]);
                    },
                  ),
                  // GreenSquareRightDrawerTile(
                  //   label: greenSquareDrawerDestinations[2].label,
                  //   onTap: () async {
                  //     await Navigator.of(context).maybePop();
                  //     await onSelect(greenSquareDrawerDestinations[2]);
                  //   },
                  // ),
                  // GreenSquareRightDrawerTile(
                  //   label: greenSquareDrawerDestinations[3].label,
                  //   onTap: () async {
                  //     await Navigator.of(context).maybePop();
                  //     await onSelect(greenSquareDrawerDestinations[3]);
                  //   },
                  // ),
                  GreenSquareRightDrawerTile(
                    label: "공지사항",
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[4]);
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerDestinations[5].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[5]);
                    },
                  ),
                  // GreenSquareRightDrawerTile(
                  //   label: greenSquareDrawerDestinations[6].label,
                  //   onTap: () async {
                  //     await Navigator.of(context).maybePop();
                  //     await onSelect(greenSquareDrawerDestinations[6]);
                  //   },
                  // ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerDestinations[7].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[7]);
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerDestinations[8].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(greenSquareDrawerDestinations[8]);
                    },
                  ),
                  // GreenSquareRightDrawerTile(
                  //   label: greenSquareDrawerDestinations[9].label,
                  //   onTap: () async {
                  //     await Navigator.of(context).maybePop();
                  //     await onSelect(greenSquareDrawerDestinations[9]);
                  //   },
                  // ),
                  // GreenSquareRightDrawerTile(
                  //   label: greenSquareDrawerDestinations[10].label,
                  //   onTap: () async {
                  //     await Navigator.of(context).maybePop();
                  //     await onSelect(greenSquareDrawerDestinations[10]);
                  //   },
                  // ),
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
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerPostLogoutDestinations[0].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(
                        greenSquareDrawerPostLogoutDestinations[0],
                      );
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerPostLogoutDestinations[1].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(
                        greenSquareDrawerPostLogoutDestinations[1],
                      );
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerPostLogoutDestinations[2].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(
                        greenSquareDrawerPostLogoutDestinations[2],
                      );
                    },
                  ),
                  GreenSquareRightDrawerTile(
                    label: greenSquareDrawerPostLogoutDestinations[3].label,
                    onTap: () async {
                      await Navigator.of(context).maybePop();
                      await onSelect(
                        greenSquareDrawerPostLogoutDestinations[3],
                      );
                    },
                  ),
                ],
              ),
            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).maybePop();
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GreenSquareTermsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          '스퀘어 이용 약관',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: bottomTextColor,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          '|',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: bottomTextColor,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.of(context).maybePop();
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  const GreenSquarePrivacyPolicyScreen(),
                            ),
                          );
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () async {
                          await Navigator.of(context).maybePop();
                          if (!context.mounted) return;
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const GreenSquareSettingsScreen(),
                            ),
                          );
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
                      if (isLoggedIn)
                        GestureDetector(
                          onTap: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final navigator = Navigator.of(context);
                            try {
                              await UserAuthService.instance.signOut();
                              if (!context.mounted) return;
                              navigator.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('로그아웃되었습니다.'),
                                ),
                              );
                            } catch (_) {
                              if (!context.mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    '로그아웃에 실패했습니다. 다시 시도해주세요.',
                                  ),
                                ),
                              );
                            }
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
                                style: theme.textTheme.bodyMedium?.copyWith(
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
    );
  }
}
