import 'package:core/features/profile/providers/profile_provider.dart';
import 'package:core/features/profile/widgets/profile_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.select((ProfileProvider p) => p.profile);
    final isLoading = context.select((ProfileProvider p) => p.isLoading);
    final error = context.select((ProfileProvider p) => p.error);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            if (profile == null && !isLoading && error == null)
              FilledButton(
                onPressed: context.read<ProfileProvider>().load,
                child: const Text('Load profile'),
              )
            else if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null)
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            else
              ProfileCard(profile: profile!),
          ],
        ),
      ),
    );
  }
}
