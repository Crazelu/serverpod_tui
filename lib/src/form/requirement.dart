import 'package:serverpod_tui/src/form/config.dart';
import 'package:serverpod_tui/src/form/config_option.dart';

/// Represents a requirement for [FormConfig].
class FormRequirement<R extends FormConfigOption, D extends FormConfigOption> {
  const FormRequirement({
    required this.requiredConfig,
    required this.requiredConfigOption,
    required this.disabledOption,
  });

  /// The required config.
  /// The selected option for this config
  /// must be [requiredConfigOption] for the requirement to be satisfied.
  final FormConfig<R> requiredConfig;

  /// The option for [requiredConfig] that must be satisified.
  final R requiredConfigOption;

  /// Option to set if this requirement is not satisfied.
  final D disabledOption;
}
