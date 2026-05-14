import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' show ImageFilter;
import 'dart:ui' as ui;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../features/auth/auth_gate.dart';
import '../firebase_options.dart';
import '../shared/infrastructure/visual_identity_local_store.dart';
import '../shared/models/visual_identity.dart';
import '../widgets/high_tech_light_waves.dart';
import 'focus_board_tab_launcher.dart';

part '../core/widgets/primitives.dart';
part '../core/widgets/sprite_mold_icon.dart';
part '../core/widgets/entity_visual_identity.dart';
part '../shared/models/attachment_record.dart';
part '../shared/models/entity_crud_snapshots.dart';
part '../shared/models/network_graph_payload.dart';
part '../shared/models/sensitive_note_tag.dart';
part '../shared/models/viewer_access.dart';
part '../core/widgets/master_detail_workspace.dart';
part '../core/widgets/entity_crud_actions.dart';
part '../shared/infrastructure/entity_workspace_runtime_metadata.dart';
part '../shared/infrastructure/entity_workspace_api_data.dart';
part '../features/companies/companies_feature.dart';
part '../features/client_companies/client_companies_feature.dart';
part '../features/contracts/contracts_feature.dart';
part '../features/people/people_feature.dart';
part '../features/people/infrastructure/people_api_data.dart';
part '../features/focus_board/focus_board_feature.dart';
part '../features/timeline/timeline_feature.dart';
part '../features/reports/reports_api_data.dart';
part '../features/home/home_dashboard_api_data.dart';
part 'shell/shell_variant.dart';
part 'shell/shell_feature_flags.dart';
part 'shell/legacy_shell.dart';
part 'shell/crm_shell.dart';
part 'shell/layout_preview_shell.dart';
part '../features/home/home_feature.dart';
part '../features/network/application/network_filter_state.dart';
part '../features/network/infrastructure/network_api_data.dart';
part '../features/network/presentation/network_workspace.dart';

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
const double _workspaceHeaderInlineMinWidth = 980;
const double _workspaceMasterDetailInlineMinWidth = 980;
const double _workspaceCompactMasterDetailInlineMinWidth = 840;
const _focusBoardStandaloneRoute = '/focus-board';
const _legalRoute = '/legal';

Future<void> initializePariFlowFirebase() async {
  if (previewFirebaseIdToken != null) {
    return;
  }

  if (!DefaultFirebaseOptions.isConfiguredForCurrentPlatform ||
      Firebase.apps.isNotEmpty) {
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

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
      home: const AuthGate(
        brand: AuthGateBrandConfig(
          paperColor: _paperColor,
          mutedColor: _mutedColor,
          tealColor: _tealColor,
          deepTealColor: _deepTealColor,
          bannerWebAsset: _crmBannerWebAsset,
          bannerMobileAsset: _crmBannerMobileAsset,
          logoSymbolAsset: _crmLogoSymbolAsset,
        ),
        child: LayoutPreviewPage(),
      ),
      routes: {
        _legalRoute: (_) => const _LegalTermsPage(),
        _focusBoardStandaloneRoute: (_) => const AuthGate(
          brand: AuthGateBrandConfig(
            paperColor: _paperColor,
            mutedColor: _mutedColor,
            tealColor: _tealColor,
            deepTealColor: _deepTealColor,
            bannerWebAsset: _crmBannerWebAsset,
            bannerMobileAsset: _crmBannerMobileAsset,
            logoSymbolAsset: _crmLogoSymbolAsset,
          ),
          child: _FocusBoardStandalonePage(),
        ),
      },
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            if (_shouldShowLocalPreviewBanner) const _LocalPreviewBanner(),
          ],
        );
      },
    );
  }
}

bool get _shouldShowLocalPreviewBanner {
  if (!kIsWeb) {
    return false;
  }

  final host = Uri.base.host.toLowerCase();
  return host == 'localhost' || host == '127.0.0.1';
}

class _LegalTermsPage extends StatefulWidget {
  const _LegalTermsPage();

  @override
  State<_LegalTermsPage> createState() => _LegalTermsPageState();
}

class _LegalTermsPageState extends State<_LegalTermsPage> {
  bool _acceptedTerms = false;
  bool _rejectedTerms = false;
  bool _acceptedPrivacy = false;
  bool _rejectedPrivacy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvasColor,
      appBar: AppBar(
        title: const Text('Termos e privacidade'),
        backgroundColor: _paperColor,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegalSection(
                    title: 'Termos de uso',
                    paragraphs: const [
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. O uso do aplicativo depende de autenticacao valida, vinculo autorizado a empresa e respeito aos perfis de acesso concedidos.',
                      'Nullam facilisis, sapien vel porta gravida, neque arcu tincidunt risus, vitae luctus erat mi sed libero. O usuario deve manter dados de contato atualizados e nao compartilhar credenciais.',
                      'Suspendisse potenti. Operacoes sensiveis podem exigir validacao adicional e registro de auditoria para preservar integridade operacional.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LegalAgreementBox(
                    acceptLabel: 'Concordo com os termos de uso',
                    rejectLabel: 'Nao concordo com os termos de uso',
                    accepted: _acceptedTerms,
                    rejected: _rejectedTerms,
                    onAccepted: (value) => setState(() {
                      _acceptedTerms = value;
                      if (value) {
                        _rejectedTerms = false;
                      }
                    }),
                    onRejected: (value) => setState(() {
                      _rejectedTerms = value;
                      if (value) {
                        _acceptedTerms = false;
                      }
                    }),
                  ),
                  const SizedBox(height: 24),
                  _LegalSection(
                    title: 'Politica de privacidade',
                    paragraphs: const [
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Dados pessoais e empresariais sao tratados somente para controle operacional, seguranca, auditoria e suporte do servico.',
                      'Integer feugiat justo at velit feugiat, sed gravida nibh porta. Informacoes de empresas nao sao exibidas a solicitantes sem vinculo aprovado.',
                      'Praesent at lectus sed lectus tristique dictum. Registros podem ser mantidos para cumprimento contratual, rastreabilidade e prevencao de uso indevido.',
                    ],
                  ),
                  const SizedBox(height: 12),
                  _LegalAgreementBox(
                    acceptLabel: 'Concordo com a politica de privacidade',
                    rejectLabel: 'Nao concordo com a politica de privacidade',
                    accepted: _acceptedPrivacy,
                    rejected: _rejectedPrivacy,
                    onAccepted: (value) => setState(() {
                      _acceptedPrivacy = value;
                      if (value) {
                        _rejectedPrivacy = false;
                      }
                    }),
                    onRejected: (value) => setState(() {
                      _rejectedPrivacy = value;
                      if (value) {
                        _acceptedPrivacy = false;
                      }
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  const _LegalSection({required this.title, required this.paragraphs});

  final String title;
  final List<String> paragraphs;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _paperColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: _deepTealColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            for (final paragraph in paragraphs) ...[
              Text(paragraph, style: Theme.of(context).textTheme.bodyMedium),
              if (paragraph != paragraphs.last) const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalAgreementBox extends StatelessWidget {
  const _LegalAgreementBox({
    required this.acceptLabel,
    required this.rejectLabel,
    required this.accepted,
    required this.rejected,
    required this.onAccepted,
    required this.onRejected,
  });

  final String acceptLabel;
  final String rejectLabel;
  final bool accepted;
  final bool rejected;
  final ValueChanged<bool> onAccepted;
  final ValueChanged<bool> onRejected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _lineColor),
      ),
      child: Column(
        children: [
          CheckboxListTile(
            value: accepted,
            onChanged: (value) => onAccepted(value == true),
            title: Text(acceptLabel),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const Divider(height: 1, color: _lineColor),
          CheckboxListTile(
            value: rejected,
            onChanged: (value) => onRejected(value == true),
            title: Text(rejectLabel),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

class _LocalPreviewBanner extends StatelessWidget {
  const _LocalPreviewBanner();

  @override
  Widget build(BuildContext context) {
    final apiBaseUrl = defaultApiBaseUrl;
    final isLocalApi = _isLocalHostUri(apiBaseUrl);
    final label = isLocalApi
        ? 'Ambiente local ativo'
        : 'Ambiente local ativo - API online';

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _lineColor),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF231C10).withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: _amberColor.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: _amberColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: _inkColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ambiente local. Deploy publico continua normal.',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: _mutedColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool _isLocalHostUri(String value) {
  final uri = Uri.tryParse(value);
  final host = uri?.host.toLowerCase() ?? '';
  return host == 'localhost' || host == '127.0.0.1';
}
