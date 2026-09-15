import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Skeleton shimmer sans dépendance tierce.
class CatalogSkeleton extends StatefulWidget {
  const CatalogSkeleton({super.key});

  @override
  State<CatalogSkeleton> createState() => _CatalogSkeletonState();
}

class _CatalogSkeletonState extends State<CatalogSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = 0.35 + (_controller.value * 0.35);
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            return Opacity(
              opacity: opacity,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
