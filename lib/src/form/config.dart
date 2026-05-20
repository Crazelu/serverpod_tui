import 'package:serverpod_tui/src/form/config_option.dart';
import 'package:serverpod_tui/src/form/requirement.dart';

abstract interface class FormConfig<T extends FormConfigOption> {
  /// UI visible label for this config.
  String get label;

  /// Supported config options.
  List<T> get options;

  /// The default config options.
  Set<T> get defaultOptions;

  /// Requirements for other related configs that must be satisfied
  /// for this config to be enabled.
  List<FormRequirement<FormConfigOption, T>> get requirements;

  /// Whether this config supports multi-select options.
  bool get multiSelect;
}

extension FormConfigExtension on FormConfig {
  /// Whether the config has boolean options.
  bool get isBoolean => defaultOptions is Set<BoolFormConfigOption>;
}
