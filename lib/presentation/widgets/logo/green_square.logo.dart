import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 22, 0, 2),
      child: SvgPicture.network(
        getImageLink(
          bucket.asset,
          asset.greensquareLogo,
          folderPath: assetFolderPath[asset.greensquareLogo],
        ),
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
