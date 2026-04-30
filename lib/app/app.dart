import 'package:flutter/material.dart';

part '../core/widgets/primitives.dart';
part 'shell/layout_preview_shell.dart';
part '../features/home/home_feature.dart';
part '../features/network/network_presentation.dart';
part '../features/network/network_domain.dart';

const _canvasColor = Color(0xFFF4EFE6);
const _paperColor = Color(0xFFFFFCF7);
const _lineColor = Color(0xFFE3D9CB);
const _inkColor = Color(0xFF182521);
const _mutedColor = Color(0xFF64736D);
const _tealColor = Color(0xFF0F766E);
const _deepTealColor = Color(0xFF143C38);
const _amberColor = Color(0xFFBF6B2D);
const _roseColor = Color(0xFFA35252);
const _slateColor = Color(0xFF536A75);

class PariFlowPartnersApp extends StatelessWidget {
  const PariFlowPartnersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _tealColor,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'PariFlow Partners',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme.copyWith(
          primary: _tealColor,
          onPrimary: Colors.white,
          secondary: _amberColor,
          onSecondary: Colors.white,
          surface: _paperColor,
          onSurface: _inkColor,
          outline: const Color(0xFF9AA9A2),
        ),
        scaffoldBackgroundColor: _canvasColor,
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.1,
            height: 1.05,
            color: _inkColor,
          ),
          headlineSmall: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: _inkColor,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _inkColor,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _inkColor,
          ),
          bodyLarge: TextStyle(fontSize: 16, height: 1.55, color: _inkColor),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: _inkColor),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _inkColor,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
            color: _inkColor,
          ),
        ),
      ),
      home: const LayoutPreviewPage(),
    );
  }
}
