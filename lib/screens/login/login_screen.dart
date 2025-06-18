import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../constants/assets.dart';
import '../../services/auth_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../home/home_screen.dart';
import '../../widgets/ziyarah_loader.dart';
import '../../widgets/ziyarah_navigator.dart';
import '../main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  late final AnimationController _animController;
  late final Animation<double> _fadeIn;
  bool _isSignUp = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(authService: _authService),
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            ZiyarahNavigator.showLoader(context, message: state.message);
          } else if (state is AuthSuccess) {
            ZiyarahNavigator.hideLoader(context);
            ZiyarahNavigator.pushReplacement(
              context,
              const MainShell(),
              loadingMessage: 'Loading main screen...',
            );
          } else if (state is AuthError) {
            ZiyarahNavigator.hideLoader(context);
            _showError(state.message);
          } else if (state is AuthToggleMode) {
            _isSignUp = state.isSignUp;
          }
        },
        child: _buildUI(),
      ),
    );
  }

  Widget _buildUI() {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          // 🌄 Background Gradient + Glow
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F3D2E), Color(0xFF1A6244)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            top: -size.height * 0.25,
            left: -size.width * 0.3,
            child: Container(
              width: size.width * 1.2,
              height: size.width * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.06), Colors.transparent],
                ),
              ),
            ),
          ),

          // 🧊 Frosted Login Card
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                  child: Container(
                    width: size.width * 0.88,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 28,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(AppAssets.logo, width: 160),
                        const SizedBox(height: 16),
                        const SizedBox(height: 6),
                        const Text(
                          'Your Smart Companion for Umrah',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 📧 Email
                        _buildInputField(
                          hintText: "Email",
                          controller: _emailController,
                          icon: Icons.email_outlined,
                          obscure: false,
                        ),
                        const SizedBox(height: 16),

                        // 🔒 Password
                        _buildInputField(
                          hintText: "Password",
                          controller: _passwordController,
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),
                        const SizedBox(height: 24),

                        // ✅ Login/Sign Up Button
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                            EmailAuthRequested(
                                              email: _emailController.text,
                                              password: _passwordController.text,
                                              isSignUp: _isSignUp,
                                            ),
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF32D27F),
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                elevation: 8,
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                            Colors.black),
                                      ),
                                    )
                                  : Text(
                                      _isSignUp ? 'Sign Up' : 'Login',
                                      style: const TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),

                        // Toggle between Login and Sign Up
                        TextButton(
                          onPressed: () {
                            context.read<AuthBloc>().add(
                                  ToggleAuthMode(!_isSignUp),
                                );
                          },
                          child: Text(
                            _isSignUp
                                ? 'Already have an account? Login'
                                : 'Don\'t have an account? Sign Up',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontFamily: 'Cairo',
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Row(
                          children: const [
                            Expanded(child: Divider(color: Colors.white30)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.white30)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 🔵 Google Sign In
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return ElevatedButton.icon(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                            GoogleSignInRequested(),
                                          );
                                    },
                              icon: Image.asset(
                                AppAssets.googleIcon,
                                width: 24,
                                height: 24,
                              ),
                              label: const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black87,
                                minimumSize: const Size.fromHeight(50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 5,
                              ),
                            );
                          },
                        ),
                      ],
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

  Widget _buildInputField({
    required String hintText,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontFamily: 'Cairo'),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF32D27F), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
