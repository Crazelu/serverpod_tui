import 'package:nocterm/nocterm.dart';

/// A terminal backend for nocterm that allows executing
/// [preExit] callback before exiting the Dart process.
class ServerpodTerminalBackend extends StdioBackend {
  ServerpodTerminalBackend({required this.preExit});

  final Future<void> Function(int exitCode) preExit;

  @override
  void requestExit([int exitCode = 0]) {
    preExit(exitCode).then<void>(
      (_) => _restoreTerminalAndExit(exitCode),
      onError: (_) => _restoreTerminalAndExit(exitCode),
    );
  }

  void _restoreTerminalAndExit(int exitCode) {
    // nocterm emits OSC 110/111 (restore default colors) without a
    // BEL/ST terminator. Close any dangling control string, then make cursor
    // visibility the final terminal-state update before the flushed exit.
    // A bare ST is ignored when the terminal is already in its ground state.
    writeRaw('\x1b\\\x1b[?25h');
    super.requestExit(exitCode);
  }
}
