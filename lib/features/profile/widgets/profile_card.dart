import 'package:core/features/profile/models/profile.dart';
import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE4DBD4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFCD405A), Color(0xFF9D233C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(Icons.person_rounded, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(profile.email, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (index) => const Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('4.92', style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: _Metric(title: 'Completed', value: '286')),
              Expanded(child: _Metric(title: 'Acceptance', value: '93.4%')),
              Expanded(child: _Metric(title: 'On-time', value: '97.1%')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(title, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
