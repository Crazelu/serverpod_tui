import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/serverpod_tui.dart';
import 'package:test/test.dart';

void main() {
  // NoctermTestBinding is a process-wide singleton, so every test must
  // dispose its tester before the next one can call NoctermTester.create.
  late NoctermTester tester;
  tearDown(() => tester.dispose());

  group('Given tabs with activity states', () {
    test('when a tab is running then a dot precedes its label', () async {
      tester = await NoctermTester.create(size: const Size(60, 4));
      await tester.pumpComponent(
        TabBar(
          labels: const ['Server logs', 'app'],
          states: const [TabActivity.none, TabActivity.running],
          selectedTab: 0,
          onTabChanged: (_) {},
        ),
      );

      expect(tester.terminalState.getText(), contains('● app'));
    });

    test(
      'when a tab is stopped then an empty circle precedes its label',
      () async {
        tester = await NoctermTester.create(size: const Size(60, 4));
        await tester.pumpComponent(
          TabBar(
            labels: const ['Server logs', 'app'],
            states: const [TabActivity.none, TabActivity.stopped],
            selectedTab: 0,
            onTabChanged: (_) {},
          ),
        );

        expect(tester.terminalState.getText(), contains('○ app'));
      },
    );

    test('when a tab is loading then a spinner precedes its label', () async {
      tester = await NoctermTester.create(size: const Size(60, 4));
      // Wrap in a SpinnerScope so the loading frame animates; a bare
      // SpinnerIcon falls back to a static glyph without one.
      await tester.pumpComponent(
        SpinnerScope(
          active: true,
          child: TabBar(
            labels: const ['Server logs', 'app'],
            states: const [TabActivity.none, TabActivity.loading],
            selectedTab: 0,
            onTabChanged: (_) {},
          ),
        ),
      );

      final text = tester.terminalState.getText();
      // A braille spinner frame, not the solid running/stopped glyphs.
      expect(text, contains('⠋ app'));
      expect(text, isNot(contains('● app')));
    });

    test('when a tab has no activity then no indicator precedes it', () async {
      tester = await NoctermTester.create(size: const Size(60, 4));
      await tester.pumpComponent(
        TabBar(
          labels: const ['Server logs'],
          states: const [TabActivity.none],
          selectedTab: 0,
          onTabChanged: (_) {},
        ),
      );

      final text = tester.terminalState.getText();
      expect(text, isNot(contains('●')));
      expect(text, isNot(contains('○')));
    });
  });

  test(
    'Given fewer states than labels '
    'when rendered '
    'then tabs without a state get no indicator',
    () async {
      tester = await NoctermTester.create(size: const Size(60, 4));
      await tester.pumpComponent(
        TabBar(
          labels: const ['Server logs', 'app'],
          states: const [TabActivity.running],
          selectedTab: 0,
          onTabChanged: (_) {},
        ),
      );

      final text = tester.terminalState.getText();
      expect(text, contains('● Server logs'));
      // The second tab has no corresponding state, so no indicator is drawn.
      expect(text, isNot(contains('● app')));
    },
  );
}
