import 'dart:io';

import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

/// A check box component
class Checkbox extends StatelessComponent {
  const Checkbox({
    super.key,
    required this.label,
    required this.value,
    this.focused = false,
  });

  final String label;
  final bool value;
  final bool focused;

  String get indicator {
    if (Platform.isWindows || Platform.isLinux) {
      return value ? '🞕' : '🞎';
    }
    return value ? '■' : '□';
  }

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);

    return Text(
      ' $indicator $label ',
      style: TextStyle(
        color: Color.defaultColor,
        backgroundColor: focused ? theme.activationKey : null,
      ),
    );
  }
}
