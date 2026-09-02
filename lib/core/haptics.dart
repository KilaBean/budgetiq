import 'package:flutter/services.dart';

/// Thin wrapper over [HapticFeedback] so call sites read intent, not mechanics,
/// and tactile feedback stays consistent across the app.
class Haptics {
  const Haptics._();

  /// A light tap — confirming a routine action (add, save).
  static void light() => HapticFeedback.lightImpact();

  /// Selection tick — switching options / tabs.
  static void selection() => HapticFeedback.selectionClick();

  /// A firmer tap — destructive or significant actions (delete).
  static void medium() => HapticFeedback.mediumImpact();
}
