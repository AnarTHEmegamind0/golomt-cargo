import 'package:core/core/design_system/components/animated_background.dart';
import 'package:core/core/design_system/components/auth_text_field.dart';
import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Үйлчилгээний нөхцөлийг зөвшөөрнө үү'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    await context.read<AuthProvider>().signUp(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (mounted) {
      final error = context.read<AuthProvider>().error;
      if (error == null) {
        // Success - pop back (main.dart will auto-navigate to AppShellPage)
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final error = context.select((AuthProvider p) => p.error);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: MeshGradientBackground(
        child: Stack(
          children: [
            const FloatingShapes(shapeCount: 5),
            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Back button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A202C),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Буцах',
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF1A202C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(height: 20),
                                    // Logo
                                    _buildLogo(isDark),
                                    const SizedBox(height: 12),
                                    // Title
                                    Text(
                                      'Бүртгүүлэх',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: isDark
                                                ? Colors.white
                                                : const Color(0xFF1A202C),
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Шинэ бүртгэл үүсгэх',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: isDark
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    const SizedBox(height: 32),
                                    // Name field
                                    AuthTextField(
                                      label: 'Нэр',
                                      hint: 'Таны нэр',
                                      controller: _nameController,
                                      focusNode: _nameFocusNode,
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: Icons.person_outline,
                                      autofillHints: const [AutofillHints.name],
                                      validator: _validateName,
                                      onSubmitted: (_) {
                                        _emailFocusNode.requestFocus();
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Email field
                                    AuthTextField(
                                      label: 'Имэйл',
                                      hint: 'example@email.com',
                                      controller: _emailController,
                                      focusNode: _emailFocusNode,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: Icons.email_outlined,
                                      autofillHints: const [
                                        AutofillHints.email,
                                      ],
                                      validator: _validateEmail,
                                      onSubmitted: (_) {
                                        _passwordFocusNode.requestFocus();
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Password field
                                    AuthTextField(
                                      label: 'Нууц үг',
                                      hint: 'Хамгийн багадаа 8 тэмдэгт',
                                      controller: _passwordController,
                                      focusNode: _passwordFocusNode,
                                      obscureText: true,
                                      textInputAction: TextInputAction.next,
                                      prefixIcon: Icons.lock_outline,
                                      autofillHints: const [
                                        AutofillHints.newPassword,
                                      ],
                                      validator: _validatePassword,
                                      onSubmitted: (_) {
                                        _confirmPasswordFocusNode
                                            .requestFocus();
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    // Confirm password field
                                    AuthTextField(
                                      label: 'Нууц үг баталгаажуулах',
                                      hint: 'Нууц үгээ дахин оруулна уу',
                                      controller: _confirmPasswordController,
                                      focusNode: _confirmPasswordFocusNode,
                                      obscureText: true,
                                      textInputAction: TextInputAction.done,
                                      prefixIcon: Icons.lock_outline,
                                      validator: _validateConfirmPassword,
                                      onSubmitted: (_) => _handleSignUp(),
                                    ),
                                    const SizedBox(height: 20),
                                    // Terms checkbox
                                    _buildTermsCheckbox(isDark),
                                    const SizedBox(height: 8),
                                    // Error message
                                    if (error != null)
                                      _buildErrorMessage(error, isDark),
                                    const SizedBox(height: 16),
                                    // Sign up button
                                    AuthButton(
                                      label: 'Бүртгүүлэх',
                                      onPressed: _handleSignUp,
                                      isLoading: isLoading,
                                      icon: Icons.person_add_rounded,
                                    ),
                                    const SizedBox(height: 24),
                                    // Already have account
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Бүртгэлтэй юу?',
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF9CA3AF)
                                                : const Color(0xFF6B7280),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: Text(
                                            'Нэвтрэх',
                                            style: TextStyle(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 40),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
      width: 72,
      height: 72,
      margin: const EdgeInsets.only(bottom: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size: 36,
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _acceptedTerms,
            onChanged: (value) {
              setState(() => _acceptedTerms = value ?? false);
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _acceptedTerms = !_acceptedTerms);
            },
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF9CA3AF)
                      : const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  const TextSpan(text: 'Би '),
                  TextSpan(
                    text: 'үйлчилгээний нөхцөл',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' болон '),
                  TextSpan(
                    text: 'нууцлалын бодлого',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: '-г зөвшөөрч байна'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage(String error, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Нэр оруулна уу';
    }
    if (value.trim().length < 2) {
      return 'Нэр хамгийн багадаа 2 тэмдэгт байх ёстой';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Имэйл хаяг оруулна уу';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Зөв имэйл хаяг оруулна уу';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Нууц үг оруулна уу';
    }
    if (value.length < 8) {
      return 'Нууц үг хамгийн багадаа 8 тэмдэгт байх ёстой';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Нууц үгээ баталгаажуулна уу';
    }
    if (value != _passwordController.text) {
      return 'Нууц үг таарахгүй байна';
    }
    return null;
  }
}
