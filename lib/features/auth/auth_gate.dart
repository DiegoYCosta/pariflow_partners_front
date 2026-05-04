part of '../../app/app.dart';

class _AuthGate extends StatefulWidget {
  const _AuthGate({required this.child});

  final Widget child;

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
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

      return const _AuthUnavailableScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        final user = snapshot.data;
        if (user != null || _previewSessionUnlocked) {
          return widget.child;
        }

        return _FirebaseLoginScreen(
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

class _FirebaseLoginScreen extends StatefulWidget {
  const _FirebaseLoginScreen({this.onPreviewSession});

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
            compact ? _crmBannerMobileAsset : _crmBannerWebAsset,
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
            color: _deepTealColor.withValues(alpha: 0.18),
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
                    _crmLogoSymbolAsset,
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
                            color: _deepTealColor,
                            letterSpacing: 0,
                          ),
                        ),
                        Text(
                          'Acesso operacional',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _mutedColor,
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
                  backgroundColor: _tealColor,
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
                    foregroundColor: _deepTealColor,
                    minimumSize: const Size.fromHeight(46),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
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
        borderSide: const BorderSide(color: _tealColor, width: 1.4),
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
}

class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _paperColor,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _AuthUnavailableScreen extends StatelessWidget {
  const _AuthUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paperColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 42,
                  color: _deepTealColor,
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
                  ).textTheme.bodyMedium?.copyWith(color: _mutedColor),
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

bool get _isPreviewAuthEnabled => _previewFirebaseIdToken != null;
