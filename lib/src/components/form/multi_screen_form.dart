import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/components/form/configuration.dart';
import 'package:serverpod_tui/src/components/form/form.dart';
import 'package:serverpod_tui/src/components/text_button.dart';
import 'package:serverpod_tui/src/components/wrap.dart';
import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';
import 'package:serverpod_tui/src/form/state.dart';

/// A multi screen form component
/// that renders a screen for each config in [state]
/// with a summary screen at the end.
class MultiScreenForm extends Form {
  const MultiScreenForm({
    super.key,
    required this.state,
    required super.scrollController,
    required super.rebuild,
    super.spacing = 1,
    super.padding = const EdgeInsets.symmetric(horizontal: 1),
    this.backButtonActivationKey = LogicalKey.space,
    this.nextButtonActivationKey = LogicalKey.space,
    super.onSubmit,
    this.summaryDescription,
  }) : super(state: state);

  /// State for multi screen form.
  final MultiScreenFormState state;

  /// Activation key for the back button.
  final LogicalKey backButtonActivationKey;

  /// Activation key for the next button.
  final LogicalKey nextButtonActivationKey;

  /// Optional description for the summary screen.
  final String? summaryDescription;

  @override
  Component build(BuildContext context) {
    if (state.isSummary) {
      return _SummaryScreen(
        state: state,
        rebuild: rebuild,
        padding: padding,
        description: summaryDescription,
      );
    }

    final config = state.configurations[state.currentScreenIndex];
    final showMultiScreenNavigationButtons =
        !state.isSummary && !state.hasSingleScreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: padding,
                child: FormConfiguration(
                  state: state,
                  config: config,
                  focused: !state.focusOnButton,
                  rebuild: rebuild,
                  onFormInputSubmit: onSubmit,
                  onFormInputArrowUp: () {
                    state.focusUp();
                    rebuild();
                  },
                  onFormInputArrowDown: () {
                    state.focusDown();
                    rebuild();
                  },
                ),
              ),
            ),
          ),
        ),
        if (showMultiScreenNavigationButtons)
          _MultiScreenNavigationButtons(
            state: state,
            rebuild: rebuild,
            backButtonActivationKey: backButtonActivationKey,
            nextButtonActivationKey: nextButtonActivationKey,
          ),
      ],
    );
  }
}

class _MultiScreenNavigationButtons extends StatelessComponent {
  const _MultiScreenNavigationButtons({
    required this.state,
    required this.rebuild,
    required this.backButtonActivationKey,
    required this.nextButtonActivationKey,
  });

  final MultiScreenFormState state;
  final VoidCallback rebuild;
  final LogicalKey backButtonActivationKey;
  final LogicalKey nextButtonActivationKey;

  @override
  Component build(BuildContext context) {
    final isFirstScreen = state.currentScreenIndex == 0;

    return Align(
      alignment: Alignment.bottomRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            name: 'Back',
            activationKeys: [backButtonActivationKey],
            onActivate: (_) {
              state.previousScreen();
              rebuild();
            },
            enabled: !isFirstScreen,
            focused: state.focusOnButton && state.focusedButtonIndex == 0,
          ),
          const SizedBox(width: 1),
          TextButton(
            name: 'Next',
            activationKeys: [nextButtonActivationKey],
            onActivate: (_) {
              state.nextScreen();
              rebuild();
            },
            focused: state.focusOnButton && state.focusedButtonIndex == 1,
          ),
        ],
      ),
    );
  }
}

class _SummaryScreen extends StatelessComponent {
  const _SummaryScreen({
    required this.state,
    required this.rebuild,
    required this.padding,
    this.description,
  });

  final MultiScreenFormState state;
  final VoidCallback rebuild;
  final EdgeInsets padding;
  final String? description;

  @override
  Component build(BuildContext context) {
    final configs = state.configurations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 1),
                  for (final config in configs)
                    _SummaryItem(
                      state: state,
                      config: config,
                    ),
                  const SizedBox(height: 1),
                  if (description case String description) ...[
                    const SizedBox(height: 1),
                    Text(
                      description,
                      style: TextStyle(
                        color: Color.defaultColor,
                        fontWeight: FontWeight.dim,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessComponent {
  const _SummaryItem({
    required this.state,
    required this.config,
  });

  final MultiScreenFormState state;
  final FormConfig config;

  @override
  Component build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 1),
      child: Wrap(
        children: [
          Text(
            '• ${config.label}: ',
            style: const TextStyle(color: Color.defaultColor),
          ),
          Text(
            _value,
            style: const TextStyle(color: Color.defaultColor),
          ),
        ],
      ),
    );
  }

  String _getSelectionValue(FormSelectionConfig config) {
    if (config.multiSelect) {
      final options = state.getSelectedOptionsFor(config) ?? {};
      final values = options.map((op) => op.label).join(', ');
      return values.isEmpty ? 'None' : values;
    } else {
      final option = state.getSelectedOptionFor(config);
      if (config.isBoolean) {
        return option == BoolFormConfigOption.enabled ? 'Enabled' : 'Disabled';
      }
      return option?.label ?? 'None';
    }
  }

  String get _value {
    return switch (config) {
      FormInputConfig config => state.getInputFor(config) ?? '',
      FormSelectionConfig config => _getSelectionValue(config),
      _ => throw UnimplementedError(
        'Missing implementation for config: $config',
      ),
    };
  }
}
