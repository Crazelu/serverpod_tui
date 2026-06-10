## 0.2.1

- **FEAT**: Added alert messages. `TuiAppStateHolder.showAlert` pins a copyable alert (e.g. an email verification code) in the log panel via `AlertLine`; a `<...>`-marked segment is copied to the clipboard and re-copied with `C`, and `Esc` dismisses it.
- **FEAT**: Clipboard copies now use the native platform tool (`pbcopy`/`clip`/`wl-copy`/`xclip`/`xsel`) in addition to OSC 52, so copying works in terminals without OSC 52 support (e.g. macOS Terminal.app).

## 0.2.0

- **BREAKING** **FEAT**: Added support for optional description for form configurations.
- **FEAT**: Improved form UI
- **CHORE**: Replaced `serverpod_shared` dependency with `serverpod_logging`.

## 0.1.0-rc.6

- **FIX**: Fixed buttons activating on Ctrl, Alt, and Meta key combinations so app-level shortcuts reach their handlers.
- **FIX**: Fixed the Ctrl-C hint toggling remounting the whole app subtree and resetting its state.
- **FIX**: FFixed text selection getting swallowed up on Windows.

## 0.1.0-rc.5

- **FEAT**: Added support for form input validation and suffix text.

## 0.1.0-rc.4

- **FEAT**: Updated Ctrl-C behavior to match common CLI tools: copies the current selection if there is one, otherwise a first press arms exit and a second press within two seconds exits gracefully.

## 0.1.0-rc.3

- **CHORE**: Lowered minimum Dart SDK to 3.10.3

## 0.1.0-rc.2

- **FIX**: Fixed terminal restoration on Windows

## 0.1.0-rc.1

- Initial version.
