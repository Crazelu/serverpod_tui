import 'package:nocterm/nocterm.dart';
// ignore: implementation_imports
import 'package:nocterm/src/components/render_ascii_text.dart'
    show AsciiLayoutEngine;
import 'package:serverpod_tui/src/components/bordered_box.dart';
import 'package:serverpod_tui/src/components/shimmer.dart';
import 'package:serverpod_tui/src/components/unconstrained_box.dart';
import 'package:serverpod_tui/src/serverpod_theme.dart';

class Logo extends StatefulComponent {
  const Logo({super.key, required this.text});

  final String text;

  @override
  State<Logo> createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  static const _chromeMargin = 6;

  late final _asciiSize = _textSize;

  Size get _textSize {
    final result = AsciiLayoutEngine.layout(
      component.text,
      const AsciiLayoutConfig(font: AsciiFont.standard),
    );
    return Size(result.width.toDouble(), result.height.toDouble());
  }

  @override
  Component build(BuildContext context) {
    final theme = ServerpodTheme.of(context);
    final baseColor = theme.primary;
    final highlightColor = theme.brightText;

    return LayoutBuilder(
      builder: (context, constraints) {
        final neededWidth = _asciiSize.width + _chromeMargin;
        final neededHeight = (_asciiSize.height) + _chromeMargin;
        final fits =
            constraints.maxWidth >= neededWidth &&
            constraints.maxHeight >= neededHeight;

        final child = fits
            ? _buildFancySplash(
                baseColor: baseColor,
                highlightColor: highlightColor,
              )
            : _buildPlainSplash(
                baseColor: baseColor,
                highlightColor: highlightColor,
              );

        return Center(
          child: BorderedBox(
            backgroundColor: Color.defaultColor,
            child: child,
          ),
        );
      },
    );
  }

  Component _buildFancySplash({
    required Color baseColor,
    required Color highlightColor,
  }) {
    return Container(
      margin: const EdgeInsets.all(2),
      child: Shimmer(
        highlightColor: highlightColor,
        baseColor: baseColor,
        child: UnconstrainedBox(
          child: AsciiText(
            component.text,
            font: AsciiFont.standard,
            style: TextStyle(color: baseColor),
          ),
        ),
      ),
    );
  }

  Component _buildPlainSplash({
    required Color baseColor,
    required Color highlightColor,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      child: Shimmer(
        highlightColor: highlightColor,
        baseColor: baseColor,
        child: Text(
          component.text,
          style: TextStyle(color: baseColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
