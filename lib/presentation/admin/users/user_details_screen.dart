import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/user_providers.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/user_model.dart';

class UserDetailsScreen extends ConsumerWidget {
  final String uid;
  const UserDetailsScreen({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile Details'),
      ),
      body: usersAsync.when(
        data: (users) {
          final user = users.firstWhere(
            (u) => u.uid == uid,
            orElse: () => UserModel(uid: uid, email: 'unknown@email.com', name: 'Unknown User', role: UserRole.user),
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: user.role == UserRole.admin
                              ? Colors.purple.withValues(alpha: 0.1)
                              : Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role == UserRole.admin ? 'Administrator' : 'Student',
                          style: TextStyle(
                            color: user.role == UserRole.admin ? Colors.purple : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security, color: Colors.blue),
                      title: const Text('Change User Role'),
                      subtitle: Text('Promote student to Admin or vice versa'),
                      trailing: DropdownButton<UserRole>(
                        value: user.role,
                        underline: const SizedBox(),
                        items: UserRole.values
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                        onChanged: (newRole) async {
                          if (newRole != null && newRole != user.role) {
                            await ref.read(userRepositoryProvider).updateUserRole(user.uid, newRole);
                            ref.invalidate(allUsersProvider);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User role updated successfully')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.bar_chart_outlined, color: Colors.green),
                      title: const Text('Academic Performance'),
                      subtitle: const Text('View score history, certificates, and metrics'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => context.push(
                        RoutePaths.adminUserPerformance.replaceAll(':uid', uid),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Account Info',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('User ID', user.uid),
                      const Divider(height: 24),
                      _buildInfoRow('Login Status', 'Active (Single Session Restrictions Applied)'),
                      const Divider(height: 24),
                      _buildInfoRow('Created Date', 'June 01, 2026'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
