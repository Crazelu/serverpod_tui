import 'package:nocterm/nocterm.dart';
import 'package:test/test.dart';

import 'util.dart';

Future<void> _sendCtrlC(NoctermTester tester) {
  return tester.sendKeyEvent(
    const KeyboardEvent(
      logicalKey: LogicalKey.keyC,
      modifiers: ModifierKeys(ctrl: true),
    ),
  );
}

void main() {
  late NoctermTester tester;
  late TestState state;
  late TestStateHolder holder;
  late bool exited;

  setUp(() async {
    state = TestState();
    holder = TestStateHolder(state);
    exited = false;
    tester = await NoctermTester.create(size: const Size(80, 24));
    await tester.pumpComponent(
      TestApp(holder: holder, onExitCallback: () => exited = true),
    );
  });

  tearDown(() async {
    tester.dispose();
    await holder.dispose();
  });

  group('Given text is selected', () {
    setUp(() {
      state.selectedText = 'a selected log line';
    });

    test(
      'when Ctrl-C is pressed then the selection is copied without exiting',
      () async {
        await _sendCtrlC(tester);

        expect(ClipboardManager.paste(), 'a selected log line');
        expect(state.ctrlCHint, 'Copied to clipboard');
        expect(exited, isFalse);
      },
    );
  });

  group('Given nothing is selected', () {
    test(
      'when Ctrl-C is pressed once then exit is armed without exiting',
      () async {
        await _sendCtrlC(tester);

        expect(state.ctrlCHint, 'Press Ctrl-C again to exit');
        expect(exited, isFalse);
      },
    );

    test('when Ctrl-C is pressed twice then it exits', () async {
      await _sendCtrlC(tester);
      await _sendCtrlC(tester);

      expect(exited, isTrue);
    });
  });
}
