import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonLoader extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final bool enableSwitchAnimation;

  const SkeletonLoader({
    super.key,
    required this.child,
    required this.isLoading,
    this.enableSwitchAnimation = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Skeletonizer(
      enabled: isLoading,
      enableSwitchAnimation: enableSwitchAnimation,
      effect: ShimmerEffect(
        baseColor: isDark ? Colors.grey[850]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[800]! : Colors.grey[100]!,
        duration: const Duration(milliseconds: 1500),
      ),
      child: child,
    );
  }
}

/// List Skeleton Loader
class ListSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;

  const ListSkeletonLoader({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}

/// Grid Skeleton Loader
class GridSkeletonLoader extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final bool isLoading;
  final int crossAxisCount;

  const GridSkeletonLoader({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.isLoading,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: isLoading,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }
}
