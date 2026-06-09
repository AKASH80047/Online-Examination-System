import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/auth_providers.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/user_providers.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFE0E7FF),
              child: Icon(Icons.person, size: 50, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(height: 24),
            Text(
              user?.name ?? 'Student',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'student@example.com',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 48),
            if (user != null)
              OutlinedButton.icon(
                onPressed: () async {
                  final newRole = user.role == UserRole.admin ? UserRole.user : UserRole.admin;
                  try {
                    await ref.read(userRepositoryProvider).updateUserRole(user.uid, newRole);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Role changed to $newRole. Please wait a moment...')),
                      );
                    }
                    // Force refresh auth state so the router redirects
                    ref.invalidate(authStateProvider);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error updating role: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.developer_mode, color: Colors.deepPurple),
                label: Text(
                  user.role == UserRole.admin
                      ? 'Developer: Switch to Student'
                      : 'Developer: Switch to Admin',
                  style: const TextStyle(color: Colors.deepPurple),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
