import 'package:esg_mobile/core/services/database/cart.service.dart';
import 'package:esg_mobile/core/utils/get_image_link.dart';
import 'package:esg_mobile/data/models/supabase/tables/_tables.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    super.key,
    required this.imagePath,
    required this.productName,
    this.productId,
    this.mainImageFolderPath,
    this.onTap,
  });

  final String imagePath;
  final String productName;
  final String? productId;
  final String? mainImageFolderPath;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  List<ProductOptionColorRow> _colorValues = const [];
  String? _selectedImagePath;
  String? _selectedColorHex;

  @override
  void initState() {
    super.initState();
    _loadColors();
  }

  @override
  void didUpdateWidget(covariant ProductCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId ||
        oldWidget.mainImageFolderPath != widget.mainImageFolderPath) {
      _colorValues = const [];
      _selectedImagePath = null;
      _selectedColorHex = null;
      _loadColors();
    }
  }

  Future<void> _loadColors() async {
    final pid = (widget.productId ?? '').trim();
    if (pid.isEmpty) {
      return;
    }

    final colors = await CartService.instance.fetchColorOptionValues(
      productId: pid,
    );
    if (!mounted) return;
    setState(() => _colorValues = colors);
  }

  @override
  Widget build(BuildContext context) {
    // Maintain aspect ratio: 152/244
    const double aspectRatio = 152 / 244;
    // Image takes 202/244 of the height, text takes 42/244

    final resolvedImagePath = _selectedImagePath ?? widget.imagePath;
    final isNetworkImage =
        resolvedImagePath.startsWith('http://') ||
        resolvedImagePath.startsWith('https://');

    return InkWell(
      onTap: widget.onTap,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image container: takes 202/244 of the card height
            Expanded(
              flex: 202,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: isNetworkImage
                        ? Image.network(
                            resolvedImagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          )
                        : Image.asset(
                            resolvedImagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.error),
                              );
                            },
                          ),
                  ),
                  if (_colorValues.isNotEmpty)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: true,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: _colorValues
                              .map((valueRow) {
                                final hex = (valueRow.value ?? '').trim();
                                final isSelected =
                                    _selectedColorHex?.toLowerCase() ==
                                    hex.toLowerCase();

                                final color = Color(
                                  int.parse('FF$hex', radix: 16),
                                );

                                return InkWell(
                                  onTap: () {
                                    final bucket =
                                        valueRow.coloredProductBucket;
                                    final fileName =
                                        valueRow.coloredProductFileName;
                                    final folderPath =
                                        valueRow.coloredProductFolderPath;

                                    final nextUrl =
                                        bucket != null && fileName != null
                                        ? getImageLink(
                                            bucket,
                                            fileName,
                                            folderPath: folderPath,
                                          )
                                        : null;

                                    setState(() {
                                      _selectedColorHex = hex;
                                      _selectedImagePath = nextUrl;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: color,
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.primary
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.outlineVariant,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(growable: false),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 12), // spacing between image and text
            // Text container: takes 42/244 of the card height
            Text(
              widget.productName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       AspectRatio(
  //         aspectRatio: 152 / 202,
  //         child: Image.asset(imagePath, fit: BoxFit.cover),
  //       ),

  //       SizedBox(height: 6), // you control the spacing

  //       Text(
  //         productName,
  //         textAlign: TextAlign.center,
  //         style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //           height: 1.0, // removes extra text padding
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
