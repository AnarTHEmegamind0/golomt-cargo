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
        Text('Нэвтрэх', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        Text('Өөрийн бүртгэлээр нэвтэрч захиалгаа удирдана уу.', style: muted),
        const SizedBox(height: 18),
        Text('Имэйл', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('login_email'),
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            hintText: 'хэрэглэгч@жишээ.мн',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Бүртгэлтэй имэйл хаягаа ашиглана уу.',
          style: muted?.copyWith(fontSize: 12),
        ),
        const SizedBox(height: 14),
        Text('Нууц үг', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 6),
        TextField(
          key: const ValueKey('login_password'),
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: '••••••••',
            prefixIcon: Icon(Icons.lock_outline_rounded),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Хамгийн багадаа 8 тэмдэгттэй байхыг зөвлөж байна.',
          style: muted?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}
