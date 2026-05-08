part of '../../app/app.dart';

enum _SpriteMoldState { base, selected }

enum _SpriteMold {
  home,
  company,
  document,
  people,
  network,
  analytics,
  calendar,
  notification,
  security,
  settings,
}

class _SpriteMoldIcon extends StatelessWidget {
  const _SpriteMoldIcon({
    required this.mold,
    this.state = _SpriteMoldState.base,
    this.size = 28,
    this.color,
    this.semanticLabel,
  });

  final _SpriteMold mold;
  final _SpriteMoldState state;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final rect = _spriteMoldSourceRect(mold, state);

    return SizedBox.square(
      dimension: size,
      child: FutureBuilder<ui.Image>(
        future: _loadSpriteMoldSheet(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SizedBox.square(dimension: size);
          }

          Widget icon = CustomPaint(
            size: Size.square(size),
            painter: _SpriteMoldPainter(
              image: snapshot.data!,
              sourceRect: rect,
              fit: BoxFit.cover,
            ),
          );

          if (color != null) {
            icon = ColorFiltered(
              colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
              child: icon,
            );
          }

          if (semanticLabel == null) {
            return icon;
          }

          return Semantics(label: semanticLabel, image: true, child: icon);
        },
      ),
    );
  }
}

class _SpriteMoldPainter extends CustomPainter {
  const _SpriteMoldPainter({
    required this.image,
    required this.sourceRect,
    required this.fit,
  });

  final ui.Image image;
  final ui.Rect sourceRect;
  final BoxFit fit;

  @override
  void paint(Canvas canvas, Size size) {
    final fitted = applyBoxFit(fit, sourceRect.size, size);
    final outputRect = Alignment.center.inscribe(
      fitted.destination,
      Offset.zero & size,
    );
    canvas.drawImageRect(
      image,
      sourceRect,
      outputRect,
      Paint()..filterQuality = FilterQuality.high,
    );
  }

  @override
  bool shouldRepaint(covariant _SpriteMoldPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.sourceRect != sourceRect ||
        oldDelegate.fit != fit;
  }
}

Future<ui.Image> _loadSpriteMoldSheet() {
  return _spriteMoldSheetFuture ??= _decodeSpriteMoldSheet();
}

Future<ui.Image> _decodeSpriteMoldSheet() async {
  final data = await rootBundle.load(_spriteMoldSheetAsset);
  final bytes = data.buffer.asUint8List();
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

Future<ui.Image>? _spriteMoldSheetFuture;

ui.Rect _spriteMoldSourceRect(_SpriteMold mold, _SpriteMoldState state) {
  return _spriteMoldRects[(mold, state)]!;
}

const Map<(_SpriteMold, _SpriteMoldState), ui.Rect> _spriteMoldRects = {
  (_SpriteMold.home, _SpriteMoldState.base): ui.Rect.fromLTWH(
    114,
    122,
    164,
    182,
  ),
  (_SpriteMold.home, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    317,
    122,
    164,
    182,
  ),
  (_SpriteMold.company, _SpriteMoldState.base): ui.Rect.fromLTWH(
    549,
    120,
    186,
    184,
  ),
  (_SpriteMold.company, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    736,
    120,
    186,
    184,
  ),
  (_SpriteMold.document, _SpriteMoldState.base): ui.Rect.fromLTWH(
    1035,
    118,
    167,
    184,
  ),
  (_SpriteMold.document, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    1220,
    118,
    167,
    184,
  ),
  (_SpriteMold.people, _SpriteMoldState.base): ui.Rect.fromLTWH(
    122,
    349,
    194,
    167,
  ),
  (_SpriteMold.people, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    337,
    349,
    194,
    167,
  ),
  (_SpriteMold.network, _SpriteMoldState.base): ui.Rect.fromLTWH(
    553,
    341,
    179,
    188,
  ),
  (_SpriteMold.network, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    738,
    341,
    179,
    188,
  ),
  (_SpriteMold.analytics, _SpriteMoldState.base): ui.Rect.fromLTWH(
    1023,
    343,
    188,
    187,
  ),
  (_SpriteMold.analytics, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    1212,
    343,
    188,
    187,
  ),
  (_SpriteMold.calendar, _SpriteMoldState.base): ui.Rect.fromLTWH(
    116,
    591,
    180,
    176,
  ),
  (_SpriteMold.calendar, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    332,
    591,
    180,
    176,
  ),
  (_SpriteMold.notification, _SpriteMoldState.base): ui.Rect.fromLTWH(
    560,
    592,
    136,
    176,
  ),
  (_SpriteMold.notification, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    747,
    592,
    136,
    176,
  ),
  (_SpriteMold.security, _SpriteMoldState.base): ui.Rect.fromLTWH(
    1032,
    586,
    163,
    186,
  ),
  (_SpriteMold.security, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    1221,
    586,
    163,
    186,
  ),
  (_SpriteMold.settings, _SpriteMoldState.base): ui.Rect.fromLTWH(
    108,
    820,
    192,
    186,
  ),
  (_SpriteMold.settings, _SpriteMoldState.selected): ui.Rect.fromLTWH(
    330,
    820,
    192,
    186,
  ),
};
