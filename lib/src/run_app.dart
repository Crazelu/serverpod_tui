import 'dart:io';

import 'package:nocterm/nocterm.dart';

bool _terminalStateCaptured = false;
bool _terminalStateRestored = false;

late bool _originalEchoMode;
late bool _originalLineMode;

void _captureTerminalState() {
  _originalEchoMode = stdin.echoMode;
  _originalLineMode = stdin.lineMode;
  _terminalStateCaptured = true;
  _terminalStateRestored = false;
}

/// Restores stdin terminal modes captured by [runTuiApp].
///
/// Safe to call multiple times.
void _restoreTerminal() {
  if (!_terminalStateCaptured || _terminalStateRestored) return;
  stdin.echoMode = _originalEchoMode;
  stdin.lineMode = _originalLineMode;
  _terminalStateRestored = true;
}

/// Run a TUI app with terminal settings restoration.
///
/// When [onShutdownSignal] is null (the default), SIGINT/SIGTERM trigger an
/// immediate `shutdownTuiApp()` and the app exits without running any user
/// cleanup.
///
/// When [onShutdownSignal] is provided, signals invoke that callback instead.
/// The caller is then responsible for running cleanup and eventually calling
/// `shutdownTuiApp(...)` to tear down the nocterm renderer.
Future<void> runTuiApp(
  Component app, {
  bool enableHotReload = true,
  TerminalBackend? backend,
  void Function()? onShutdownSignal,
}) async {
  _captureTerminalState();

  void onShutDownSignalDefault(ProcessSignal _) {
    shutdownTuiApp();
  }

  void onShutDownSignalDelegated(ProcessSignal _) {
    _restoreTerminal();
    onShutdownSignal!.call();
  }

  final handler = onShutdownSignal == null
      ? onShutDownSignalDefault
      : onShutDownSignalDelegated;

  ProcessSignal.sigint.watch().listen(handler);
  if (!Platform.isWindows) {
    ProcessSignal.sigterm.watch().listen(handler);
  }

  await runApp(app, enableHotReload: enableHotReload, backend: backend);
}

/// Restores stdin terminal modes captured by [runTuiApp]
/// then shuts down the nocterm app with proper terminal cleanup.
void shutdownTuiApp([int exitCode = 0]) {
  _restoreTerminal();
  shutdownApp(exitCode);
}
