import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LookbookProductMarker extends StatefulWidget {
  const LookbookProductMarker({
    super.key,
    required this.productName,
    required this.markerRadius,
    required this.markerHaloRadius,
    this.priceText,
    this.description,
    this.thumbnailUrl,
    this.onOpenProduct,
  });

  final String productName;
  final String? thumbnailUrl;
  final double markerRadius;
  final double markerHaloRadius;
  final String? priceText;
  final String? description;
  final VoidCallback? onOpenProduct;

  @override
  State<LookbookProductMarker> createState() => _LookbookProductMarkerState();
}

class _LookbookProductMarkerState extends State<LookbookProductMarker> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  Timer? _hideTimer;
  bool _isHovered = false;

  @override
  void dispose() {
    _hideTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _scheduleHideOverlay() {
    if (!kIsWeb) return;
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(milliseconds: 160), _removeOverlay);
  }

  void _showOverlay() {
    if (!kIsWeb) return;
    if (!mounted) return;
    if (_overlayEntry != null) return;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final description = (widget.description ?? '').trim();
    final priceText = (widget.priceText ?? '').trim();
    final canOpen = widget.onOpenProduct != null;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(widget.markerHaloRadius + 10, -42),
                child: MouseRegion(
                  cursor: canOpen
                      ? SystemMouseCursors.click
                      : SystemMouseCursors.basic,
                  onEnter: (_) => _cancelHideTimer(),
                  onExit: (_) => _scheduleHideOverlay(),
                  child: Material(
                    color: Colors.transparent,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 240),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: cs.outlineVariant,
                          ),
                        ),
                        child: InkWell(
                          onTap: widget.onOpenProduct,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: ClipRect(
                                    child: widget.thumbnailUrl != null
                                        ? Image.network(
                                            widget.thumbnailUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color:
                                                    cs.surfaceContainerHighest,
                                                child: Icon(
                                                  Icons
                                                      .image_not_supported_outlined,
                                                  color: cs.onSurfaceVariant,
                                                ),
                                              );
                                            },
                                          )
                                        : Container(
                                            color: cs.surfaceContainerHighest,
                                            child: Icon(
                                              Icons.inventory_2_outlined,
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.productName,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (priceText.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            priceText,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      if (description.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final canOpen = widget.onOpenProduct != null;
    final haloAlpha = _isHovered ? 120 : 90;
    final dotScale = _isHovered ? 1.15 : 1.0;

    return MouseRegion(
      cursor: canOpen ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        _cancelHideTimer();
        if (!_isHovered) setState(() => _isHovered = true);
        _showOverlay();
      },
      onExit: (_) {
        if (_isHovered) setState(() => _isHovered = false);
        _scheduleHideOverlay();
      },
      child: CompositedTransformTarget(
        link: _layerLink,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onOpenProduct,
          child: Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(haloAlpha),
                ),
                child: const SizedBox.expand(),
              ),
              AnimatedScale(
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                scale: dotScale,
                child: SizedBox(
                  width: widget.markerRadius * 2,
                  height: widget.markerRadius * 2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary,
                      border: Border.all(
                        color: cs.surface,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
