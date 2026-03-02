import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).textTheme.bodyMedium;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Login', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text(
          'Sign in to curate and save your best references.',
          style: muted,
        ),
        const SizedBox(height: 18),
        Text('Email', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('login_email'),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'demo@demo.com',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Use your workspace email.',
          style: muted?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 14),
        Text('Password', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('login_password'),
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'password',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Minimum 8 characters recommended.',
          style: muted?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
