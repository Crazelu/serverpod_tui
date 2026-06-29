import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

/// Renders a tip.
class Tip extends StatelessComponent {
  const Tip(this.tip, {super.key});

  final String tip;

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);
    return Text('💡 $tip', style: TextStyle(color: theme.brightText));
  }
}
