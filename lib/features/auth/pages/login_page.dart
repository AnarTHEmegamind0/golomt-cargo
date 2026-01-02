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
      appBar: AppBar(title: const Text('Login')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LoginForm(
                emailController: _emailController,
                passwordController: _passwordController,
              ),
              const SizedBox(height: 16),
              FilledButton(
                key: const ValueKey('login_submit'),
                onPressed: isLoading
                    ? null
                    : () async {
                        await context.read<AuthProvider>().login(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                child: Text(isLoading ? 'Signing in…' : 'Sign in'),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
