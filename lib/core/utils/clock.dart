/// Source of the current time.
///
/// Injected rather than calling `DateTime.now()` directly so that anything
/// deriving from "now" — relative timestamps, sort order, overdue checks — can
/// be tested deterministically with a fixed clock.
abstract interface class Clock {
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}
