import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Continues the native splash into the first Flutter frame.
///
/// Android/iOS show the launch screen (teal ground, white piggy) until Flutter
/// paints. Without this the handoff is a hard cut from that to a white
/// scaffold. [SplashGate] paints the identical artwork as its first frame, then
/// cross-fades it away, so the two stages read as one continuous screen.
///
/// The dwell is deliberately short — this is a seam-hider, not a brand ad. When
/// the platform asks for reduced motion the gate is skipped entirely.
class SplashGate extends StatefulWidget {
  const SplashGate({super.key, required this.child});

  final Widget child;

  /// How long the artwork holds before it starts dissolving.
  static const Duration dwell = Duration(milliseconds: 260);

  /// How long the cross-fade takes.
  static const Duration fade = Duration(milliseconds: 420);

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashGate.fade,
  );

  bool _started = false;

  @override
  void initState() {
    super.initState();
    // Start dissolving only after the app has actually painted a frame, so the
    // gate hides real startup work instead of adding to it.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(SplashGate.dwell);
      if (mounted) await _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    }
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
      builder: (context, _) {
        final t = _controller.value;
        if (t == 1) return widget.child;
        return Stack(
          children: [
            // The app fades up underneath rather than appearing at full
            // strength the instant the cover clears.
            Opacity(opacity: Curves.easeIn.transform(t), child: widget.child),
            IgnorePointer(
              child: Opacity(
                opacity: 1 - Curves.easeInOut.transform(t),
                child: const _SplashArtwork(),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// The launch artwork, matched to `flutter_native_splash.yaml`.
class _SplashArtwork extends StatelessWidget {
  const _SplashArtwork();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.seed,
      child: const Center(
        child: Icon(Icons.savings_rounded, size: 132, color: Colors.white),
      ),
    );
  }
}
