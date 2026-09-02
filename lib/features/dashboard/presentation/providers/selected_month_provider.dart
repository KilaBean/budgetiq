import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../shared/domain/month.dart';

part 'selected_month_provider.g.dart';

/// The month the dashboard is showing.
///
/// Everything on the dashboard — summary, insights, budget snapshot — reads
/// this rather than "now", so stepping back a month moves the whole screen
/// together. Bounded to months the loaded window can actually answer for.
@Riverpod(keepAlive: true)
class SelectedMonth extends _$SelectedMonth {
  @override
  Month build() => Month.current();

  void previous() => state = state.previous;

  /// Steps forward, never past the current month — there is no future data.
  void next() {
    if (isAtCurrent) return;
    state = state.next;
  }

  void reset() => state = Month.current();

  bool get isAtCurrent => state == Month.current();
}
