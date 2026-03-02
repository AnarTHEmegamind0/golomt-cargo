import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onFinish});

  final VoidCallback onFinish;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    (
      title: 'Track deliveries live',
      description: 'Real-time position updates and route hints in one glance.',
      icon: Icons.map_rounded,
    ),
    (
      title: 'Chat in-app',
      description: 'Coordinate with customers and restaurants without switching apps.',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    (
      title: 'Finish with proof',
      description: 'Attach handoff evidence and settle earnings faster.',
      icon: Icons.camera_alt_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: widget.onFinish, child: const Text('Skip')),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (value) => setState(() => _index = value),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.14),
                          child: Icon(slide.icon, size: 54),
                        ),
                        const SizedBox(height: 22),
                        Text(slide.title, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 8),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton(
                onPressed: () {
                  if (isLast) {
                    widget.onFinish();
                    return;
                  }
                  _controller.nextPage(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                  );
                },
                child: Text(isLast ? 'Get started' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
