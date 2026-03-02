import 'package:core/features/auth/providers/auth_provider.dart';
import 'package:core/features/auth/widgets/login_form.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'demo@demo.com');
  final _passwordController = TextEditingController(text: 'password');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select((AuthProvider p) => p.isLoading);
    final error = context.select((AuthProvider p) => p.error);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F1EC), Color(0xFFF2E9E2)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 920;

              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1040),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF191312).withValues(alpha: 0.08),
                            blurRadius: 28,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: wide
                            ? Row(
                                children: [
                                  const Expanded(child: _MoodPanel()),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: _AuthPanel(
                                      emailController: _emailController,
                                      passwordController: _passwordController,
                                      isLoading: isLoading,
                                      error: error,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const _MoodPanel(),
                                  const SizedBox(height: 18),
                                  _AuthPanel(
                                    emailController: _emailController,
                                    passwordController: _passwordController,
                                    isLoading: isLoading,
                                    error: error,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.error,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFE8DED7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginForm(
            emailController: emailController,
            passwordController: passwordController,
          ),
          const SizedBox(height: 18),
          FilledButton(
            key: const ValueKey('login_submit'),
            onPressed: isLoading
                ? null
                : () async {
                    await context.read<AuthProvider>().login(
                      email: emailController.text.trim(),
                      password: passwordController.text,
                    );
                  },
            child: Text(isLoading ? 'Signing in...' : 'Sign in'),
          ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(
              error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoodPanel extends StatelessWidget {
  const _MoodPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD2455F), Color(0xFFB53049)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PinCargo',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Collect ideas, track references, and keep inspiration structured.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 18),
          const _MoodTile(
            title: 'Pinned this hour',
            value: '34',
            note: 'fresh references added by your team',
          ),
          const SizedBox(height: 10),
          const _MoodTile(
            title: 'Boards updated',
            value: '9',
            note: 'interiors, campaign, style and studio',
          ),
        ],
      ),
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile({
    required this.title,
    required this.value,
    required this.note,
  });

  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.push_pin_rounded, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$title • $value',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
