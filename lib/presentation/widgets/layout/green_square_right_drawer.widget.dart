import 'package:esg_mobile/core/constants/green_square_navigation.dart';
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
                itemCount: greenSquareDrawerDestinations.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final destination = greenSquareDrawerDestinations[index];
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
