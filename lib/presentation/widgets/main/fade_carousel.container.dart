import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// A reusable container that cycles through background images with a fade
/// animation while displaying a foreground [child]. Images are pre‑cached
/// to minimize flicker.
///
/// Provide a list of [ImageProvider]s via [images]. You may use the factory
/// helpers [FadeCarouselContainer.assets] or [FadeCarouselContainer.network] for
/// convenience.
class FadeCarouselContainer extends StatefulWidget {
  const FadeCarouselContainer({
    super.key,
    required this.images,
    this.child,
    this.switchInterval = const Duration(seconds: 6),
    this.fadeDuration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    this.onIndexChanged,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.overlayColor,
    // Container passthrough parameters
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.clipBehavior = Clip.none,
    this.transform,
    this.transformAlignment,
    this.containerAlignment,
  });

  /// Convenience factory for asset images.
  factory FadeCarouselContainer.assets(
    List<String> assetPaths, {
    Key? key,
    Widget? child,
    Duration switchInterval = const Duration(seconds: 6),
    Duration fadeDuration = const Duration(milliseconds: 900),
    Curve curve = Curves.easeInOut,
    void Function(int index)? onIndexChanged,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    Color? overlayColor,
    // Container passthrough
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    Clip clipBehavior = Clip.none,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    AlignmentGeometry? containerAlignment,
  }) => FadeCarouselContainer(
    key: key,
    images: assetPaths.map((p) => AssetImage(p) as ImageProvider).toList(),
    switchInterval: switchInterval,
    fadeDuration: fadeDuration,
    curve: curve,
    onIndexChanged: onIndexChanged,
    fit: fit,
    alignment: alignment,
    overlayColor: overlayColor,
    width: width,
    height: height,
    constraints: constraints,
    margin: margin,
    padding: padding,
    color: color,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    clipBehavior: clipBehavior,
    transform: transform,
    transformAlignment: transformAlignment,
    containerAlignment: containerAlignment,
    child: child,
  );

  /// Convenience factory for network images with caching.
  factory FadeCarouselContainer.network(
    List<String> urls, {
    Key? key,
    Widget? child,
    Duration switchInterval = const Duration(seconds: 6),
    Duration fadeDuration = const Duration(milliseconds: 900),
    Curve curve = Curves.easeInOut,
    void Function(int index)? onIndexChanged,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    Color? overlayColor,
    // Container passthrough
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    Clip clipBehavior = Clip.none,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    AlignmentGeometry? containerAlignment,
  }) => FadeCarouselContainer(
    key: key,
    images: urls
        .map((u) => CachedNetworkImageProvider(u) as ImageProvider)
        .toList(),
    switchInterval: switchInterval,
    fadeDuration: fadeDuration,
    curve: curve,
    onIndexChanged: onIndexChanged,
    fit: fit,
    alignment: alignment,
    overlayColor: overlayColor,
    width: width,
    height: height,
    constraints: constraints,
    margin: margin,
    padding: padding,
    color: color,
    decoration: decoration,
    foregroundDecoration: foregroundDecoration,
    clipBehavior: clipBehavior,
    transform: transform,
    transformAlignment: transformAlignment,
    containerAlignment: containerAlignment,
    child: child,
  );

  /// Background images that will be faded through.
  final List<ImageProvider> images;
  final Widget? child;
  final Duration switchInterval;
  final Duration fadeDuration;
  final Curve curve;
  final void Function(int index)? onIndexChanged;
  final BoxFit fit;
  final Alignment alignment;
  final Color? overlayColor; // optional color filter / tint mask
  // Container parameters
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Decoration? decoration;
  final Decoration? foregroundDecoration;
  final Clip clipBehavior;
  final Matrix4? transform;
  final AlignmentGeometry? transformAlignment;
  final AlignmentGeometry? containerAlignment;

  @override
  State<FadeCarouselContainer> createState() => _FadeCarouselContainerState();
}

class _FadeCarouselContainerState extends State<FadeCarouselContainer>
    with SingleTickerProviderStateMixin {
  late int _index;
  Timer? _timer; // becomes active only when we actually need rotation
  // Keep previous image to cross-fade smoothly.
  ImageProvider? _prevImage;
  ImageProvider? _currentImage;
  bool _fading = false;
  bool _precached = false;

  @override
  void initState() {
    super.initState();
    _index = 0;
    _currentImage = widget.images.isNotEmpty ? widget.images[_index] : null;
    if (widget.images.length > 1) {
      _startTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_precached) {
      _precacheAll();
      _precached = true;
    }
  }

  void _startTimer() {
    // Avoid creating multiple timers; cancel any stale one first.
    _timer?.cancel();
    _timer = Timer.periodic(widget.switchInterval, (_) => _next());
  }

  Future<void> _precacheAll() async {
    for (final img in widget.images) {
      // ignore: use_build_context_synchronously
      precacheImage(img, context);
    }
  }

  void _next() {
    if (!mounted) return;
    setState(() {
      _prevImage = _currentImage;
      _index = (_index + 1) % widget.images.length;
      _currentImage = widget.images[_index];
      _fading = true;
    });
    widget.onIndexChanged?.call(_index);
    // End fade flag after animation completes to stop layering cost.
    Future.delayed(widget.fadeDuration, () {
      if (!mounted) return;
      setState(() => _fading = false);
    });
  }

  @override
  void didUpdateWidget(covariant FadeCarouselContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    final imagesChanged = oldWidget.images != widget.images;
    if (imagesChanged) {
      // Reset indices and preload new set.
      _index = 0;
      _currentImage = widget.images.isNotEmpty ? widget.images.first : null;
      _prevImage = null;
      if (widget.images.isNotEmpty) _precacheAll();
      // Start or stop timer depending on new length.
      if (widget.images.length > 1) {
        _startTimer();
      } else {
        _timer?.cancel();
        _timer = null;
      }
    }
    if (oldWidget.switchInterval != widget.switchInterval) {
      if (_timer != null) {
        // Recreate with new interval only if we actually rotate.
        if (widget.images.length > 1) {
          _startTimer();
        } else {
          _timer?.cancel();
          _timer = null;
        }
      } else if (widget.images.length > 1) {
        // Interval changed and we now have >1 images but no timer yet (e.g. initial list was empty).
        _startTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    final overlayColor = widget.overlayColor;

    if (_currentImage != null) {
      children.add(_buildImage(_currentImage!, 1));
    }
    if (_fading && _prevImage != null) {
      // Previous image fades out underneath the new one.
      children.add(_buildImage(_prevImage!, 0));
    }

    return Container(
      width: widget.width,
      height: widget.height,
      constraints: widget.constraints,
      margin: widget.margin,
      padding: widget.padding,
      color: widget.color,
      decoration: widget.decoration,
      foregroundDecoration: widget.foregroundDecoration,
      alignment: widget.containerAlignment,
      clipBehavior: widget.clipBehavior,
      transform: widget.transform,
      transformAlignment: widget.transformAlignment,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ...children,
          if (overlayColor != null) Container(color: overlayColor),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }

  Widget _buildImage(ImageProvider image, double targetOpacity) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(image.hashCode.toString() + targetOpacity.toString()),
      tween: Tween(begin: targetOpacity == 1 ? 0.0 : 1.0, end: targetOpacity),
      duration: widget.fadeDuration,
      curve: widget.curve,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: image,
            fit: widget.fit,
            alignment: widget.alignment,
          ),
        ),
      ),
    );
  }
}
