import 'package:flutter/material.dart';

class MaterialCard extends StatelessWidget {
  final String imagePath;
  final String koreanTitle;
  final String englishTitle;
  final String buttonText;
  final VoidCallback? onButtonPressed;

  const MaterialCard({
    super.key,
    required this.imagePath,
    required this.koreanTitle,
    required this.englishTitle,
    required this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AspectRatio(
      aspectRatio: 300 / 163,
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Content overlay
            Positioned(
              left: 16,
              right: 16,
              top: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Korean title
                  Text(
                    koreanTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // English title
                  Text(
                    englishTitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 22,
                      fontFamily: 'EB Garamond',
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onButtonPressed ?? () {},
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.grey.withValues(alpha: 0.6),
                          Colors.grey.withValues(alpha: 0.7),
                          Colors.grey.withValues(alpha: 0.6),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      buttonText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
