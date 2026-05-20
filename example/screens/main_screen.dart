import 'package:intl/intl.dart';
import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/nocterm_components.dart';

class MainScreen extends StatefulComponent {
  @override
  State<StatefulComponent> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _selectedTab = 0;

  @override
  Component build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      mainAxisSize: .max,
      children: [
        Expanded(
          child: BorderedBox(
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .max,
              children: [
                TabBar(
                  labels: ['Logs'],
                  selectedTab: _selectedTab,
                  onTabChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),
                Expanded(
                  child: ListView(
                    children: [
                      LogMessage(
                        timestamp: DateTime.now(),
                        message:
                            'SERVERPOD version: 3.5.0-beta.1, dart: 3.11.0 '
                            '(stable) (Mon Feb 9 00:38:07 2026 -0800) on '
                            '"macos_arm64", time: 2026-04-01 07:20:19.806701Z',
                        logLevel: .info,
                      ),
                      LogMessage(
                        timestamp: DateTime.now(),
                        message: 'Webserver listening on http://localhost:8082',
                        logLevel: .info,
                      ),
                      LogMessage(
                        timestamp: DateTime.now(),
                        message: 'Some other message',
                        logLevel: .info,
                      ),
                      LogDivider(label: 'Hot reload (x4)'),
                      LogMessage(
                        timestamp: DateTime.now(),
                        message: 'We are back after the hot reload!!',
                        logLevel: .info,
                      ),
                      LogMessage(
                        timestamp: DateTime.now(),
                        message: 'Oops, something went wrong.',
                        logLevel: .warning,
                      ),
                      LogMessage(
                        timestamp: DateTime.now(),
                        message: 'And now we crashed :(',
                        logLevel: .error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ButtonBar(
          buttons: [
            Button(
              name: 'Hot Reload',
              activationChar: 'R',
              activationKeys: const [.keyR],
              onActivate: (_) {},
            ),
            Button(
              name: 'Create Migration',
              activationChar: 'M',
              activationKeys: const [.keyM],
              onActivate: (_) {},
            ),
            Button(
              name: 'Apply Migration',
              activationChar: 'A',
              activationKeys: const [.keyA],
              onActivate: (_) {},
            ),
            Button(
              name: 'Quit',
              activationChar: 'Q',
              activationKeys: const [.keyQ],
              onActivate: (_) {
                shutdownTuiApp(0);
              },
            ),
          ],
        ),
      ],
    );
  }
}

enum LogLevel {
  debug('debug', Colors.gray),
  info('info ', Colors.blue),
  warning('warn ', Colors.yellow),
  error('error', Colors.red),
  fatal('fatal', Colors.brightRed)
  ;

  const LogLevel(this.label, this.color);
  final String label;
  final Color color;
}

class LogMessage extends StatelessComponent {
  static final _timeFormat = DateFormat('HH:mm:ss');

  final DateTime timestamp;
  final LogLevel logLevel;
  final String message;

  LogMessage({
    required this.timestamp,
    required this.logLevel,
    required this.message,
  });

  @override
  Component build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      mainAxisAlignment: .start,
      mainAxisSize: .max,
      children: [
        Text(logLevel.label, style: TextStyle(color: logLevel.color)),
        SizedBox(width: 1),
        Text(
          _timeFormat.format(timestamp.toLocal()),
          style: TextStyle(fontWeight: .dim),
        ),
        SizedBox(width: 1),
        Expanded(child: Text(message)),
      ],
    );
  }
}

class LogDivider extends StatelessComponent {
  final String label;

  LogDivider({super.key, required this.label});

  @override
  Component build(BuildContext context) {
    return Stack(
      children: [
        Divider(),
        Center(child: Text(' $label ')),
      ],
    );
  }
}
