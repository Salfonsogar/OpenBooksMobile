import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final ShimmerLoadingShape shape;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
    this.shape = ShimmerLoadingShape.rectangle,
  });

  factory ShimmerLoading.card({double width = double.infinity, double height = 120}) {
    return ShimmerLoading(
      width: width,
      height: height,
      borderRadius: 12,
      shape: ShimmerLoadingShape.rounded,
    );
  }

  factory ShimmerLoading.avatar({double size = 48}) {
    return ShimmerLoading(
      width: size,
      height: size,
      borderRadius: size / 2,
      shape: ShimmerLoadingShape.circle,
    );
  }

  factory ShimmerLoading.text({double width = 100, double height = 16}) {
    return ShimmerLoading(
      width: width,
      height: height,
      borderRadius: 4,
      shape: ShimmerLoadingShape.rectangle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: _getBorderRadius(),
        ),
      ),
    );
  }

  BorderRadius _getBorderRadius() {
    switch (shape) {
      case ShimmerLoadingShape.circle:
        return BorderRadius.circular(height / 2);
      case ShimmerLoadingShape.rounded:
        return BorderRadius.circular(borderRadius);
      case ShimmerLoadingShape.rectangle:
        return BorderRadius.circular(borderRadius);
    }
  }
}

enum ShimmerLoadingShape { rectangle, circle, rounded }

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemSpacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.itemSpacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (_, _) => SizedBox(height: itemSpacing),
      itemBuilder: (context, index) => ShimmerLoading.card(height: itemHeight),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemBuilder: (context, index) => const ShimmerLoading(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 12,
        shape: ShimmerLoadingShape.rounded,
      ),
    );
  }
}