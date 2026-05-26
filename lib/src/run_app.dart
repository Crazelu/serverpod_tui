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
  // On Windows, ENABLE_ECHO_INPUT requires ENABLE_LINE_INPUT to be set, or
  // SetConsoleMode rejects with ERROR_INVALID_PARAMETER. Restore lineMode
  // first so echoMode is allowed to follow.
  stdin.lineMode = _originalLineMode;
  stdin.echoMode = _originalEchoMode;
  _terminalStateRestored = true;
}

/// Run a TUI app with terminal settings restoration.
///
/// SIGINT (Ctrl-C) is intentionally not handled here. The nocterm backend
/// converts it into a Ctrl-C keyboard event routed through the component tree,
/// which [TuiAppState] intercepts to copy the current selection or require a
/// second press before exiting.
///
/// SIGTERM still triggers shutdown. When [onShutdownSignal] is null (the
/// default), it runs an immediate `shutdownTuiApp()`. When provided, SIGTERM
/// invokes that callback instead, and the caller is responsible for cleanup
/// and eventually calling `shutdownTuiApp(...)` to tear down the renderer.
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

  // SIGINT is handled in-app via TuiAppState; see the doc comment above.
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
