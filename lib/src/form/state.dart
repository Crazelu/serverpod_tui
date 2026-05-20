import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';
import 'package:serverpod_tui/src/form/requirement.dart';

/// State for a `Form` component.
class FormState<F extends FormConfig> {
  FormState(this._configValues) {
    _updateState();
  }

  /// Configurations used to initialize this state.
  final List<F> _configValues;

  /// Mutable configurations which gets updated with this state.
  final List<F> configurations = [];

  /// Tracked state for selected [FormConfigOption]s per [FormConfig].
  final Map<F, Set<FormConfigOption>> _selectionState = {};

  /// Tracked state for focused [FormConfigOption] per [FormConfig].
  final Map<F, _FormConfigState> _focusedOptionState = {};

  int _maxFocusedConfigIndex = 0;

  /// Max index of focusable configurations.
  int get maxFocusedConfigIndex => _maxFocusedConfigIndex;

  int _focusedConfigIndex = 0;

  /// Index of the current configuration in focus.
  int get focusedConfigIndex => _focusedConfigIndex;

  /// Updates internal selection and focus states
  /// and removes configurations that do not meet specified requirements.
  void _updateState() {
    configurations.clear();
    for (final config in _configValues) {
      if (_isConfigConstrained(config)) {
        _selectionState.remove(config);
        _focusedOptionState.remove(config);
        continue;
      }
      configurations.add(config);
      _selectionState[config] ??= config.defaultOptions;
      _focusedOptionState[config] ??= _FormConfigState(config);
    }

    _maxFocusedConfigIndex = configurations.length - 1;
  }

  /// Updates the focused [FormConfig] by [delta].
  void updateFocusedConfig(int delta) {
    _focusedConfigIndex += delta;
    if (_focusedConfigIndex > maxFocusedConfigIndex) {
      _focusedConfigIndex = 0;
    } else if (_focusedConfigIndex < 0) {
      _focusedConfigIndex = maxFocusedConfigIndex;
    }
  }

  /// Updates the focused [FormConfigOption] for the focused [FormConfig] by [delta].
  void updateFocusedConfigOption(int delta) {
    final config = configurations[_focusedConfigIndex];
    final configState = _focusedOptionState[config];
    configState?._updateFocusedOption(delta);
  }

  void _updateOptionFor(F config, FormConfigOption option) {
    if (config.multiSelect) {
      final selections = _selectionState[config];
      if (selections != null && selections.contains(option)) {
        _selectionState[config] = selections.difference({option});
      } else {
        _selectionState[config] = {...?selections, option};
      }
    } else {
      _selectionState[config] = {option};
    }
  }

  /// Updates the selected [FormConfigOption] for the focused [FormConfig].
  void selectConfigOption() {
    final config = configurations[_focusedConfigIndex];
    final configState = _focusedOptionState[config];
    if (configState == null) return;

    // Invert the focused option for config with boolean options
    // to select correct option since the UI only displays 'Enabled' option
    if (config.isBoolean) {
      final selectedOption = getSelectedOptionFor(config);
      final unselectedOptionIndex = config.options.indexWhere(
        (e) => e != selectedOption,
      );
      configState._focusedOptionIndex = unselectedOptionIndex;
    }

    final focusedOptionIndex = configState.focusedOptionIndex;
    final newOption = config.options[focusedOptionIndex];
    _updateOptionFor(config, newOption);
    _evaluateRequirements();
    _updateState();
  }

  void updateSelectedOption(F config, FormConfigOption option) {
    _updateOptionFor(config, option);
    _focusedConfigIndex = configurations.indexOf(config);
    final configState = _focusedOptionState[config];
    configState?._focusedOptionIndex = config.options.indexOf(option);
    _evaluateRequirements();
    _updateState();
  }

  /// Evaluates requirements defined for each [FormConfig].
  void _evaluateRequirements() {
    for (final config in configurations) {
      if (config.requirements.isEmpty) continue;
      for (final req in config.requirements) {
        final selectedOption = getSelectedOptionFor(req.requiredConfig);
        if (selectedOption != req.requiredConfigOption) {
          _selectionState[config] = {req.disabledOption};
          final configState = _focusedOptionState[config];
          // Update the focused option index to keep UI interaction in sync
          configState?._focusedOptionIndex = config.options.indexOf(
            req.disabledOption,
          );
        }
      }
    }
  }

  /// True when [config] is partially locked because at least one requirement
  /// on another config is not satisfied.
  bool _isConfigConstrained(F config) {
    return config.requirements.any(_isRequirementUnsatisfied);
  }

  /// True when [req] is not satisfied given current selections.
  bool _isRequirementUnsatisfied(FormRequirement req) {
    return getSelectedOptionFor(req.requiredConfig) != req.requiredConfigOption;
  }

  /// Returns the focused option for [config].
  int? getFocusedOptionIndexFor(F config) {
    final state = _focusedOptionState[config];
    return state?._focusedOptionIndex;
  }

  /// Returns the selected [FormConfigOption] for [config].
  /// For multi-select configs, use [getSelectedOptionsFor] instead.
  T? getSelectedOptionFor<T extends FormConfigOption>(FormConfig<T> config) {
    final value = _selectionState[config];
    return value?.firstOrNull as T?;
  }

  /// Returns all selected [FormConfigOption]s for [config].
  Set<T>? getSelectedOptionsFor<T extends FormConfigOption>(
    FormConfig<T> config,
  ) {
    return _selectionState[config]?.cast<T>();
  }

  /// Returns true if [option] is a selected option for [config].
  bool isOptionSelectedForConfig<T extends FormConfigOption>(
    FormConfig<T> config,
    T option,
  ) {
    final value = _selectionState[config];
    return value?.contains(option) ?? false;
  }
}

/// Internal state tracking the focused option for a [FormConfig].
class _FormConfigState<T extends FormConfig> {
  _FormConfigState(this.config) : _maxIndex = config.options.length - 1;

  final T config;
  final int _maxIndex;

  late int _focusedOptionIndex = 0;
  int get focusedOptionIndex => _focusedOptionIndex;

  void _updateFocusedOption(int delta) {
    _focusedOptionIndex += delta;
    if (_focusedOptionIndex > _maxIndex) {
      _focusedOptionIndex = 0;
    } else if (_focusedOptionIndex < 0) {
      _focusedOptionIndex = _maxIndex;
    }
  }
}
