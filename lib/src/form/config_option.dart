/// A [FormConfig] option.
abstract class FormConfigOption {
  /// UI visible label for this option.
  String get label;
}

/// [FormConfigOption] that can either be [enabled] or [disabled].
enum BoolFormConfigOption implements FormConfigOption {
  enabled('Enabled'),
  disabled('Disabled')
  ;

  const BoolFormConfigOption(this.label);

  @override
  final String label;
}
