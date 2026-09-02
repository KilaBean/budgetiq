import 'package:flutter/material.dart';

/// A shimmering placeholder block used to build skeleton loading states.
///
/// Wrap one or more [SkeletonBox]es in a layout that mirrors the real content
/// so the transition from loading to loaded is seamless.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.width, this.height = 14, this.radius = 8});

  final double? width;
  final double height;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surfaceContainerHigh;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 - 2 * _controller.value, 0),
              end: Alignment(1 - 2 * _controller.value, 0),
              colors: [base, highlight, base],
              stops: const [0.35, 0.5, 0.65],
            ),
          ),
        );
      },
    );
  }
}

/// A vertical list of skeleton rows (icon chip + two lines + trailing) that
/// matches a typical transaction/category list while loading.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: rows,
      separatorBuilder: (_, _) => const SizedBox(height: 18),
      itemBuilder: (_, _) => const Row(
        children: [
          SkeletonBox(width: 40, height: 40, radius: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 140, height: 13),
                SizedBox(height: 8),
                SkeletonBox(width: 90, height: 11),
              ],
            ),
          ),
          SizedBox(width: 12),
          SkeletonBox(width: 60, height: 14),
        ],
      ),
    );
  }
}
