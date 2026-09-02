import 'package:flutter/material.dart';

/// Friendly full-screen fallback shown when a widget subtree throws, replacing
/// Flutter's default red error screen in release builds.
class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // Use a minimal MaterialApp-free layout so it renders even if theming is
    // unavailable at the point of failure.
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.sentiment_dissatisfied, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                const Text(
                  'The app hit an unexpected error. Please try again.',
                  textAlign: TextAlign.center,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
