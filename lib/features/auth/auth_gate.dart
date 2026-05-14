import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/api/api_client.dart';
import '../../firebase_options.dart';

class AuthGateBrandConfig {
  const AuthGateBrandConfig({
    required this.paperColor,
    required this.mutedColor,
    required this.tealColor,
    required this.deepTealColor,
    required this.bannerWebAsset,
    required this.bannerMobileAsset,
    required this.logoSymbolAsset,
  });

  final Color paperColor;
  final Color mutedColor;
  final Color tealColor;
  final Color deepTealColor;
  final String bannerWebAsset;
  final String bannerMobileAsset;
  final String logoSymbolAsset;
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.child, required this.brand});

  final Widget child;
  final AuthGateBrandConfig brand;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _previewSessionUnlocked = false;

  @override
  Widget build(BuildContext context) {
    final firebaseAvailable =
        DefaultFirebaseOptions.isConfiguredForCurrentPlatform &&
        Firebase.apps.isNotEmpty;

    if (!firebaseAvailable) {
      if (_isPreviewAuthEnabled) {
        return widget.child;
      }

      return _AuthUnavailableScreen(brand: widget.brand);
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _AuthLoadingScreen(brand: widget.brand);
        }

        if (_previewSessionUnlocked) {
          return widget.child;
        }

        final user = snapshot.data;
        if (user != null) {
          return _BackendSessionGate(brand: widget.brand, child: widget.child);
        }

        return _FirebaseLoginScreen(
          brand: widget.brand,
          onPreviewSession: _isPreviewAuthEnabled
              ? () {
                  setState(() {
                    _previewSessionUnlocked = true;
                  });
                }
              : null,
        );
      },
    );
  }
}

class _BackendSessionGate extends StatefulWidget {
  const _BackendSessionGate({required this.child, required this.brand});

  final Widget child;
  final AuthGateBrandConfig brand;

  @override
  State<_BackendSessionGate> createState() => _BackendSessionGateState();
}

class _BackendSessionGateState extends State<_BackendSessionGate> {
  late Future<SessionSnapshot> _sessionLoad;
  bool _contextConfirmed = false;

  @override
  void initState() {
    super.initState();
    _sessionLoad = ApiClient().ensureDevelopmentSession();
  }

  void _retry() {
    setState(() {
      _contextConfirmed = false;
      _sessionLoad = ApiClient().reloadSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SessionSnapshot>(
      future: _sessionLoad,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _AuthLoadingScreen(brand: widget.brand);
        }

        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error! as ApiException).message
              : 'Nao foi possivel validar a sessao interna.';
          return _SessionUnavailableScreen(
            brand: widget.brand,
            message: message,
            onRetry: _retry,
          );
        }

        final session = snapshot.data;
        if (session == null) {
          return _SessionUnavailableScreen(
            brand: widget.brand,
            message: 'Sessao interna nao encontrada.',
            onRetry: _retry,
          );
        }

        if (session.userPublicId == 'usr_dev_local') {
          return widget.child;
        }

        if (!_contextConfirmed) {
          return _CompanyContextSelectionScreen(
            brand: widget.brand,
            session: session,
            onConfirm: (scopedSession) => setState(() {
              _contextConfirmed = true;
              _sessionLoad = Future.value(scopedSession);
            }),
            onRetry: _retry,
          );
        }

        return widget.child;
      },
    );
  }
}

class _FirebaseLoginScreen extends StatefulWidget {
  const _FirebaseLoginScreen({required this.brand, this.onPreviewSession});

  final AuthGateBrandConfig brand;
  final VoidCallback? onPreviewSession;

  @override
  State<_FirebaseLoginScreen> createState() => _FirebaseLoginScreenState();
}

class _FirebaseLoginScreenState extends State<_FirebaseLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  AuthGateBrandConfig get _brand => widget.brand;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            compact ? _brand.bannerMobileAsset : _brand.bannerWebAsset,
            fit: BoxFit.cover,
            alignment: compact ? Alignment.center : Alignment.centerRight,
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: compact
                    ? [
                        const Color(0xF8FFF9EF),
                        const Color(0xEEF6E9D7),
                        const Color(0xDDE5D5B8),
                      ]
                    : [
                        const Color(0xFFF8F1E2),
                        const Color(0xEAF6EDD9),
                        const Color(0xB9E2D8BD),
                        const Color(0x44213E39),
                      ],
                stops: compact
                    ? const [0.0, 0.58, 1.0]
                    : const [0.0, 0.46, 0.76, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 18 : 42,
                  vertical: 28,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: _buildLoginPanel(context),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, compact ? 12 : 18, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : _openClientOnboarding,
                  icon: const Icon(Icons.business_center_outlined, size: 18),
                  label: const Text('Cadastrar novo cliente'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.92),
                    foregroundColor: _brand.deepTealColor,
                    side: BorderSide(
                      color: _brand.deepTealColor.withValues(alpha: 0.22),
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPanel(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.68)),
        boxShadow: [
          BoxShadow(
            color: _brand.deepTealColor.withValues(alpha: 0.18),
            blurRadius: 38,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(26, 24, 26, 22),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Image.asset(
                    _brand.logoSymbolAsset,
                    width: 42,
                    height: 42,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PariFlow Partners',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: _brand.deepTealColor,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'Acesso operacional',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _brand.mutedColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                decoration: _authInputDecoration(
                  label: 'E-mail',
                  icon: Icons.mail_outline_rounded,
                ),
                validator: (value) {
                  final email = value?.trim() ?? '';
                  if (email.isEmpty || !email.contains('@')) {
                    return 'Informe um e-mail valido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                decoration: _authInputDecoration(
                  label: 'Senha',
                  icon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if ((value ?? '').length < 6) {
                    return 'Informe a senha.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isSubmitting ? null : _sendPasswordReset,
                  child: const Text('Recuperar senha'),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isSubmitting ? null : _submit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.login_rounded),
                label: const Text('Entrar'),
                style: FilledButton.styleFrom(
                  backgroundColor: _brand.tealColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              if (widget.onPreviewSession != null) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _isSubmitting ? null : widget.onPreviewSession,
                  icon: const Icon(Icons.science_outlined),
                  label: const Text('Entrar em homologacao'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _brand.deepTealColor,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/legal'),
                icon: const Icon(Icons.policy_outlined, size: 18),
                label: const Text('Termos de uso e privacidade'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _authInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDCE5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _brand.tealColor, width: 1.4),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (error) {
      _showAuthMessage(_firebaseAuthMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showAuthMessage('Informe o e-mail para recuperar a senha.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showAuthMessage('Enviamos a recuperacao para o e-mail informado.');
    } on FirebaseAuthException catch (error) {
      _showAuthMessage(_firebaseAuthMessage(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showAuthMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openClientOnboarding() async {
    await showDialog<void>(
      context: context,
      builder: (context) => _ClientOnboardingDialog(brand: _brand),
    );
  }
}

class _ClientOnboardingDialog extends StatefulWidget {
  const _ClientOnboardingDialog({required this.brand});

  final AuthGateBrandConfig brand;

  @override
  State<_ClientOnboardingDialog> createState() =>
      _ClientOnboardingDialogState();
}

class _ClientOnboardingDialogState extends State<_ClientOnboardingDialog> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _tradeName = TextEditingController();
  final _legalName = TextEditingController();
  final _cnpj = TextEditingController();
  final _stateRegistration = TextEditingController();
  final _municipalRegistration = TextEditingController();
  final _segment = TextEditingController();
  final _primaryCnae = TextEditingController();
  final _contactName = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactPhone = TextEditingController();
  final _verificationCode = TextEditingController();
  final _quotaControllers = <String, TextEditingController>{};

  List<_OnboardingOption> _companyTypes = _fallbackCompanyTypes;
  List<_OnboardingOption> _companySizes = _fallbackCompanySizes;
  List<_AccessQuotaOption> _accessLevels = _fallbackAccessLevels;
  String _companyType = _fallbackCompanyTypes.first.value;
  String _companySize = _fallbackCompanySizes[2].value;
  String _verificationChannel = 'EMAIL';
  bool _verificationAccepted = true;
  bool _checkingCnpj = false;
  bool _sendingVerification = false;
  bool _submitting = false;
  Timer? _cnpjDebounce;
  String? _lastCheckedCnpj;
  String? _verificationChallengePublicId;
  String? _verificationDevCode;
  DateTime? _verificationExpiresAt;
  _CnpjStatusSnapshot? _cnpjStatus;
  _OnboardingResultSnapshot? _result;

  AuthGateBrandConfig get _brand => widget.brand;

  @override
  void initState() {
    super.initState();
    _ensureQuotaControllers(_accessLevels);
    _cnpj.addListener(_scheduleCnpjCheck);
    unawaited(_loadOptions());
  }

  @override
  void dispose() {
    _cnpjDebounce?.cancel();
    _tradeName.dispose();
    _legalName.dispose();
    _cnpj.dispose();
    _stateRegistration.dispose();
    _municipalRegistration.dispose();
    _segment.dispose();
    _primaryCnae.dispose();
    _contactName.dispose();
    _contactEmail.dispose();
    _contactPhone.dispose();
    _verificationCode.dispose();
    for (final controller in _quotaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(18),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 940,
          maxHeight: size.height * 0.9,
        ),
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 720;
                      final fieldWidth = compact
                          ? constraints.maxWidth
                          : (constraints.maxWidth - 14) / 2;

                      return Wrap(
                        spacing: 14,
                        runSpacing: 14,
                        children: [
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _tradeName,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Nome fantasia',
                                icon: Icons.storefront_outlined,
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _legalName,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Razao social',
                                icon: Icons.article_outlined,
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _cnpj,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(14),
                              ],
                              decoration: _dialogInputDecoration(
                                label: 'CNPJ',
                                icon: Icons.badge_outlined,
                                suffixIcon: _checkingCnpj
                                    ? const Padding(
                                        padding: EdgeInsets.all(13),
                                        child: SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        tooltip: 'Verificar CNPJ',
                                        onPressed: _checkCnpj,
                                        icon: const Icon(
                                          Icons.manage_search_outlined,
                                        ),
                                      ),
                              ),
                              validator: (value) {
                                final cnpj = _digitsOnly(value ?? '');
                                if (cnpj.length != 14) {
                                  return 'Informe 14 digitos.';
                                }
                                return null;
                              },
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            DropdownButtonFormField<String>(
                              key: ValueKey('company-type-$_companyType'),
                              initialValue: _companyType,
                              isExpanded: true,
                              decoration: _dialogInputDecoration(
                                label: 'Tipo de empresa',
                                icon: Icons.domain_outlined,
                              ),
                              items: [
                                for (final option in _companyTypes)
                                  DropdownMenuItem(
                                    value: option.value,
                                    child: Text(option.label),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _companyType = value);
                              },
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _stateRegistration,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Inscricao estadual',
                                icon: Icons.receipt_long_outlined,
                                helperText: 'Opcional',
                              ),
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _municipalRegistration,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Inscricao municipal',
                                icon: Icons.receipt_outlined,
                                helperText: 'Opcional',
                              ),
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _segment,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Segmento de atuacao',
                                icon: Icons.category_outlined,
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _primaryCnae,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                              ],
                              decoration: _dialogInputDecoration(
                                label: 'CNAE principal',
                                icon: Icons.numbers_outlined,
                                helperText: 'Opcional',
                              ),
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            DropdownButtonFormField<String>(
                              key: ValueKey('company-size-$_companySize'),
                              initialValue: _companySize,
                              isExpanded: true,
                              decoration: _dialogInputDecoration(
                                label: 'Porte da empresa',
                                icon: Icons.apartment_outlined,
                              ),
                              items: [
                                for (final option in _companySizes)
                                  DropdownMenuItem(
                                    value: option.value,
                                    child: Text(option.label),
                                  ),
                              ],
                              onChanged: (value) {
                                if (value == null) {
                                  return;
                                }
                                setState(() => _companySize = value);
                              },
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _contactName,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Contato principal',
                                icon: Icons.person_outline_rounded,
                              ),
                              validator: _requiredValidator,
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _contactEmail,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'E-mail do contato',
                                icon: Icons.mail_outline_rounded,
                              ),
                              validator: _emailValidator,
                            ),
                          ),
                          _fieldBox(
                            fieldWidth,
                            TextFormField(
                              controller: _contactPhone,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              decoration: _dialogInputDecoration(
                                label: 'Telefone do contato',
                                icon: Icons.phone_outlined,
                              ),
                            ),
                          ),
                          _fieldBox(
                            constraints.maxWidth,
                            _buildCnpjStatusPanel(context),
                          ),
                          _fieldBox(
                            constraints.maxWidth,
                            _buildVerificationPanel(
                              compact,
                              constraints.maxWidth,
                              fieldWidth,
                            ),
                          ),
                          _fieldBox(
                            constraints.maxWidth,
                            _buildQuotaPanel(compact),
                          ),
                          if (_result != null)
                            _fieldBox(
                              constraints.maxWidth,
                              _buildResultPanel(context, _result!),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Empresa raiz bloqueada contra exclusao quando criada.',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: _brand.mutedColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _submitting ? null : _submit,
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_circle_outline),
                    label: const Text('Cadastrar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: _brand.tealColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 14, 16),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _brand.tealColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.business_center_outlined,
              color: _brand.tealColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Cadastrar novo cliente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: _brand.deepTealColor,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  'Onboarding comercial e empresa raiz',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: _brand.mutedColor),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Fechar',
            onPressed: _submitting ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }

  Widget _buildCnpjStatusPanel(BuildContext context) {
    final status = _cnpjStatus;
    final background = status == null
        ? const Color(0xFFF8FAF8)
        : status.canSubmit
        ? _brand.tealColor.withValues(alpha: 0.08)
        : const Color(0xFFFFF4ED);
    final foreground = status == null
        ? _brand.mutedColor
        : status.canSubmit
        ? _brand.deepTealColor
        : const Color(0xFF9A4B16);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: status == null
              ? const Color(0xFFDCE5E0)
              : foreground.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              status == null
                  ? Icons.manage_search_outlined
                  : status.canSubmit
                  ? Icons.verified_outlined
                  : Icons.block_outlined,
              color: foreground,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: status == null
                  ? Text(
                      'Informe o CNPJ para consultar o tipo de contrato disponivel.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: foreground),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${status.availabilityLabel} | ${status.contractTypeLabel}',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.message,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: foreground),
                        ),
                        if (status.contactLabel.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            status.contactLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: _brand.mutedColor),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationPanel(
    bool compact,
    double fullWidth,
    double fieldWidth,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE5E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 14,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: fieldWidth,
                  child: CheckboxListTile(
                    value: _verificationAccepted,
                    onChanged: (value) {
                      setState(() {
                        _verificationAccepted = value ?? true;
                        _resetVerificationChallenge();
                        if (!_verificationAccepted) {
                          _verificationChannel = 'NONE';
                        } else if (_verificationChannel == 'NONE') {
                          _verificationChannel = 'EMAIL';
                        }
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Validar em duas etapas agora'),
                    subtitle: Text(
                      _verificationAccepted
                          ? 'Libera imediatamente com o código confirmado.'
                          : 'Seguir para a análise manual.',
                    ),
                  ),
                ),
                SizedBox(
                  width: fieldWidth,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('verification-channel-$_verificationChannel'),
                    initialValue: _verificationChannel,
                    isExpanded: true,
                    decoration: _dialogInputDecoration(
                      label: 'Canal de validacao',
                      icon: Icons.security_outlined,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EMAIL', child: Text('E-mail')),
                      DropdownMenuItem(value: 'PHONE', child: Text('Telefone')),
                      DropdownMenuItem(
                        value: 'WHATSAPP',
                        child: Text('WhatsApp'),
                      ),
                      DropdownMenuItem(
                        value: 'NONE',
                        child: Text('Enviar para análise'),
                      ),
                    ],
                    onChanged: _verificationAccepted
                        ? (value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _verificationChannel = value;
                              _resetVerificationChallenge();
                            });
                          }
                        : null,
                  ),
                ),
              ],
            ),
            if (_verificationAccepted && _verificationChannel != 'NONE') ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: compact ? fullWidth : 220,
                    child: FilledButton.icon(
                      onPressed: _sendingVerification
                          ? null
                          : _startVerification,
                      icon: _sendingVerification
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.mark_email_read_outlined),
                      label: const Text('Enviar código'),
                      style: FilledButton.styleFrom(
                        backgroundColor: _brand.deepTealColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: compact ? fullWidth : 220,
                    child: TextFormField(
                      controller: _verificationCode,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: _dialogInputDecoration(
                        label: 'Código recebido',
                        icon: Icons.pin_outlined,
                      ),
                    ),
                  ),
                  if (_verificationDevCode != null)
                    SizedBox(
                      width: compact ? fullWidth : 260,
                      child: Text(
                        'Código local: $_verificationDevCode',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: _brand.deepTealColor),
                      ),
                    )
                  else if (_verificationExpiresAt != null)
                    SizedBox(
                      width: compact ? fullWidth : 260,
                      child: Text(
                        'Código enviado. Expira em alguns minutos.',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: _brand.mutedColor),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuotaPanel(bool compact) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7DED1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Contas iniciais por nível',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _brand.deepTealColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final level in _accessLevels)
                  SizedBox(
                    width: compact ? double.infinity : 158,
                    child: TextFormField(
                      controller: _quotaControllers[level.key],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: _dialogInputDecoration(
                        label: level.label,
                        icon: Icons.group_add_outlined,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(
    BuildContext context,
    _OnboardingResultSnapshot result,
  ) {
    final released = result.immediateRelease;
    final color = released ? _brand.tealColor : const Color(0xFF9A6A1A);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              released
                  ? Icons.check_circle_outline
                  : Icons.pending_actions_outlined,
              color: color,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    released ? 'Cliente liberado' : 'Solicitação registrada',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    result.summary,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldBox(double width, Widget child) {
    return SizedBox(width: width, child: child);
  }

  InputDecoration _dialogInputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    String? helperText,
  }) {
    return InputDecoration(
      labelText: label,
      helperText: helperText,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDCE5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _brand.tealColor, width: 1.4),
      ),
    );
  }

  Future<void> _loadOptions() async {
    try {
      final data = await _api.getMap(
        'public/client-onboarding/options',
        requiresAuth: false,
      );
      final companyTypes = _readOptions(
        data['companyTypes'],
        _fallbackCompanyTypes,
      );
      final companySizes = _readOptions(
        data['companySizes'],
        _fallbackCompanySizes,
      );
      final accessLevels = _readAccessLevels(
        data['accessLevels'],
        _fallbackAccessLevels,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _companyTypes = companyTypes;
        _companySizes = companySizes;
        _accessLevels = accessLevels;
        _companyType = _valueOrFirst(_companyType, _companyTypes);
        _companySize = _valueOrFirst(_companySize, _companySizes);
        _ensureQuotaControllers(_accessLevels);
      });
    } on ApiException {
      // Fallback local mantem o cadastro usavel quando a API ainda esta subindo.
    }
  }

  void _ensureQuotaControllers(List<_AccessQuotaOption> levels) {
    final keys = levels.map((level) => level.key).toSet();
    final staleKeys = _quotaControllers.keys
        .where((key) => !keys.contains(key))
        .toList();

    for (final key in staleKeys) {
      _quotaControllers.remove(key)?.dispose();
    }

    for (final level in levels) {
      _quotaControllers.putIfAbsent(
        level.key,
        () => TextEditingController(text: '${level.defaultQuota}'),
      );
    }
  }

  void _scheduleCnpjCheck() {
    final cnpj = _digitsOnly(_cnpj.text);
    if (cnpj.length != 14) {
      _cnpjDebounce?.cancel();
      if (_cnpjStatus != null || _lastCheckedCnpj != null) {
        setState(() {
          _cnpjStatus = null;
          _lastCheckedCnpj = null;
        });
      }
      return;
    }

    _cnpjDebounce?.cancel();
    _cnpjDebounce = Timer(const Duration(milliseconds: 450), () {
      if (_lastCheckedCnpj == cnpj && _cnpjStatus != null) {
        return;
      }
      unawaited(_checkCnpj(showErrors: false));
    });
  }

  Future<void> _checkCnpj({bool showErrors = true}) async {
    final cnpj = _digitsOnly(_cnpj.text);
    if (cnpj.length != 14) {
      if (showErrors) {
        _showMessage('Informe um CNPJ com 14 digitos.');
      }
      return;
    }

    setState(() => _checkingCnpj = true);

    try {
      final data = await _api.getMap(
        'public/client-onboarding/cnpj-status',
        query: {'cnpj': cnpj},
        requiresAuth: false,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _lastCheckedCnpj = cnpj;
        _cnpjStatus = _CnpjStatusSnapshot.fromMap(data);
      });
    } on ApiException catch (error) {
      if (showErrors) {
        _showMessage(error.message);
      }
    } finally {
      if (mounted) {
        setState(() => _checkingCnpj = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _contactEmail.text.trim();
    final phone = _contactPhone.text.trim();

    if (email.isEmpty && phone.isEmpty) {
      _showMessage('Informe o e-mail ou telefone do contato principal.');
      return;
    }

    if (_verificationAccepted &&
        _verificationChannel == 'EMAIL' &&
        email.isEmpty) {
      _showMessage('Informe o e-mail usado na verificação.');
      return;
    }

    if (_verificationAccepted &&
        (_verificationChannel == 'PHONE' ||
            _verificationChannel == 'WHATSAPP') &&
        phone.isEmpty) {
      _showMessage('Informe o telefone usado na verificação.');
      return;
    }

    if (_verificationAccepted &&
        _verificationChannel != 'NONE' &&
        (_verificationChallengePublicId == null ||
            _verificationCode.text.trim().length != 6)) {
      _showMessage('Informe o código de verificacao.');
      return;
    }

    if (_cnpjStatus == null || _lastCheckedCnpj != _digitsOnly(_cnpj.text)) {
      await _checkCnpj(showErrors: false);
    }

    if (!mounted) {
      return;
    }

    setState(() => _submitting = true);

    try {
      final body = <String, dynamic>{
        'tradeName': _tradeName.text.trim(),
        'legalName': _legalName.text.trim(),
        'cnpj': _digitsOnly(_cnpj.text),
        'companyType': _companyType,
        'segment': _segment.text.trim(),
        'companySize': _companySize,
        'primaryContactName': _contactName.text.trim(),
        'accessLevelQuotas': {
          for (final level in _accessLevels)
            level.key:
                int.tryParse(_quotaControllers[level.key]?.text ?? '') ??
                level.defaultQuota,
        },
        'verificationAccepted': _verificationAccepted,
        'verificationChannel': _verificationAccepted
            ? _verificationChannel
            : 'NONE',
      };
      _putIfNotBlank(
        body,
        'verificationChallengePublicId',
        _verificationChallengePublicId ?? '',
      );
      _putIfNotBlank(body, 'verificationCode', _verificationCode.text);
      _putIfNotBlank(body, 'stateRegistration', _stateRegistration.text);
      _putIfNotBlank(
        body,
        'municipalRegistration',
        _municipalRegistration.text,
      );
      _putIfNotBlank(body, 'primaryCnae', _primaryCnae.text);
      _putIfNotBlank(body, 'primaryContactEmail', email);
      _putIfNotBlank(body, 'primaryContactPhone', phone);

      final data = await _api.postMap(
        'public/client-onboarding',
        body: body,
        requiresAuth: false,
      );
      final result = _OnboardingResultSnapshot.fromMap(data);

      if (!mounted) {
        return;
      }

      setState(() => _result = result);
      _showMessage(
        result.immediateRelease
            ? 'Cliente liberado com verificacao em duas etapas.'
            : 'Solicitacao registrada para analise.',
      );
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _startVerification() async {
    final cnpj = _digitsOnly(_cnpj.text);
    if (cnpj.length != 14) {
      _showMessage('Informe o CNPJ antes de enviar o código.');
      return;
    }

    final target = _verificationChannel == 'EMAIL'
        ? _contactEmail.text.trim()
        : _contactPhone.text.trim();
    if (target.isEmpty) {
      _showMessage(
        _verificationChannel == 'EMAIL'
            ? 'Informe o e-mail do contato.'
            : 'Informe o telefone do contato.',
      );
      return;
    }

    setState(() => _sendingVerification = true);

    try {
      final data = await _api.postMap(
        'public/client-onboarding/verification/start',
        body: {'cnpj': cnpj, 'channel': _verificationChannel, 'target': target},
        requiresAuth: false,
      );

      if (!mounted) {
        return;
      }

      final devCode = _asText(data['devCode']);
      setState(() {
        _verificationChallengePublicId = _asText(data['challengePublicId']);
        _verificationDevCode = devCode.isEmpty ? null : devCode;
        _verificationExpiresAt = DateTime.tryParse(_asText(data['expiresAt']));
        _verificationCode.clear();
      });
      _showMessage('Código de verificacao enviado.');
    } on ApiException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _sendingVerification = false);
      }
    }
  }

  void _resetVerificationChallenge() {
    _verificationChallengePublicId = null;
    _verificationDevCode = null;
    _verificationExpiresAt = null;
    _verificationCode.clear();
  }

  String? _requiredValidator(String? value) {
    if ((value ?? '').trim().isEmpty) {
      return 'Campo obrigatorio.';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) {
      return null;
    }
    if (!email.contains('@')) {
      return 'E-mail invalido.';
    }
    return null;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OnboardingOption {
  const _OnboardingOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _AccessQuotaOption {
  const _AccessQuotaOption({
    required this.key,
    required this.label,
    required this.defaultQuota,
  });

  final String key;
  final String label;
  final int defaultQuota;
}

class _CnpjStatusSnapshot {
  const _CnpjStatusSnapshot({
    required this.availabilityLabel,
    required this.contractTypeLabel,
    required this.message,
    required this.canSubmit,
    required this.contactLabel,
  });

  factory _CnpjStatusSnapshot.fromMap(Map<String, dynamic> map) {
    final contact = _asMap(map['commercialContact']);
    final contactParts = [
      _asText(contact['name']),
      _asText(contact['emailMasked']),
      _asText(contact['phoneMasked']),
    ].where((item) => item.isNotEmpty).toList();

    return _CnpjStatusSnapshot(
      availabilityLabel: _asText(
        map['availabilityLabel'],
        fallback: 'Status consultado',
      ),
      contractTypeLabel: _asText(
        map['contractTypeLabel'],
        fallback: 'Tipo de contrato',
      ),
      message: _asText(map['message']),
      canSubmit: _asBool(map['canSubmit']),
      contactLabel: contactParts.isEmpty
          ? ''
          : 'Contato comercial: ${contactParts.join(' | ')}',
    );
  }

  final String availabilityLabel;
  final String contractTypeLabel;
  final String message;
  final bool canSubmit;
  final String contactLabel;
}

class _OnboardingResultSnapshot {
  const _OnboardingResultSnapshot({
    required this.immediateRelease,
    required this.summary,
  });

  factory _OnboardingResultSnapshot.fromMap(Map<String, dynamic> map) {
    final request = _asMap(map['request']);
    final rootCompany = _asMap(map['tenantRootCompany']);
    final security = _asMap(map['security']);
    final requestStatus = _asText(request['statusLabel']);
    final rootId = _asText(rootCompany['publicId']);
    final rootStatus = _asText(rootCompany['statusLabel']);
    final reviewEmail = _asText(security['reviewNotificationEmail']);
    final released = _asBool(security['immediateRelease']);
    final parts = <String>[
      if (requestStatus.isNotEmpty) 'Solicitacao: $requestStatus',
      if (rootId.isNotEmpty) 'Empresa raiz: $rootId',
      if (rootStatus.isNotEmpty) 'Status: $rootStatus',
      if (reviewEmail.isNotEmpty) 'Analise: $reviewEmail',
    ];

    return _OnboardingResultSnapshot(
      immediateRelease: released,
      summary: parts.isEmpty
          ? 'Registro recebido pelo backend.'
          : parts.join(' | '),
    );
  }

  final bool immediateRelease;
  final String summary;
}

const _fallbackCompanyTypes = [
  _OnboardingOption(value: 'SERVICE_PROVIDER', label: 'Prestadora de servicos'),
  _OnboardingOption(
    value: 'CONDOMINIUM_MANAGER',
    label: 'Administradora ou condominio',
  ),
  _OnboardingOption(value: 'CORPORATE_CLIENT', label: 'Cliente corporativo'),
  _OnboardingOption(value: 'CONSULTING', label: 'Consultoria'),
  _OnboardingOption(value: 'TECHNOLOGY', label: 'Tecnologia ou SaaS'),
  _OnboardingOption(value: 'OTHER', label: 'Outro'),
];

const _fallbackCompanySizes = [
  _OnboardingOption(value: 'MEI', label: 'MEI'),
  _OnboardingOption(value: 'MICRO', label: 'Microempresa'),
  _OnboardingOption(value: 'SMALL', label: 'Pequena empresa'),
  _OnboardingOption(value: 'MEDIUM', label: 'Media empresa'),
  _OnboardingOption(value: 'LARGE', label: 'Grande empresa'),
  _OnboardingOption(value: 'ENTERPRISE', label: 'Enterprise'),
];

const _fallbackAccessLevels = [
  _AccessQuotaOption(key: 'ADMIN', label: 'Administrador', defaultQuota: 1),
  _AccessQuotaOption(key: 'EXECUTIVE', label: 'Alta gestao', defaultQuota: 1),
  _AccessQuotaOption(key: 'LEGAL', label: 'Juridico', defaultQuota: 0),
  _AccessQuotaOption(key: 'HR', label: 'RH estrategico', defaultQuota: 1),
  _AccessQuotaOption(
    key: 'OPERATIONS',
    label: 'Operacao autorizada',
    defaultQuota: 3,
  ),
];

List<_OnboardingOption> _readOptions(
  Object? value,
  List<_OnboardingOption> fallback,
) {
  if (value is! List) {
    return fallback;
  }

  final options = [
    for (final item in value)
      if (item is Map)
        _OnboardingOption(
          value: _asText(item['value']),
          label: _asText(item['label']),
        ),
  ].where((item) => item.value.isNotEmpty && item.label.isNotEmpty).toList();

  return options.isEmpty ? fallback : options;
}

List<_AccessQuotaOption> _readAccessLevels(
  Object? value,
  List<_AccessQuotaOption> fallback,
) {
  if (value is! List) {
    return fallback;
  }

  final options = [
    for (final item in value)
      if (item is Map)
        _AccessQuotaOption(
          key: _asText(item['key']),
          label: _asText(item['label']),
          defaultQuota: _asInt(item['defaultQuota']),
        ),
  ].where((item) => item.key.isNotEmpty && item.label.isNotEmpty).toList();

  return options.isEmpty ? fallback : options;
}

String _valueOrFirst(String current, List<_OnboardingOption> options) {
  if (options.any((option) => option.value == current)) {
    return current;
  }
  return options.first.value;
}

Map<String, dynamic> _asMap(Object? value) {
  if (value is Map) {
    return value.cast<String, dynamic>();
  }
  return const {};
}

String _asText(Object? value, {String fallback = ''}) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? fallback : text;
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse('${value ?? ''}') ?? 0;
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  return value?.toString().toLowerCase() == 'true';
}

String _digitsOnly(String value) {
  return value.replaceAll(RegExp(r'\D'), '');
}

void _putIfNotBlank(Map<String, dynamic> body, String key, String value) {
  final normalized = value.trim();
  if (normalized.isNotEmpty) {
    body[key] = normalized;
  }
}

const _accessLevelLabels = <String, String>{
  'ADMIN': 'Administrador',
  'EXECUTIVE': 'Executivo',
  'LEGAL': 'Juridico',
  'HR': 'RH',
  'OPERATIONS': 'Operacao',
};

const _requestNewCompanyValue = '__request_company_access__';

class _SessionUnavailableScreen extends StatelessWidget {
  const _SessionUnavailableScreen({
    required this.brand,
    required this.message,
    required this.onRetry,
  });

  final AuthGateBrandConfig brand;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brand.paperColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.gpp_maybe_outlined,
                  size: 42,
                  color: brand.deepTealColor,
                ),
                const SizedBox(height: 14),
                Text(
                  'Sessao interna nao validada',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: brand.mutedColor),
                ),
                const SizedBox(height: 18),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Tentar novamente'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => unawaited(ApiClient().logout()),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sair'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyContextSelectionScreen extends StatelessWidget {
  const _CompanyContextSelectionScreen({
    required this.brand,
    required this.session,
    required this.onConfirm,
    required this.onRetry,
  });

  final AuthGateBrandConfig brand;
  final SessionSnapshot session;
  final ValueChanged<SessionSnapshot> onConfirm;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _CompanyAccessRequiredScreen(
      brand: brand,
      session: session,
      onRetry: onRetry,
      onContextSelected: onConfirm,
    );
  }
}

class _CompanyContextInfoTile extends StatelessWidget {
  const _CompanyContextInfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE5E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyAccessRequiredScreen extends StatefulWidget {
  const _CompanyAccessRequiredScreen({
    required this.brand,
    required this.session,
    required this.onRetry,
    required this.onContextSelected,
  });

  final AuthGateBrandConfig brand;
  final SessionSnapshot session;
  final VoidCallback onRetry;
  final ValueChanged<SessionSnapshot> onContextSelected;

  @override
  State<_CompanyAccessRequiredScreen> createState() =>
      _CompanyAccessRequiredScreenState();
}

class _CompanyAccessRequiredScreenState
    extends State<_CompanyAccessRequiredScreen> {
  final _api = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _cnpj = TextEditingController();
  final _companyName = TextEditingController();
  final _requesterDocument = TextEditingController();
  final _requesterName = TextEditingController();
  final _requesterRole = TextEditingController();
  final _requesterEmail = TextEditingController();
  final _requesterPhone = TextEditingController();
  final _notes = TextEditingController();
  String _accessLevel = 'OPERATIONS';
  bool _acceptedTerms = false;
  bool _submitting = false;
  bool _selectingContext = false;
  bool _loadingContext = false;
  String? _message;
  var _accessDocuments = <Map<String, dynamic>>[];
  var _linkedCompanies = <Map<String, dynamic>>[];
  String _selectedContext = _requestNewCompanyValue;

  AuthGateBrandConfig get _brand => widget.brand;

  @override
  void initState() {
    super.initState();
    _requesterName.text = widget.session.userName;
    unawaited(_loadAccessContext());
  }

  @override
  void dispose() {
    _cnpj.dispose();
    _companyName.dispose();
    _requesterDocument.dispose();
    _requesterName.dispose();
    _requesterRole.dispose();
    _requesterEmail.dispose();
    _requesterPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < 760;
    final requestingCompany = _requestingCompany;
    final selectedCompany = _selectedCompany;
    return Scaffold(
      backgroundColor: _brand.paperColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 28,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFDCE5E0)),
                  boxShadow: [
                    BoxShadow(
                      color: _brand.deepTealColor.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Image.asset(
                              _brand.logoSymbolAsset,
                              width: 42,
                              height: 42,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'PariFlow Partners',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: _brand.deepTealColor,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                  Text(
                                    'Contexto empresarial',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: _brand.mutedColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Selecione a empresa principal aprovada ou solicite um novo vinculo.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: _brand.mutedColor),
                        ),
                        if (_loadingContext) ...[
                          const SizedBox(height: 14),
                          const LinearProgressIndicator(minHeight: 2),
                        ],
                        if (_linkedCompanies.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedContext,
                            isExpanded: true,
                            decoration: _accessDecoration(
                              label: 'Empresa principal ativa',
                              icon: Icons.business_outlined,
                            ),
                            items: [
                              for (final company in _linkedCompanies)
                                DropdownMenuItem(
                                  value: _companyPublicId(company),
                                  child: Text(_companyOptionLabel(company)),
                                ),
                              const DropdownMenuItem(
                                value: _requestNewCompanyValue,
                                child: Text(
                                  'Solicitar vinculo a outra empresa',
                                ),
                              ),
                            ],
                            onChanged: _selectingContext
                                ? null
                                : (value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedContext = value;
                                        _message = null;
                                      });
                                    }
                                  },
                          ),
                        ],
                        if (!requestingCompany && selectedCompany != null) ...[
                          const SizedBox(height: 14),
                          _CompanyContextInfoTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Usuario',
                            value:
                                '${widget.session.userName} | ${widget.session.userPublicId}',
                          ),
                          const SizedBox(height: 10),
                          _CompanyContextInfoTile(
                            icon: Icons.business_outlined,
                            label: 'Empresa selecionada',
                            value: _companyOptionLabel(selectedCompany),
                          ),
                          const SizedBox(height: 10),
                          _CompanyContextInfoTile(
                            icon: Icons.admin_panel_settings_outlined,
                            label: 'Nivel de acesso',
                            value: _companyAccessLabel(selectedCompany),
                          ),
                        ],
                        if (requestingCompany) ...[
                          const SizedBox(height: 16),
                          _AccessInfoBox(
                            text: _linkedCompanies.isEmpty
                                ? 'Sua conta Firebase foi validada, mas ainda nao ha vinculo aprovado. Envie os dados para analise antes de acessar os documentos do app.'
                                : 'A solicitacao abaixo nao troca seu contexto atual. O acesso so sera liberado depois da aprovacao no backend.',
                          ),
                          const SizedBox(height: 16),
                          _accessTextField(
                            controller: _cnpj,
                            label: 'CNPJ da empresa',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(14),
                            ],
                            validator: (value) =>
                                _digitsOnly(value ?? '').length == 14
                                ? null
                                : 'Informe 14 digitos.',
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _companyName,
                            label: 'Nome da empresa',
                            icon: Icons.business_center_outlined,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Informe a empresa.'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            initialValue: _accessLevel,
                            isExpanded: true,
                            decoration: _accessDecoration(
                              label: 'Nivel de acesso solicitado',
                              icon: Icons.admin_panel_settings_outlined,
                            ),
                            items: [
                              for (final entry in _accessLevelLabels.entries)
                                DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _accessLevel = value);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _requesterDocument,
                            label: 'CPF ou CNPJ do solicitante',
                            icon: Icons.person_search_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(14),
                            ],
                            validator: (value) {
                              final digits = _digitsOnly(value ?? '');
                              return digits.length == 11 || digits.length == 14
                                  ? null
                                  : 'Informe CPF ou CNPJ valido.';
                            },
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _requesterName,
                            label: 'Nome do solicitante',
                            icon: Icons.person_outline_rounded,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Informe o nome.'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _requesterRole,
                            label: 'Cargo ou relacao com a empresa',
                            icon: Icons.assignment_ind_outlined,
                            validator: (value) => (value ?? '').trim().isEmpty
                                ? 'Informe o vinculo.'
                                : null,
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _requesterEmail,
                            label: 'E-mail de contato',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              final email = (value ?? '').trim();
                              return email.isEmpty || email.contains('@')
                                  ? null
                                  : 'E-mail invalido.';
                            },
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _requesterPhone,
                            label: 'Telefone de contato',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 10),
                          _accessTextField(
                            controller: _notes,
                            label: 'Observacoes sem dados sensiveis',
                            icon: Icons.notes_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: _acceptedTerms,
                            onChanged: (value) =>
                                setState(() => _acceptedTerms = value == true),
                            title: const Text(
                              'Li e concordo com os termos de uso e politica de privacidade.',
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/legal'),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Abrir termos e privacidade'),
                            ),
                          ),
                        ],
                        if (_message != null) ...[
                          const SizedBox(height: 8),
                          _AccessInfoBox(text: _message!),
                        ],
                        if (_loadingContext) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(minHeight: 2),
                        ] else if (_accessDocuments.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Documentos desta etapa',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          for (final item in _accessDocuments.take(3)) ...[
                            _CompanyAccessDocumentTile(item: item),
                            const SizedBox(height: 8),
                          ],
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          alignment: WrapAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _submitting || _selectingContext
                                  ? null
                                  : () => unawaited(ApiClient().logout()),
                              icon: const Icon(Icons.logout_rounded),
                              label: const Text('Sair'),
                            ),
                            OutlinedButton.icon(
                              onPressed: _submitting || _selectingContext
                                  ? null
                                  : widget.onRetry,
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Revalidar'),
                            ),
                            if (requestingCompany)
                              FilledButton.icon(
                                onPressed: _submitting ? null : _submit,
                                icon: _submitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.send_outlined),
                                label: const Text('Solicitar acesso'),
                              )
                            else
                              FilledButton.icon(
                                onPressed: _selectingContext
                                    ? null
                                    : _confirmSelectedContext,
                                icon: _selectingContext
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.login_rounded),
                                label: const Text('Entrar'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _requestingCompany =>
      _selectedContext == _requestNewCompanyValue || _linkedCompanies.isEmpty;

  Map<String, dynamic>? get _selectedCompany {
    for (final company in _linkedCompanies) {
      if (_companyPublicId(company) == _selectedContext) {
        return company;
      }
    }
    return null;
  }

  String _companyPublicId(Map<String, dynamic> company) {
    return _asText(company['publicId']);
  }

  String _companyOptionLabel(Map<String, dynamic> company) {
    final name = [
      _asText(company['tradeName']),
      _asText(company['legalName']),
    ].firstWhere((value) => value.isNotEmpty, orElse: () => 'Empresa');
    final cnpj = _asText(company['cnpj']);
    final status = _asText(company['status']);
    return [
      name,
      if (cnpj.isNotEmpty) cnpj,
      if (status.isNotEmpty) status,
    ].join(' | ');
  }

  String _companyAccessLabel(Map<String, dynamic> company) {
    final profile = _asText(company['accessProfile']);
    if (profile.isNotEmpty) {
      return _accessLevelLabels[profile.toUpperCase()] ?? profile;
    }
    final profiles = widget.session.profiles;
    return profiles.isEmpty
        ? widget.session.securityContext
        : profiles.join(' / ');
  }

  Widget _accessTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: _accessDecoration(label: label, icon: icon),
      validator: validator,
    );
  }

  InputDecoration _accessDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFFDCE5E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: _brand.tealColor, width: 1.4),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_acceptedTerms) {
      setState(() {
        _message = 'Aceite os termos para enviar a solicitacao.';
      });
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _submitting = true;
      _message = null;
    });

    try {
      final body = <String, dynamic>{
        'cnpj': _digitsOnly(_cnpj.text),
        'companyName': _companyName.text.trim(),
        'requesterDocument': _digitsOnly(_requesterDocument.text),
        'requestedAccessLevel': _accessLevel,
        'requesterName': _requesterName.text.trim(),
        'requesterRole': _requesterRole.text.trim(),
      };
      _putIfNotBlank(body, 'requesterEmail', _requesterEmail.text);
      _putIfNotBlank(body, 'requesterPhone', _requesterPhone.text);
      _putIfNotBlank(body, 'notes', _notes.text);
      final result = await _api.postMap('auth/access-request', body: body);
      if (!mounted) {
        return;
      }
      setState(() {
        _message =
            '${result['message'] ?? 'Solicitacao registrada para analise.'}';
      });
      await _loadAccessContext();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _confirmSelectedContext() async {
    final selectedCompany = _selectedCompany;
    if (selectedCompany == null) {
      setState(() {
        _message = 'Selecione uma empresa vinculada para continuar.';
      });
      return;
    }

    setState(() {
      _selectingContext = true;
      _message = null;
    });

    try {
      final session = await _api.selectCompanyContext(
        _companyPublicId(selectedCompany),
      );
      if (!mounted) {
        return;
      }
      widget.onContextSelected(session);
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _message = error.message;
      });
    } finally {
      if (mounted) {
        setState(() => _selectingContext = false);
      }
    }
  }

  Future<void> _loadAccessContext() async {
    setState(() => _loadingContext = true);
    try {
      final data = await _api.getMap('auth/access-context');
      if (!mounted) {
        return;
      }
      final linkedCompanies = [
        for (final item in (data['linkedCompanies'] as List? ?? const []))
          if (item is Map) item.cast<String, dynamic>(),
      ];
      final linkedCompany = data['linkedCompany'];
      if (linkedCompanies.isEmpty && linkedCompany is Map) {
        linkedCompanies.add(linkedCompany.cast<String, dynamic>());
      }
      final currentTenant = widget.session.tenantRootCompanyPublicId;
      final hasCurrentTenant = linkedCompanies.any(
        (company) => _companyPublicId(company) == currentTenant,
      );
      setState(() {
        _linkedCompanies = linkedCompanies;
        _selectedContext = hasCurrentTenant
            ? currentTenant
            : linkedCompanies.isNotEmpty
            ? _companyPublicId(linkedCompanies.first)
            : _requestNewCompanyValue;
        _accessDocuments = [
          for (final item in (data['documents'] as List? ?? const []))
            if (item is Map) item.cast<String, dynamic>(),
        ];
      });
    } on ApiException catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _linkedCompanies = const [];
        _selectedContext = _requestNewCompanyValue;
        _accessDocuments = const [];
      });
    } finally {
      if (mounted) {
        setState(() => _loadingContext = false);
      }
    }
  }
}

class _CompanyAccessDocumentTile extends StatelessWidget {
  const _CompanyAccessDocumentTile({required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final status = '${item['status'] ?? 'PENDING'}';
    final cnpj = '${item['cnpj'] ?? ''}';
    final companyName = '${item['companyName'] ?? ''}';
    final level = '${item['requestedAccessLevel'] ?? ''}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE5E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.description_outlined, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      companyName,
                      cnpj,
                    ].where((value) => value.isNotEmpty).join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      status,
                      level,
                    ].where((value) => value.isNotEmpty).join(' | '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessInfoBox extends StatelessWidget {
  const _AccessInfoBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDCE5E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(text)),
          ],
        ),
      ),
    );
  }
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen({required this.brand});

  final AuthGateBrandConfig brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brand.paperColor,
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _AuthUnavailableScreen extends StatelessWidget {
  const _AuthUnavailableScreen({required this.brand});

  final AuthGateBrandConfig brand;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: brand.paperColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 42,
                  color: brand.deepTealColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Autenticacao indisponivel',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Este build exige Firebase configurado para acessar o sistema.',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: brand.mutedColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _firebaseAuthMessage(FirebaseAuthException error) {
  return switch (error.code) {
    'invalid-email' => 'E-mail invalido.',
    'user-disabled' => 'Usuario desativado.',
    'user-not-found' ||
    'wrong-password' ||
    'invalid-credential' => 'E-mail ou senha invalidos.',
    'too-many-requests' =>
      'Muitas tentativas. Aguarde alguns minutos e tente novamente.',
    'network-request-failed' => 'Falha de rede ao autenticar.',
    'operation-not-allowed' =>
      'Login por e-mail e senha ainda nao esta habilitado no Firebase.',
    _ => 'Nao foi possivel autenticar agora.',
  };
}

bool get _isPreviewAuthEnabled => previewFirebaseIdToken != null;
