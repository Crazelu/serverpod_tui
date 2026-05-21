import 'package:meta/meta.dart';
import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/app_state_holder.dart';
import 'package:serverpod_tui/src/components/spinner.dart';

/// A root TUI component.
abstract class TuiApp<T extends TuiAppStateHolder> extends StatefulComponent {
  const TuiApp({super.key, required this.holder});

  final T holder;

  @override
  TuiAppState<TuiApp> createState();
}

/// The logic and internal state for a [TuiApp].
abstract class TuiAppState<S extends TuiApp> extends State<S> {
  @override
  void initState() {
    super.initState();
    component.holder.attach(this);
  }

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void dispose() {
    component.holder.detach(this);
    super.dispose();
  }

  void rebuild() {
    setState(() {});
  }

  /// Describes the part of the user interface represented by this component.
  Component buildApp(BuildContext context);

  @override
  @protected
  Component build(BuildContext context) {
    final state = component.holder.state;

    return NoctermApp(
      child: Builder(
        builder: (context) {
          final themeData = TuiTheme.of(context);
          return TuiTheme(
            data: themeData.copyWith(
              background: Color.defaultColor,
            ),
            child: SpinnerScope(
              active: state.activeOperations.isNotEmpty,
              child: buildApp(context),
            ),
          );
        },
      ),
    );
  }
}
