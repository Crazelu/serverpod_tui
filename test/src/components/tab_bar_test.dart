import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/serverpod_tui.dart';
import 'package:test/test.dart';

/// Renders a [TabBar] and returns the full rendered text. When [withSpinner] is
/// set, the bar is wrapped in a [SpinnerScope] so loading tabs animate (a bare
/// [SpinnerIcon] falls back to a static glyph without one).
Future<String> _render(
  List<String> labels,
  List<TabActivity> states, {
  int selectedTab = 0,
  int width = 60,
  bool withSpinner = false,
}) async {
  final tester = await NoctermTester.create(size: Size(width.toDouble(), 4));
  try {
    Component tabBar = TabBar(
      labels: labels,
      states: states,
      selectedTab: selectedTab,
      onTabChanged: (_) {},
    );
    if (withSpinner) {
      tabBar = SpinnerScope(active: true, child: tabBar);
    }
    await tester.pumpComponent(tabBar);
    return tester.terminalState.getText();
  } finally {
    tester.dispose();
  }
}

void main() {
  group('Given tabs with activity states', () {
    test('when a tab is running then a dot precedes its label', () async {
      final text = await _render(
        ['Server logs', 'app'],
        [TabActivity.none, TabActivity.running],
      );

      expect(text, contains('● app'));
    });

    test('when a tab is stopped then a square precedes its label', () async {
      final text = await _render(
        ['Server logs', 'app'],
        [TabActivity.none, TabActivity.stopped],
      );

      expect(text, contains('◼ app'));
    });

    test('when a tab is loading then a spinner precedes its label', () async {
      final text = await _render(
        ['Server logs', 'app'],
        [TabActivity.none, TabActivity.loading],
        withSpinner: true,
      );

      // A braille spinner frame, not the solid running/stopped glyphs.
      expect(text, contains('⠋ app'));
      expect(text, isNot(contains('● app')));
    });

    test('when a tab has no activity then no indicator precedes it', () async {
      final text = await _render(['Server logs'], [TabActivity.none]);

      expect(text, isNot(contains('●')));
      expect(text, isNot(contains('◼')));
    });
  });

  test(
    'Given fewer states than labels '
    'when rendered '
    'then tabs without a state get no indicator',
    () async {
      final text = await _render(
        ['Server logs', 'app'],
        [TabActivity.running],
      );

      expect(text, contains('● Server logs'));
      // The second tab has no corresponding state, so no indicator is drawn.
      expect(text, isNot(contains('● app')));
    },
  );
}
