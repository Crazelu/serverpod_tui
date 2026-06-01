import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/value_notifier.dart';

/// A [TextEditingController] that validates its text on every change and
/// exposes the validation result via an [error] notifier.
///
/// Provide an optional [validator] function. It receives the current text and
/// returns an error message string if the value is invalid, or `null` if valid.
class ValidatingTextController extends TextEditingController {
  ValidatingTextController({
    super.text,
    String? Function(String)? validator,
  }) : _validator = validator,
       _errorNotifier = ValueNotifier<String?>(null) {
    addListener(_onTextChanged);
  }

  String? Function(String)? _validator;
  final ValueNotifier<String?> _errorNotifier;

  /// A [ValueListenable] that emits error messages (or `null`) as the
  /// text changes.
  ValueListenable<String?> get error => _errorNotifier;

  /// Replaces the validator function. Runs validation immediately.
  void setValidator(String? Function(String)? validator) {
    _validator = validator;
    _validate();
  }

  void _onTextChanged() {
    _validate();
  }

  void _validate() {
    final validator = _validator;
    if (validator == null) return;
    _errorNotifier.value = validator(text);
  }

  @override
  void dispose() {
    removeListener(_onTextChanged);
    _errorNotifier.dispose();
    super.dispose();
  }
}
