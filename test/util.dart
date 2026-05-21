import 'package:serverpod_tui/src/app.dart';
import 'package:serverpod_tui/src/app_state_holder.dart';
import 'package:serverpod_tui/src/bounded_queue_list.dart';
import 'package:serverpod_tui/src/state.dart';

class TestState extends TuiState {
  @override
  final logHistory = BoundedQueueList<Object>(maxLogEntries);

  @override
  final rawLines = BoundedQueueList<String>(maxRawLines);

  @override
  final Map<String, TrackedOperation> activeOperations = {};

  /// Maximum number of log entries to keep.
  static const maxLogEntries = 10000;

  /// Maximum number of raw lines to keep.
  static const maxRawLines = 10000;
}

class TestStateHolder extends TuiAppStateHolder<TestState> {
  TestStateHolder(this._state);

  final TestState _state;

  @override
  void attach(TuiAppState widgetState) {}

  @override
  void detach(TuiAppState widgetState) {}

  @override
  TestState get state => _state;

  @override
  TuiAppState? get widgetState => null;
}
