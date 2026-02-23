import 'package:flutter/material.dart';
import 'package:garden_homesuit/config/app_colors.dart';
import 'package:garden_homesuit/components/login_logo/login_logo.component.dart';
import 'package:garden_homesuit/components/login_input/login_input.component.dart';
import 'package:garden_homesuit/components/login_button/login_button.component.dart';
import 'package:garden_homesuit/providers/auth.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _rememberUser = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUsername();
  }

  Future<void> _loadSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('saved_username');
    if (savedUsername != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _rememberUser = true;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'El usuario es requerido';
    }
    if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final loginAction = ref.read(loginActionProvider);
        await loginAction(
          username: _usernameController.text.trim(),
          password: _passwordController.text,
        );

        // Guardar o eliminar el username según el checkbox
        final prefs = await SharedPreferences.getInstance();
        if (_rememberUser) {
          await prefs.setString(
            'saved_username',
            _usernameController.text.trim(),
          );
        } else {
          await prefs.remove('saved_username');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Bienvenido a Garden HomeSuit',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
            ),
          );

          // Navegar al dashboard
          context.go('/dashboard');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().contains('401')
                    ? 'Usuario o contraseña incorrectos'
                    : 'Error al iniciar sesión: $e',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.negative,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: 0,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Row(
          children: [
            // Columna izquierda - Logo e ilustración
            Expanded(
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.primary,
                      AppColors.info,
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    bottomLeft: Radius.circular(24),
                  ),
                ),
                child: Stack(
                  children: [
                    // Imagen en la parte superior izquierda
                    Positioned(
                      top: 50,
                      left: 30,
                      child: Image.asset(
                        'assets/images/homesuit.png',
                        height: 50, // Opcional: ajustar visibilidad
                      ),
                    ),
                    // Logo central
                    const Center(child: LoginLogoComponent()),
                  ],
                ),
              ),
            ),

            // Columna derecha - Formulario
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 60,
                  vertical: 40,
                ),
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildLoginForm(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 40),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Image(
                  image: AssetImage('assets/images/mobile_garden_logo.png'),
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 40),
                _buildLoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Monitoreo inteligente de tu jardín.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 32),

          // Campo de usuario
          LoginInputComponent(
            label: 'Usuario',
            hintText: 'tu_usuario',
            controller: _usernameController,
            prefixIcon: Icons.person_outline,
            validator: _validateUsername,
          ),

          const SizedBox(height: 20),

          // Campo de contraseña
          LoginInputComponent(
            label: 'Contraseña',
            hintText: '••••••••',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline,
            isPassword: true,
            validator: _validatePassword,
          ),

          const SizedBox(height: 16),

          // Checkbox recordar usuario
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberUser,
                  onChanged: (value) {
                    setState(() {
                      _rememberUser = value ?? false;
                    });
                  },
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  side: const BorderSide(color: AppColors.textMuted, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Recordar usuario',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Botón de login
          LoginButtonComponent(
            text: 'INICIAR SESIÓN',
            onPressed: _handleLogin,
            isLoading: _isLoading,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
