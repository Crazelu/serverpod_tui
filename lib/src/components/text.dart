import 'package:nocterm/nocterm.dart' hide TextAlign;
import 'package:nocterm/src/framework/terminal_canvas.dart';

import 'package:nocterm/src/text/text_layout_engine.dart';

/// A run of text with a single style with
/// leading and trailing whitespaces removed for lines after the first line.
class ServerpodTuiText extends SingleChildRenderObjectComponent {
  const ServerpodTuiText(
    this.data, {
    super.key,
    this.style,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.textAlign = TextAlign.left,
    this.maxLines,
  });

  final String data;
  final TextStyle? style;
  final bool softWrap;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final int? maxLines;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderText(
      text: data,
      style: style,
      softWrap: softWrap,
      overflow: overflow,
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderText renderObject) {
    renderObject
      ..text = data
      ..style = style
      ..softWrap = softWrap
      ..overflow = overflow
      ..textAlign = textAlign
      ..maxLines = maxLines;
  }
}

/// Render object for displaying text
class RenderText extends RenderObject with Selectable {
  RenderText({
    required String text,
    TextStyle? style,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.clip,
    TextAlign textAlign = TextAlign.left,
    int? maxLines,
  }) : _text = text,
       _style = style,
       _softWrap = softWrap,
       _overflow = overflow,
       _textAlign = textAlign,
       _maxLines = maxLines;

  String _text;
  String get text => _text;
  set text(String value) {
    if (_text == value) return;
    _text = value;
    markNeedsLayout();
  }

  TextStyle? _style;
  TextStyle? get style => _style;
  set style(TextStyle? value) {
    if (_style == value) return;
    _style = value;
    markNeedsPaint();
  }

  bool _softWrap;
  bool get softWrap => _softWrap;
  set softWrap(bool value) {
    if (_softWrap == value) return;
    _softWrap = value;
    markNeedsLayout();
  }

  TextOverflow _overflow;
  TextOverflow get overflow => _overflow;
  set overflow(TextOverflow value) {
    if (_overflow == value) return;
    _overflow = value;
    markNeedsLayout();
  }

  TextAlign _textAlign;
  TextAlign get textAlign => _textAlign;
  set textAlign(TextAlign value) {
    if (_textAlign == value) return;
    _textAlign = value;
    markNeedsPaint();
  }

  int? _maxLines;
  int? get maxLines => _maxLines;
  set maxLines(int? value) {
    if (_maxLines == value) return;
    _maxLines = value;
    markNeedsLayout();
  }

  TextLayoutResult? _layoutResult;

  @override
  String get selectableText => _text;

  @override
  TextLayoutResult? get selectableLayout => _layoutResult;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  void performLayout() {
    // For text alignment to work properly, we need to use the actual constraint width
    // When in a Column without stretch, we get infinite width, so we use intrinsic width
    final maxWidth = constraints.maxWidth.isFinite
        ? constraints.maxWidth.toInt()
        : double.maxFinite.toInt();

    // Debug: print constraint info
    // print('RenderText layout: text="$_text", constraints=$constraints, maxWidth=$maxWidth');

    final config = TextLayoutConfig(
      softWrap: _softWrap,
      overflow: _overflow,
      textAlign: _textAlign,
      maxLines: _maxLines,
      maxWidth: maxWidth,
    );

    _layoutResult = TextLayoutEngine.layout(_text, config);

    size = constraints.constrain(
      Size(
        _layoutResult!.actualWidth.toDouble(),
        _layoutResult!.actualHeight.toDouble(),
      ),
    );
  }

  @override
  void paint(TerminalCanvas canvas, Offset offset) {
    super.paint(canvas, offset);

    if (_layoutResult == null) return;

    final lines = _layoutResult!.lines;
    // Use the actual size width for alignment, not the constraint
    // The size has been constrained during layout
    final alignmentWidth = size.width.toInt();
    final style = _style;

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Check if this is the last line of a paragraph for justification
      bool isLastLine = i == lines.length - 1;
      if (i < lines.length - 1) {
        // Check if next line starts a new paragraph (was preceded by newline)
        // This is a simplification - proper implementation would track paragraph boundaries
        isLastLine = false;
      }

      String displayLine = line;

      // Remove leading and trailing whitespace
      if (i != 0) {
        displayLine = displayLine.trim();
      }

      // Apply justification if needed
      if (_textAlign == TextAlign.justify && !isLastLine) {
        displayLine = TextLayoutEngine.justifyLine(
          line,
          alignmentWidth,
          isLastLine: isLastLine,
        );
      }

      // Calculate horizontal offset based on text alignment
      final xOffset =
          offset.dx +
          TextLayoutEngine.calculateAlignmentOffset(
            displayLine,
            alignmentWidth,
            _textAlign,
          );

      // Apply clipping if needed
      if (_overflow == TextOverflow.clip && constraints.maxWidth.isFinite) {
        // The TextLayoutEngine already handles truncation, so we just paint what it gave us
        // But we might need to clip at the canvas level for safety
      }

      // Use selection-aware painting if there is an active selection
      if (hasSelection) {
        paintTextWithSelection(
          canvas,
          Offset(xOffset, offset.dy + i),
          displayLine,
          style,
          i,
        );
      } else {
        canvas.drawText(
          Offset(xOffset, offset.dy + i),
          displayLine,
          style: _style,
        );
      }
    }
  }
}
