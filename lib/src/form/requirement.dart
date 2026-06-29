import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';

/// Represents a requirement for [FormConfig].
class FormRequirement<T extends FormConfigOption> {
  const FormRequirement({
    required this.config,
    required this.configOptions,
  });

  /// The required config.
  /// The selected option for this config
  /// must be in [configOptions] for the requirement to be satisfied.
  final FormConfig<T> config;

  /// The options for [config] that must be satisified.
  final Set<T> configOptions;
}
