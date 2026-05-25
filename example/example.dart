import 'package:serverpod_tui/serverpod_tui.dart';

import 'screens/loading_screen.dart';
import 'screens/main_screen.dart';
import 'package:nocterm/nocterm.dart';

enum Screen { loading, main }

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
    }

    return Focusable(
      focused: true,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKey.space) {
          setState(() {
            final nextIndex = (_screen.index + 1) % Screen.values.length;
            _screen = Screen.values[nextIndex];
          });
          return true;
        }
        return false;
      },
      child: screenComponent,
    );
  }
}
