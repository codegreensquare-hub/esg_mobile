import 'package:flutter/material.dart';

class LookbookGridItem extends StatelessWidget {
  const LookbookGridItem({
    required this.id,
    required this.title,
    required this.coverUrl,
    this.onTap,
    super.key,
  });

  final String id;
  final String title;
  final String? coverUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      child: KeyedSubtree(
        key: ValueKey(id),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: ClipRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (coverUrl != null)
                    RepaintBoundary(
                      child: Image.network(
                        coverUrl!,
                        fit: BoxFit.cover,
                        excludeFromSemantics: true,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 32,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.menu_book_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 32,
                      ),
                    ),
                  Positioned.fill(
                    child: Container(
                      color: theme.colorScheme.scrim.withAlpha(90),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
