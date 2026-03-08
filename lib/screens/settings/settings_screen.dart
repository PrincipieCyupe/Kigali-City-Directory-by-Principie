import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/navigation_provider.dart';
import '../login.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final settingsState = ref.watch(settingsNotifierProvider);
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Settings'),
              background: Container(
                color: Colors.green,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 45, color: Colors.green),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.displayName ?? user?.email ?? 'User',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.email != null)
                      Text(
                        user!.email!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  const Text(
                    'Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.person,
                            color: Colors.green,
                          ),
                          title: const Text('Name'),
                          subtitle: Text(user?.displayName ?? 'Not set'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.green),
                          title: const Text('Email'),
                          subtitle: Text(user?.email ?? 'Not set'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.verified,
                            color: Colors.green,
                          ),
                          title: const Text('Email Verified'),
                          subtitle: Text(
                            user?.emailVerified == true
                                ? 'Yes'
                                : 'No - Check your inbox',
                          ),
                          trailing: user?.emailVerified == false
                              ? TextButton(
                                  onPressed: () async {
                                    await user?.sendEmailVerification();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Verification email sent!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Text('Verify'),
                                )
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications Section
                  const Text(
                    'Notifications',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SwitchListTile(
                      secondary: const Icon(
                        Icons.notifications,
                        color: Colors.green,
                      ),
                      title: const Text('Location Notifications'),
                      subtitle: const Text(
                        'Get notified about nearby locations',
                      ),
                      value: settingsState.notificationsEnabled,
                      onChanged: (value) {
                        ref
                            .read(settingsNotifierProvider.notifier)
                            .toggleNotifications();
                      },
                      activeColor: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // About Section
                  const Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.green),
                          title: const Text('App Version'),
                          subtitle: const Text('1.0.0'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.description,
                            color: Colors.green,
                          ),
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to terms
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Icons.privacy_tip,
                            color: Colors.green,
                          ),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // Navigate to privacy
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text(
                              'Are you sure you want to logout?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          // Clear listings before logout so next user doesn't see old data
                          ref
                              .read(listingNotifierProvider.notifier)
                              .clearListings();
                          await ref
                              .read(authNotifierProvider.notifier)
                              .signOut();
                          // Reset navigation index to 0
                          ref.read(bottomNavIndexProvider.notifier).setIndex(0);
                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Login(),
                              ),
                              (route) => false,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

