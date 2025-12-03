import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CodeGreenLogo extends StatelessWidget {
  const CodeGreenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: SvgPicture.asset(
        'assets/images/logos/codegreen_logo.svg',
        width: 168,
        height: 50,
        colorFilter: ColorFilter.mode(
          theme.colorScheme.onSurface,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
