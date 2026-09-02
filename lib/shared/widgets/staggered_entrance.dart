import 'package:flutter/material.dart';

/// Fades and lifts a child into place, offset by [index] so a column of cards
/// arrives as a sequence rather than all at once.
///
/// Deliberately small numbers: 12 logical pixels of travel and a 60ms step.
/// The effect should register as the screen settling, not as an animation the
/// user has to wait through. Honours the platform's reduced-motion setting.
class StaggeredEntrance extends StatefulWidget {
  const StaggeredEntrance({
    super.key,
    required this.index,
    required this.child,
  });

  final int index;
  final Widget child;

  static const Duration _duration = Duration(milliseconds: 340);
  static const Duration _step = Duration(milliseconds: 60);

  /// Items past this position start together — a long list should not have the
  /// last card waiting a second to appear.
  static const int _maxSteps = 6;

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: StaggeredEntrance._duration,
  );

  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scheduled) return;
    _scheduled = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    final steps = widget.index.clamp(0, StaggeredEntrance._maxSteps);
    Future<void>.delayed(StaggeredEntrance._step * steps, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    return AnimatedBuilder(
      animation: curve,
      builder: (context, child) => Opacity(
        opacity: curve.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}
