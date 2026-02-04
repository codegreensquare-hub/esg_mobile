import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:esg_mobile/core/constants/asset.dart';
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';

class MileageIcon extends StatelessWidget {
  const MileageIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.network(
      getImageLink(
        bucket.asset,
        asset.cMilage,
        folderPath: assetFolderPath[asset.cMilage],
      ),
      width: size,
      height: size,
      semanticsLabel: '마일리지',
    );
  }
}
