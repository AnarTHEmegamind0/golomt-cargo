import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProfileProvider>();
      if (provider.profile == null && !provider.isLoading) {
        provider.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileProvider p) => p.profile);
    final isLoading = context.select((ProfileProvider p) => p.isLoading);
    final error = context.select((ProfileProvider p) => p.error);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        children: [
          Text('Profile', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(
            'Driver identity, performance, and vehicle details.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: CircularProgressIndicator(),
            ))
          else if (error != null)
            Text(
              error,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (profile != null)
            ProfileCard(profile: profile)
          else
            FilledButton(
              onPressed: context.read<ProfileProvider>().load,
              child: const Text('Load profile'),
            ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: const Color(0xFFB6364C).withValues(alpha: 0.14),
                    ),
                    child: const Icon(Icons.two_wheeler_rounded),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Yamaha NMAX 155 • plate 48-91 УБГ',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
