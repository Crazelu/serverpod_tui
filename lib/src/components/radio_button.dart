import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

/// A radio button component.
class RadioButton extends StatelessComponent {
  const RadioButton({
    required this.label,
    required this.value,
    this.focused = false,
  });

  final bool value;
  final String label;
  final bool focused;

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);
    final indicator = value ? '●' : '○';

    return Text(
      '$indicator $label',
      style: TextStyle(
        color: Color.defaultColor,
        backgroundColor: focused ? theme.activationKey : null,
      ),
    );
  }
}
