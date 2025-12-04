import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GreenSquareLogo extends StatelessWidget {
  const GreenSquareLogo({
    super.key,
    this.height = 22,
    this.width,
    this.color,
  });

  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 2),
      child: SvgPicture.asset(
        'assets/images/logos/greensquare_logo.svg',
        height: height,
        width: width,
        colorFilter: color != null
            ? ColorFilter.mode(
                color!,
                BlendMode.srcIn,
              )
            : null,
      ),
    );
  }
}
