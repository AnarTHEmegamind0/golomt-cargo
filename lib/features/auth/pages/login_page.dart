import 'package:core/features/auth/providers/auth_provider.dart';
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
            colors: [Color(0xFFF8F3EE), Color(0xFFF3ECE4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: const Color(0xFFE7DED5)),
                          ),
                          child: Text(
                            'Cargo App',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2A3348),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const _SplashPhoneMockup(),
                      const SizedBox(height: 22),
                      Text(
                        'Дэлхийг хаалгандаа\nхүлээж ав',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 39,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Захиалгын дугаараа бүртгэж, хүргэлтийн явцаа шууд хянаарай.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF677186),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        key: const ValueKey('login_submit'),
                        onPressed: isLoading
                            ? null
                            : () async {
                                await context.read<AuthProvider>().login(
                                  email: _emailController.text.trim(),
                                  password: _passwordController.text,
                                );
                              },
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          isLoading ? 'Нэвтэрч байна...' : 'Эхлэх',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          'Нэвтрэх',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: const Color(0xFF4F596F),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
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

class _SplashPhoneMockup extends StatelessWidget {
  const _SplashPhoneMockup();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(42),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A2233).withValues(alpha: 0.18),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 0.62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF111111),
            borderRadius: BorderRadius.circular(42),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFFF6EBDD),
                borderRadius: BorderRadius.circular(38),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '09:41',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF2C2C2C),
                              ),
                        ),
                        const Spacer(),
                        Container(
                          width: 90,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const _CourierArt(),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Хүргэлтээ\nудирдахад бэлэн',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              height: 1.08,
                            ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Трак кодоо оруулаад эхлээрэй.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF636C7E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourierArt extends StatelessWidget {
  const _CourierArt();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 20,
            bottom: 20,
            child: _BoxCube(size: 88, color: const Color(0xFFE8C389)),
          ),
          Positioned(
            right: 28,
            bottom: 48,
            child: _BoxCube(size: 70, color: const Color(0xFFDCAA66)),
          ),
          Positioned(
            left: 86,
            top: 10,
            child: Container(
              width: 110,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF2B3447),
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(
                Icons.delivery_dining_rounded,
                color: Color(0xFFFFD08C),
                size: 86,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoxCube extends StatelessWidget {
  const _BoxCube({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFB98D4F).withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
