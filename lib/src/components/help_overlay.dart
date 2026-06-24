import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

import 'shrink_wrap_scroll_view.dart';

typedef HelpOverlayBindings = List<(String, List<(String, String)>)>;

/// Width reserved for the activation-key column in the help body.
const _keyColumnWidth = 24.0;

/// Help overlay showing all keybindings. Sizes to its content; scrolls if
/// content exceeds the available terminal height.
class HelpOverlay extends StatefulComponent {
  const HelpOverlay({
    super.key,
    required this.bindings,
    required this.closeKey,
    this.controller,
  });

  final HelpOverlayBindings bindings;
  final ScrollController? controller;

  /// The key for dismissing this overlay.
  /// This is only displayed. Users should listen for the key event
  /// and to dismiss the overlay.
  final String closeKey;

  @override
  State<StatefulComponent> createState() => _HelpOverlayState();
}

class _HelpOverlayState extends State<HelpOverlay> {
  ScrollController? _ownedController;

  ScrollController get _effectiveController =>
      component.controller ?? (_ownedController ??= ScrollController());

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Component build(BuildContext context) {
    final st = ServerpodTheme.of(context);
    final theme = TuiTheme.of(context);
    final scrollController = _effectiveController;

    // Outer Padding bounds the panel to (screen - 4) on each axis so
    // SingleChildScrollView has finite extent to clamp against and scroll
    // within when content overflows.
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: theme.surface,
            border: BoxBorder.all(
              style: BoxBorderStyle.rounded,
              color: st.activationKey,
            ),
            title: BorderTitle(
              text: 'Help',
              style: TextStyle(
                color: st.activationKey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShrinkWrapScrollView(
                controller: scrollController,
                thumbVisibility: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 1),
                    for (final (section, items) in component.bindings) ...[
                      Text(
                        section,
                        style: TextStyle(
                          color: theme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      for (final (key, desc) in items)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: _keyColumnWidth,
                              child: Text(
                                key,
                                style: TextStyle(
                                  color: theme.onSurface,
                                  fontWeight: FontWeight.dim,
                                ),
                              ),
                            ),
                            Text(
                              desc,
                              style: TextStyle(color: theme.onSurface),
                            ),
                          ],
                        ),
                      const SizedBox(height: 1),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  text: 'Press ',
                  style: TextStyle(
                    color: theme.onSurface,
                    fontWeight: FontWeight.dim,
                  ),
                  children: [
                    TextSpan(
                      text: component.closeKey,
                      style: TextStyle(
                        color: st.activationKey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(text: ' to close'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
