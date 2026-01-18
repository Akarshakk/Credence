import 'package:flutter/material.dart';

/// A widget wrapper that provides performance optimizations to reduce buffer queue issues
class PerformanceOptimizedWidget extends StatelessWidget {
  final Widget child;
  final bool enableRepaintBoundary;
  final bool enableAutomaticKeepAlive;

  const PerformanceOptimizedWidget({
    super.key,
    required this.child,
    this.enableRepaintBoundary = true,
    this.enableAutomaticKeepAlive = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget optimizedChild = child;

    // Wrap with RepaintBoundary to isolate repaints
    if (enableRepaintBoundary) {
      optimizedChild = RepaintBoundary(child: optimizedChild);
    }

    // Add AutomaticKeepAlive if needed
    if (enableAutomaticKeepAlive) {
      optimizedChild = AutomaticKeepAlive(
        child: optimizedChild,
      );
    }

    return optimizedChild;
  }
}

/// A performance-optimized ListView that reduces buffer queue issues
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final ScrollController? controller;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  const OptimizedListView({
    super.key,
    required this.children,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
      physics: physics ?? const ClampingScrollPhysics(),
      // Use cacheExtent to optimize rendering
      cacheExtent: 250.0,
      itemCount: children.length,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: children[index],
        );
      },
    );
  }
}

/// A performance-optimized image widget
class OptimizedImage extends StatelessWidget {
  final String? imagePath;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const OptimizedImage({
    super.key,
    this.imagePath,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (assetPath != null) {
      imageWidget = Image.asset(
        assetPath!,
        width: width,
        height: height,
        fit: fit,
        // Optimize memory usage
        cacheWidth: width?.round(),
        cacheHeight: height?.round(),
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      );
    } else if (imagePath != null) {
      imageWidget = Image.network(
        imagePath!,
        width: width,
        height: height,
        fit: fit,
        // Optimize memory usage
        cacheWidth: width?.round(),
        cacheHeight: height?.round(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? const CircularProgressIndicator();
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.error);
        },
      );
    } else {
      imageWidget = errorWidget ?? const Icon(Icons.image_not_supported);
    }

    return RepaintBoundary(child: imageWidget);
  }
}