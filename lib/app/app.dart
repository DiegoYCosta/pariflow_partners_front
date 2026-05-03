import 'dart:async';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/high_tech_light_waves.dart';

part '../core/widgets/primitives.dart';
part '../core/widgets/sprite_mold_icon.dart';
part '../core/widgets/master_detail_workspace.dart';
part '../shared/models/attachment_record.dart';
part '../shared/models/network_graph_payload.dart';
part '../shared/models/sensitive_note_tag.dart';
part '../shared/models/viewer_access.dart';
part '../features/companies/companies_feature.dart';
part '../features/companies/infrastructure/companies_mock_data.dart';
part '../features/client_companies/client_companies_feature.dart';
part '../features/client_companies/infrastructure/client_companies_mock_data.dart';
part '../features/contracts/contracts_feature.dart';
part '../features/contracts/infrastructure/contracts_mock_data.dart';
part '../features/people/people_feature.dart';
part '../features/people/infrastructure/people_mock_data.dart';
part 'shell/shell_variant.dart';
part 'shell/shell_feature_flags.dart';
part 'shell/legacy_shell.dart';
part 'shell/crm_shell.dart';
part 'shell/layout_preview_shell.dart';
part '../features/home/home_feature.dart';
part '../features/network/application/network_filter_state.dart';
part '../features/network/domain/network_entities.dart';
part '../features/network/domain/network_graph_engine.dart';
part '../features/network/infrastructure/network_graph_payload_preview.dart';
part '../features/network/infrastructure/network_mock_graph.dart';
part '../features/network/presentation/network_workspace.dart';
part '../features/network/presentation/network_canvas.dart';
part '../features/network/presentation/network_detail.dart';
part '../features/network/presentation/network_widgets.dart';
part '../features/network/presentation/painters/network_link_painter.dart';

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
const _crmBannerWebAsset = 'assets/images/banner_web_clean.webp';
const _crmBannerMobileAsset = 'assets/images/banner_mobile_clean.webp';
const _crmBackgroundAsset = 'assets/images/background_abstract_warm.webp';
const _crmLogoSymbolAsset = 'assets/images/logo_transparent.webp';
const _crmLogoWordmarkAsset = 'assets/images/PFP.webp';
const _crmLogoBackdropAsset = 'assets/images/background-logo.webp';
const _spriteMoldSheetAsset = 'assets/images/Icones.webp';

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
