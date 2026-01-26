import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CodeGreenLogo extends StatelessWidget {
  const CodeGreenLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: SvgPicture.network(
        getImageLink(
          bucket.asset,
          asset.codegreenLogo,
          folderPath: assetFolderPath[asset.codegreenLogo],
        ),
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
