import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:full_stack_e_commerce_app/core/theme.dart';
import 'package:full_stack_e_commerce_app/features/auth/providers/auth_provider.dart';
import 'package:full_stack_e_commerce_app/features/profile/pages/edit_profile_page.dart';
import '../providers/client_profile_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(clientProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.ivory,
        elevation: 0,
      ),
      backgroundColor: AppTheme.ivory,
      body: profileAsync.when(
        data: (client) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.goldTint,
                child: Text(
                  client.name.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    color: AppTheme.primaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              Text(
                client.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),

              // Email
              Text(
                client.email ?? 'No email',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 6),

              // Phone
              Text(
                client.phone,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(color: AppTheme.secondaryText),
              ),
              const SizedBox(height: 16),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.gold,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfilePage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Spacer(),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryText,
                    foregroundColor: AppTheme.pureWhite,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Logout',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.gold),
        ),
        error: (err, _) => Center(
          child: Text(
            'Error loading profile: $err',
            style: TextStyle(color: AppTheme.primaryText),
          ),
        ),
      ),
    );
  }
}
