import 'package:nocterm/nocterm.dart';

/// A concrete [ValueListenable] that holds a single value and notifies
/// listeners when the value changes.
class ValueNotifier<T> extends ValueListenable<T> {
  ValueNotifier(this._value);

  T _value;

  @override
  T get value => _value;

  set value(T newValue) {
    if (_value != newValue) {
      _value = newValue;
      notifyListeners();
    }
  }

  final _listeners = <VoidCallback>{};

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    final listeners = _listeners.toList();
    for (final listener in listeners) {
      listener();
    }
  }

  void dispose() {
    _listeners.clear();
  }
}
