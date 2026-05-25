import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/components/checkbox.dart';
import 'package:serverpod_tui/src/components/radio_button.dart';
import 'package:serverpod_tui/src/components/wrap.dart';
import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';
import 'package:serverpod_tui/src/form/state.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

/// A form component that renders text input,
/// single select, boolean and multi-select options.
class Form extends StatelessComponent {
  const Form({
    super.key,
    required this.state,
    required this.scrollController,
    required this.rebuild,
    this.spacing = 1,
    this.padding = const EdgeInsets.symmetric(horizontal: 1),
  });

  final FormState state;
  final ScrollController scrollController;
  final VoidCallback rebuild;
  final double spacing;
  final EdgeInsets padding;

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);

    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: SingleChildScrollView(
        controller: scrollController,
        child: Padding(padding: padding, child: _buildConfigurations(theme)),
      ),
    );
  }

  Component _buildConfigurations(ServerpodThemeData theme) {
    final configurations = state.configurations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final config in configurations.indexed) ...[
          _buildConfiguration(
            theme: theme,
            config: config.$2,
            configFocused: config.$1 == state.focusedConfigIndex,
          ),
          SizedBox(height: spacing),
        ],
      ],
    );
  }

  Component _buildConfiguration({
    required ServerpodThemeData theme,
    required FormConfig config,
    required bool configFocused,
  }) {
    if (config is FormInputConfig) {
      return _buildInputConfiguration(
        theme: theme,
        config: config,
        configFocused: configFocused,
      );
    }

    if (config is! FormSelectionConfig) {
      throw UnsupportedError('Unsupported configuration: $config');
    }

    if (config.multiSelect) {
      return _buildMultiSelectConfiguration(
        theme: theme,
        config: config,
        configFocused: configFocused,
      );
    }

    if (config.isBoolean) {
      return _buildBooleanConfiguration(
        theme: theme,
        config: config,
        configFocused: configFocused,
      );
    }

    return _buildSingleSelectConfiguration(
      theme: theme,
      config: config,
      configFocused: configFocused,
    );
  }

  Component _buildInputConfiguration({
    required ServerpodThemeData theme,
    required FormInputConfig config,
    required bool configFocused,
  }) {
    final controller = state.getInputControllerFor(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: const TextStyle(
            color: Color.defaultColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        GestureDetector(
          onTap: () {
            state.requestFocus(config);
            rebuild();
          },
          child: TextField(
            maxLines: config.maxLines,
            width: config.width,
            controller: controller,
            focused: configFocused,
            cursorBlinkRate: Duration(milliseconds: 700),
            decoration: InputDecoration(
              border: BoxBorder.all(),
              focusedBorder: BoxBorder.all(),
            ),
            onKeyEvent: (event) {
              switch (event.logicalKey) {
                case LogicalKey.arrowUp:
                  state.updateFocusedConfig(-1);
                  if (state.focusedConfigIndex == state.maxFocusedConfigIndex) {
                    scrollController.scrollToEnd();
                  } else {
                    scrollController.scrollUp(3);
                  }
                  rebuild();
                  return true;
                case LogicalKey.arrowDown:
                  state.updateFocusedConfig(1);
                  if (state.focusedConfigIndex == 0) {
                    scrollController.scrollToStart();
                  } else {
                    scrollController.scrollDown(3);
                  }
                  rebuild();
                  return true;
              }
              return false;
            },
          ),
        ),
      ],
    );
  }

  Component _buildSingleSelectConfiguration({
    required ServerpodThemeData theme,
    required FormSelectionConfig config,
    required bool configFocused,
  }) {
    final selectedOption = state.getSelectedOptionFor(config);
    final focusedOptionIndex = state.getFocusedOptionIndexFor(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: const TextStyle(
            color: Color.defaultColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          spacing: 2,
          children: [
            for (final option in config.options.indexed)
              _buildConfigurationOption(
                theme,
                option.$2,
                focused: configFocused && focusedOptionIndex == option.$1,
                selected: selectedOption == option.$2,
                onTap: () {
                  state.updateSelectedOption(config, option.$2);
                  rebuild();
                },
              ),
          ],
        ),
      ],
    );
  }

  Component _buildBooleanConfiguration({
    required ServerpodThemeData theme,
    required FormSelectionConfig config,
    required bool configFocused,
  }) {
    final selectedOption =
        state.getSelectedOptionFor(config) as BoolFormConfigOption?;
    const defaultOption = BoolFormConfigOption.enabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: const TextStyle(
            color: Color.defaultColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildMultiSelectOption(
          theme,
          BoolFormConfigOption.enabled,
          focused: configFocused,
          selected: selectedOption == defaultOption,
          onTap: () {
            final newOption = selectedOption == BoolFormConfigOption.enabled
                ? BoolFormConfigOption.disabled
                : BoolFormConfigOption.enabled;
            state.updateSelectedOption(config, newOption);
            rebuild();
          },
        ),
      ],
    );
  }

  Component _buildMultiSelectConfiguration({
    required ServerpodThemeData theme,
    required FormSelectionConfig config,
    required bool configFocused,
  }) {
    final selectedOptions = state.getSelectedOptionsFor(config) ?? {};
    final focusedOptionIndex = state.getFocusedOptionIndexFor(config);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          config.label,
          style: const TextStyle(
            color: Color.defaultColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        Wrap(
          spacing: 2,
          children: [
            for (final option in config.options.indexed)
              _buildMultiSelectOption(
                theme,
                option.$2,
                focused: configFocused && focusedOptionIndex == option.$1,
                selected: selectedOptions.contains(option.$2),
                onTap: () {
                  state.updateSelectedOption(config, option.$2);
                  rebuild();
                },
              ),
          ],
        ),
      ],
    );
  }

  Component _buildConfigurationOption(
    ServerpodThemeData theme,
    FormConfigOption option, {
    required bool focused,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: RadioButton(
        label: option.label,
        value: selected,
        focused: focused,
      ),
    );
  }

  Component _buildMultiSelectOption(
    ServerpodThemeData theme,
    FormConfigOption option, {
    required bool focused,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Checkbox(
        label: option.label,
        value: selected,
        focused: focused,
      ),
    );
  }
}
