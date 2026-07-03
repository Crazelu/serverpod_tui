import 'package:intl/intl.dart';
import 'package:nocterm/nocterm.dart';
import 'package:serverpod_tui/src/alert_message.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

final _timeFormat = DateFormat('HH:mm:ss.SSS');

/// Renders an [AlertMessage] as a pinned, log-styled line: an `alert` marker
/// and timestamp aligned with the log entries' level/time columns, followed by
/// the message (with its code emphasised) and `C Copy` / `Esc Dismiss` hints.
///
/// The message is left-truncated (keeping the trailing code) when it doesn't
/// fit, so the line never wraps. Place it where it should appear - e.g. pinned
/// at the bottom of a log panel.
class AlertLine extends StatelessComponent {
  const AlertLine({
    super.key,
    required this.alert,
    required this.onCopy,
    required this.onDismiss,
    this.time,
    this.copied = false,
  });

  final AlertMessage alert;

  /// When the alert was raised; rendered in the same column as log timestamps.
  /// Omitted when null.
  final DateTime? time;

  /// When true, the copy hint shows a `✓ Copied` confirmation instead of
  /// `C Copy`.
  final bool copied;

  /// Invoked when the copy hint is clicked.
  final VoidCallback onCopy;

  /// Invoked when the dismiss hint is clicked.
  final VoidCallback onDismiss;

  @override
  Component build(BuildContext context) {
    final st = ServerpodTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 'alert' is five characters, matching the log level labels so the
        // timestamp lines up with the log entries' time column.
        Text(
          'alert',
          style: TextStyle(color: st.warningLevel, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 1),
        if (time case final time?) ...[
          Text(
            _timeFormat.format(time.toLocal()),
            style: const TextStyle(fontWeight: FontWeight.dim),
          ),
          const SizedBox(width: 1),
        ],
        // nocterm's Text has no ellipsis/clip, so a line wider than its
        // container wraps. Measure the remaining width and pre-truncate.
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth = constraints.maxWidth.isFinite
                  ? constraints.maxWidth.floor()
                  : alert.displayText.length + 20;
              return Row(children: _messageSpans(st, maxWidth));
            },
          ),
        ),
      ],
    );
  }

  /// Builds the message and hint spans, fitted to [maxWidth] columns. The
  /// message is truncated from the left so the trailing code stays visible,
  /// and the code (if any) is emphasised.
  List<Component> _messageSpans(ServerpodThemeData st, int maxWidth) {
    final code = alert.copyText;

    final keyStyle = TextStyle(
      color: st.activationKey,
      fontWeight: FontWeight.bold,
    );
    final labelStyle = TextStyle(color: st.brightText);
    final copiedStyle = TextStyle(
      color: st.success,
      fontWeight: FontWeight.bold,
    );

    // Each hint is a run of styled spans plus its tap handler, rendered as one
    // clickable group. Trailing spaces after Copy separate it from Dismiss. The
    // copy hint becomes `✓ Copied` (matching the log's green success mark) for
    // a moment after a copy.
    final copyHint = copied
        ? [('✓', copiedStyle), (' Copied  ', labelStyle)]
        : [('C', keyStyle), (' Copy  ', labelStyle)];
    final hints = <(List<(String, TextStyle)>, VoidCallback)>[
      if (code != null) (copyHint, onCopy),
      ([('Esc', keyStyle), (' Dismiss', labelStyle)], onDismiss),
    ];
    final hintsWidth = hints.fold<int>(
      0,
      (w, hint) => w + hint.$1.fold<int>(0, (w, span) => w + span.$1.length),
    );

    final message = _truncateKeepingTail(
      alert.displayText,
      maxWidth - hintsWidth,
    );

    Text plain(String text) =>
        Text(text, style: TextStyle(color: st.brightText));

    // Emphasise the code where it survives in the (possibly truncated) message.
    final codeStart = code == null ? -1 : message.lastIndexOf(code);
    final messageSpans = codeStart < 0
        ? [plain(message)]
        : [
            plain(message.substring(0, codeStart)),
            Text(
              code!,
              style: TextStyle(color: st.primary, fontWeight: FontWeight.bold),
            ),
            plain(message.substring(codeStart + code.length)),
          ];

    return [
      ...messageSpans,
      Expanded(child: const SizedBox.shrink()),
      for (final (spans, onTap) in hints) _hint(spans, onTap),
    ];
  }

  /// Renders one hint group as a clickable [GestureDetector]. [MainAxisSize.min]
  /// keeps the hit area to the text so only that hint responds to a tap.
  Component _hint(List<(String, TextStyle)> spans, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [for (final (text, style) in spans) Text(text, style: style)],
      ),
    );
  }

  /// Truncates [text] to [width] columns, keeping the tail and prefixing an
  /// ellipsis when it doesn't fit. Returns empty when there is no room.
  static String _truncateKeepingTail(String text, int width) {
    if (width <= 0) return '';
    if (text.length <= width) return text;
    if (width == 1) return '…';
    return '…${text.substring(text.length - (width - 1))}';
  }
}
