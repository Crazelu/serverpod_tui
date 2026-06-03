import 'package:serverpod_tui/serverpod_tui.dart';

import 'screens/form_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/main_screen.dart';
import 'package:nocterm/nocterm.dart';

enum Screen { loading, main, form }

void main() {
  runTuiApp(const ExampleApp());
}

class ExampleApp extends StatefulComponent {
  const ExampleApp({super.key});

  @override
  State<ExampleApp> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> with TickerProviderStateMixin {
  Screen _screen = .loading;

  @override
  Component build(BuildContext context) {
    Component screenComponent;
    switch (_screen) {
      case Screen.loading:
        screenComponent = LoadingScreen();
      case Screen.main:
        screenComponent = MainScreen();
      case Screen.form:
        screenComponent = FormScreen();
    }

    return Focusable(
      focused: true,
      onKeyEvent: (event) {
        switch (event.logicalKey) {
          case LogicalKey.space:
            setState(() {
              final nextIndex = (_screen.index + 1) % Screen.values.length;
              _screen = Screen.values[nextIndex];
            });
            return true;
          case LogicalKey.escape:
            shutdownTuiApp();
            return true;
          default:
            return false;
        }
      },
      child: screenComponent,
    );
  }
}
