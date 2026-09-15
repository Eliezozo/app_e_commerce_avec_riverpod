import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Icône qui vole du bouton « ajouter » vers l'icône panier (bonus).
void playAddToCartAnimation({
  required BuildContext context,
  required GlobalKey targetKey,
}) {
  final overlayState = Overlay.maybeOf(context);
  final sourceBox = context.findRenderObject();
  final targetContext = targetKey.currentContext;
  final targetBox = targetContext?.findRenderObject();

  if (overlayState == null ||
      sourceBox is! RenderBox ||
      !sourceBox.hasSize ||
      targetBox is! RenderBox ||
      !targetBox.hasSize) {
    return;
  }

  final start = sourceBox.localToGlobal(sourceBox.size.center(Offset.zero));
  final end = targetBox.localToGlobal(targetBox.size.center(Offset.zero));

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      return _FlyingCartIcon(
        start: start,
        end: end,
        onCompleted: () => entry.remove(),
      );
    },
  );
  overlayState.insert(entry);
}

class _FlyingCartIcon extends StatefulWidget {
  const _FlyingCartIcon({
    required this.start,
    required this.end,
    required this.onCompleted,
  });

  final Offset start;
  final Offset end;
  final VoidCallback onCompleted;

  @override
  State<_FlyingCartIcon> createState() => _FlyingCartIconState();
}

class _FlyingCartIconState extends State<_FlyingCartIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _position;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _position = Tween<Offset>(begin: widget.start, end: widget.end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );
    _scale = Tween<double>(begin: 1, end: 0.35).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _opacity = Tween<double>(begin: 1, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _controller.forward().whenComplete(widget.onCompleted);
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
        final offset = _position.value;
        return Positioned(
          left: offset.dx - 14,
          top: offset.dy - 14,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: child,
            ),
          ),
        );
      },
      child: const Material(
        color: AppColors.primary,
        shape: CircleBorder(),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Icon(
            Icons.shopping_bag_rounded,
            size: 16,
            color: AppColors.onPrimary,
          ),
        ),
      ),
    );
  }
}
