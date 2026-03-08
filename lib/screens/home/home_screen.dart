import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listing_provider.dart';
import '../../providers/navigation_provider.dart';
import '../login.dart';
import '../directory/directory_screen.dart';
import '../my_listings/my_listings_screen.dart';
import '../map_view/map_view_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final authState = ref.watch(authNotifierProvider);

    // List of screens
    final screens = [
      const DirectoryScreen(),
      const MyListingsScreen(),
      const MapViewScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      drawer: _buildDrawer(context, ref, authState),
      appBar: AppBar(
        title: const Text('Kigali City Directory'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh based on current tab
              if (currentIndex == 1) {
                // My Listings - load user's listings
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  ref
                      .read(listingNotifierProvider.notifier)
                      .loadUserListings(user.uid);
                }
              } else {
                // Directory or other - load all listings
                ref.read(listingNotifierProvider.notifier).loadAllListings();
              }
            },
          ),
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(bottomNavIndexProvider.notifier).setIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Directory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map View'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final user = authState.user;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.green),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 35, color: Colors.green),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.displayName ?? user?.email ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.library_books, color: Colors.green),
            title: const Text('Directory'),
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).setIndex(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Colors.green),
            title: const Text('My Listings'),
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).setIndex(1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.map, color: Colors.green),
            title: const Text('Map View'),
            onTap: () {
              ref.read(bottomNavIndexProvider.notifier).setIndex(2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              // Clear listings before logout so next user doesn't see old data
              ref.read(listingNotifierProvider.notifier).clearListings();
              await ref.read(authNotifierProvider.notifier).signOut();
              // Reset navigation index to 0 (Directory)
              ref.read(bottomNavIndexProvider.notifier).setIndex(0);
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

