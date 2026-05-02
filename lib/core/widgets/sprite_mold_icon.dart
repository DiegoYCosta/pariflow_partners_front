part of '../../app/app.dart';

enum _SpriteMoldState { base, selected }

extension on _SpriteMoldState {
  String get token => switch (this) {
    _SpriteMoldState.base => 'base',
    _SpriteMoldState.selected => 'selected',
  };
}

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

extension on _SpriteMold {
  String get token => switch (this) {
    _SpriteMold.home => 'home',
    _SpriteMold.company => 'company',
    _SpriteMold.document => 'document',
    _SpriteMold.people => 'people',
    _SpriteMold.network => 'network',
    _SpriteMold.analytics => 'analytics',
    _SpriteMold.calendar => 'calendar',
    _SpriteMold.notification => 'notification',
    _SpriteMold.security => 'security',
    _SpriteMold.settings => 'settings',
  };

  String command(_SpriteMoldState state) => 'mold.$token.${state.token}';
}

class _SpriteMoldRef {
  const _SpriteMoldRef({required this.mold, required this.state});

  final _SpriteMold mold;
  final _SpriteMoldState state;

  String get command => mold.command(state);

  factory _SpriteMoldRef.parse(String command) {
    final normalized = command.trim().toLowerCase();
    final parts = normalized.split('.');
    if (parts.length != 3 || parts.first != 'mold') {
      throw FormatException(
        'Use o formato mold.<nome>.<estado>. Recebido: $command',
      );
    }

    return _SpriteMoldRef(
      mold: _spriteMoldFromToken(parts[1]),
      state: _spriteMoldStateFromToken(parts[2]),
    );
  }
}

class _SpriteMoldCommands {
  const _SpriteMoldCommands._();

  static const String home = 'mold.home.base';
  static const String homeSelected = 'mold.home.selected';
  static const String company = 'mold.company.base';
  static const String companySelected = 'mold.company.selected';
  static const String document = 'mold.document.base';
  static const String documentSelected = 'mold.document.selected';
  static const String people = 'mold.people.base';
  static const String peopleSelected = 'mold.people.selected';
  static const String network = 'mold.network.base';
  static const String networkSelected = 'mold.network.selected';
  static const String analytics = 'mold.analytics.base';
  static const String analyticsSelected = 'mold.analytics.selected';
  static const String calendar = 'mold.calendar.base';
  static const String calendarSelected = 'mold.calendar.selected';
  static const String notification = 'mold.notification.base';
  static const String notificationSelected = 'mold.notification.selected';
  static const String security = 'mold.security.base';
  static const String securitySelected = 'mold.security.selected';
  static const String settings = 'mold.settings.base';
  static const String settingsSelected = 'mold.settings.selected';
}

class _SpriteMoldIcon extends StatelessWidget {
  const _SpriteMoldIcon({
    super.key,
    required this.mold,
    this.state = _SpriteMoldState.base,
    this.size = 28,
    this.color,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  factory _SpriteMoldIcon.fromCommand(
    String command, {
    Key? key,
    double size = 28,
    String? semanticLabel,
  }) {
    final ref = _SpriteMoldRef.parse(command);
    return _SpriteMoldIcon(
      key: key,
      mold: ref.mold,
      state: ref.state,
      size: size,
      semanticLabel: semanticLabel,
    );
  }

  final _SpriteMold mold;
  final _SpriteMoldState state;
  final double size;
  final Color? color;
  final BoxFit fit;
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
              fit: fit,
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

_SpriteMold _spriteMoldFromToken(String token) {
  return switch (token) {
    'home' || 'inicio' => _SpriteMold.home,
    'company' ||
    'companies' ||
    'empresa' ||
    'empresas' ||
    'cliente' ||
    'clientes' => _SpriteMold.company,
    'document' ||
    'documents' ||
    'doc' ||
    'contract' ||
    'contracts' ||
    'contrato' ||
    'contratos' => _SpriteMold.document,
    'people' ||
    'person' ||
    'pessoa' ||
    'pessoas' ||
    'colaborador' ||
    'colaboradores' ||
    'user' ||
    'users' => _SpriteMold.people,
    'network' || 'graph' || 'teia' || 'relational' => _SpriteMold.network,
    'analytics' ||
    'report' ||
    'reports' ||
    'metric' ||
    'metrics' ||
    'relatorio' ||
    'relatorios' => _SpriteMold.analytics,
    'calendar' || 'agenda' || 'timeline' || 'evento' || 'eventos' =>
      _SpriteMold.calendar,
    'notification' ||
    'notifications' ||
    'bell' ||
    'alert' ||
    'alerts' ||
    'notificacao' ||
    'notificacoes' => _SpriteMold.notification,
    'security' || 'shield' || 'secure' || 'compliance' => _SpriteMold.security,
    'settings' ||
    'setting' ||
    'admin' ||
    'config' ||
    'configuracao' ||
    'configuracoes' => _SpriteMold.settings,
    _ => throw FormatException('Molde desconhecido: $token'),
  };
}

_SpriteMoldState _spriteMoldStateFromToken(String token) {
  return switch (token) {
    'base' || 'default' || 'normal' || 'inactive' || 'off' =>
      _SpriteMoldState.base,
    'selected' || 'active' || 'on' || 'gold' || 'dourado' =>
      _SpriteMoldState.selected,
    _ => throw FormatException('Estado desconhecido: $token'),
  };
}

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
