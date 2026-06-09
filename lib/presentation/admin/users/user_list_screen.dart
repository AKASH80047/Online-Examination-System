import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:exam_paper/user_providers.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/app_constants.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;
    final usersAsync = ref.watch(allUsersProvider);

    Widget buildBody() {
      return usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.people_outline, size: 56, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No Users Yet',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Users who sign up will appear here.',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allUsersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final isAdmin = user.role == UserRole.admin;
                final initial = user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => context.push(
                        RoutePaths.adminUserDetails.replaceAll(':uid', user.uid),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isAdmin
                                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                      : [const Color(0xFF4F46E5), const Color(0xFF7C3AED)],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1F2937),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.email,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Role badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: isAdmin
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.role.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isAdmin
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Change role
                            Tooltip(
                              message: 'Change Role',
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final newRole = await showDialog<UserRole>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text('Change Role: ${user.name}'),
                                      content: const Text(
                                        'Select a new role. This changes access permissions immediately.',
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, UserRole.user),
                                          child: const Text('USER'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.pop(context, UserRole.admin),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFEF4444),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('ADMIN'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (newRole != null && newRole != user.role) {
                                    await ref
                                        .read(userRepositoryProvider)
                                        .updateUserRole(user.uid, newRole);
                                    ref.invalidate(allUsersProvider);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Role updated to ${newRole.name.toUpperCase()} for ${user.name}',
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.swap_horiz, size: 18, color: Color(0xFF6B7280)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      );
    }

    if (isDesktop) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                backgroundColor: const Color(0xFFF9FAFB),
                appBar: const AdminAppBar(title: 'Manage Users', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: const AdminAppBar(title: 'Manage Users'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}
