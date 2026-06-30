import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/components/spinner.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

/// Activity state shown as a leading indicator on a tab.
enum TabActivity {
  /// No indicator.
  none,

  /// A solid green dot.
  running,

  /// An animated spinner.
  loading,

  /// A solid red square.
  stopped,
}

/// A tab bar component.
class TabBar extends StatelessComponent {
  const TabBar({
    super.key,
    required this.labels,
    required this.selectedTab,
    required this.onTabChanged,
    this.states = const [],
  });

  final List<String> labels;
  final int selectedTab;
  final ValueChanged<int> onTabChanged;

  /// Per-tab activity indicators, aligned by index with [labels]. Indices
  /// without an entry (or set to [TabActivity.none]) render no indicator.
  final List<TabActivity> states;

  @override
  Component build(BuildContext context) {
    final tabComponents = <Component>[];

    for (int i = 0; i < labels.length; i += 1) {
      tabComponents.add(
        _TabSpacing(
          width: 1,
          type: selectedTab == i
              ? _TabSpacingType.shortRight
              : _TabSpacingType.full,
        ),
      );

      // Tab.
      tabComponents.add(
        _Tab(
          label: labels[i],
          selected: i == selectedTab,
          state: i < states.length ? states[i] : TabActivity.none,
          onTap: () => onTabChanged(i),
        ),
      );

      // Spacing after tab.
      _TabSpacingType spacingType;
      if (i == selectedTab) {
        spacingType = _TabSpacingType.shortLeft;
      } else {
        spacingType = _TabSpacingType.full;
      }

      tabComponents.add(_TabSpacing(width: 2, type: spacingType));
    }

    // Fill remaining space after last tab.
    tabComponents.add(
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return _TabSpacing(
              width: constraints.maxWidth.toInt(),
              type: _TabSpacingType.full,
            );
          },
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tabComponents,
    );
  }
}

class _Tab extends StatelessComponent {
  const _Tab({
    required this.label,
    required this.selected,
    required this.state,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final TabActivity state;
  final VoidCallback onTap;

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);
    final indicator = _indicator(theme);
    // The indicator and its trailing space occupy two columns, so the
    // selection underline must cover them too.
    final underlineWidth = label.length + (indicator != null ? 2 : 0);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (indicator != null) ...[indicator, const Text(' ')],
              Text(
                label,
                style: TextStyle(
                  color: theme.brightText,
                  fontWeight: selected ? FontWeight.normal : FontWeight.dim,
                ),
              ),
            ],
          ),
          Text(
            ''.padLeft(underlineWidth, '━'),
            style: TextStyle(
              color: selected ? theme.activationKey : null,
              fontWeight: selected ? FontWeight.normal : FontWeight.dim,
            ),
          ),
        ],
      ),
    );
  }

  /// The leading status indicator for [state], or null for [TabActivity.none].
  /// The indicator keeps its status colour whether or not the tab is selected,
  /// so app state stays readable at a glance.
  Component? _indicator(ServerpodThemeData theme) {
    switch (state) {
      case TabActivity.none:
        return null;
      case TabActivity.running:
        return Text('●', style: TextStyle(color: theme.success));
      case TabActivity.loading:
        return SpinnerIcon(color: theme.spinner);
      case TabActivity.stopped:
        return Text('◼', style: TextStyle(color: theme.failure));
    }
  }
}

enum _TabSpacingType { full, shortLeft, shortRight }

class _TabSpacing extends StatelessComponent {
  final int width;
  final _TabSpacingType type;

  const _TabSpacing({required this.width, required this.type});

  @override
  Component build(BuildContext context) {
    String underline;
    switch (type) {
      case _TabSpacingType.full:
        underline = ''.padLeft(width, '━');
        break;
      case _TabSpacingType.shortLeft:
        underline = '╺'.padRight(width, '━');
        break;
      case _TabSpacingType.shortRight:
        underline = '╸'.padLeft(width, '━');
        break;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(''.padLeft(width)),
        Text(underline, style: const TextStyle(fontWeight: FontWeight.dim)),
      ],
    );
  }
}
