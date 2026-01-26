import 'package:esg_mobile/core/constants/asset.dart' as asset_constants;
import 'package:esg_mobile/core/constants/bucket.dart';
import 'package:esg_mobile/core/constants/frame_width.dart';
import 'package:esg_mobile/core/services/database/product.service.dart';
import 'package:esg_mobile/core/theme/util.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/entities/product_with_other_details.dart';
import 'package:esg_mobile/data/entities/story_with_tags.dart';
import 'package:esg_mobile/data/models/supabase/enums/_enums.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/codegreen_banner_carousel.widget.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/codegreen_material_section.widget.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/codegreen_meet_section.widget.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/home_new_in_products.widget.dart';
import 'package:esg_mobile/presentation/screens/code_green/widgets/home_stories_section.widget.dart';
import 'package:flutter/material.dart';

class HomeTab extends StatefulWidget {
  static const tab = 'home';
  const HomeTab({
    this.onTapNatureMaterial,
    this.onTapVeganMaterial,
    this.onTapBiodegradableMaterial,
    this.onTapGreenSquare,
    this.onTapProduct,
    this.onTapStory, // Updated to use StoryWithTags
    super.key,
  });

  final VoidCallback? onTapNatureMaterial;
  final VoidCallback? onTapVeganMaterial;
  final VoidCallback? onTapBiodegradableMaterial;
  final VoidCallback? onTapGreenSquare;
  final ValueChanged<ProductWithOtherDetails>? onTapProduct;
  final void Function(StoryWithTags story)?
  onTapStory; // Changed type to StoryWithTags

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const int _homeGridLimit = 4;

  List<ProductWithOtherDetails> _products = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await ProductService.instance.fetchProducts(
        vendor: VendorAdminType.lgs,
        company: '00000000-0000-0000-0000-000000000000',
        limit: _homeGridLimit,
      );

      if (!mounted) return;
      setState(() {
        _products = results;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      debugPrint('Error fetching home products: $error\n$stackTrace');
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load products.';
        _isLoading = false;
      });
    }
  }

  String _resolveProductTitle(ProductWithOtherDetails item) {
    return item.product.title ?? item.product.name ?? '';
  }

  String _resolveProductImagePath(ProductWithOtherDetails item) {
    final mainImageBucket = item.product.mainImageBucket;
    final fileName = item.product.mainImageFileName;

    if (mainImageBucket != null &&
        mainImageBucket.isNotEmpty &&
        fileName != null &&
        fileName.isNotEmpty) {
      return getImageLink(
        mainImageBucket,
        fileName,
        folderPath: item.product.mainImageFolderPath,
      );
    }

    final fallbackImages = item.images
        .where(
          (img) =>
              (img.bucket?.isNotEmpty ?? false) &&
              (img.fileName?.isNotEmpty ?? false),
        )
        .toList();

    final firstImage = fallbackImages.isNotEmpty ? fallbackImages.first : null;
    if (firstImage?.bucket != null && firstImage?.fileName != null) {
      return getImageLink(
        firstImage!.bucket!,
        firstImage.fileName!,
        folderPath: firstImage.folderPath,
      );
    }

    return getImageLink(
      bucket.asset,
      asset_constants.asset.product1,
      folderPath:
          asset_constants.assetFolderPath[asset_constants.asset.product1],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.zero,
      width: double.infinity,
      child: Column(
        children: [
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: frameWidth),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SizedBox(height: 32),

                  Text(
                    'New In',
                    textAlign: TextAlign.center,
                    style: createTextTheme(context).headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 16),
                  HomeNewInProducts(
                    isLoading: _isLoading,
                    error: _error,
                    products: _products,
                    resolveImagePath: _resolveProductImagePath,
                    resolveTitle: _resolveProductTitle,
                    onTapProduct: widget.onTapProduct,
                  ),
                ],
              ),
            ),
          ),
          // Codegreen Material section
          const SizedBox(height: 80),
          CodegreenMaterialSection(
            onTapNature: widget.onTapNatureMaterial,
            onTapVegan: widget.onTapVeganMaterial,
            onTapBiodegradable: widget.onTapBiodegradableMaterial,
          ),
          const SizedBox(height: 80),
          CodegreenBannerCarousel(
            imagePaths: [
              getImageLink(
                bucket.asset,
                asset_constants.asset.banner1Window,
                folderPath: asset_constants
                    .assetFolderPath[asset_constants.asset.banner1Window],
              ),
              getImageLink(
                bucket.asset,
                asset_constants.asset.banner2Window,
                folderPath: asset_constants
                    .assetFolderPath[asset_constants.asset.banner2Window],
              ),
              getImageLink(
                bucket.asset,
                asset_constants.asset.banner3Window,
                folderPath: asset_constants
                    .assetFolderPath[asset_constants.asset.banner3Window],
              ),
            ],
          ),
          const SizedBox(height: 80),
          CodegreenMeetSection(
            onTapVisit: widget.onTapGreenSquare,
          ),
          const SizedBox(height: 80),
          HomeStoriesSection(
            onTapStory: widget.onTapStory, // Pass callback directly
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
