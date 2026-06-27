import 'package:flutter/material.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class RolesPermissionScreen extends StatelessWidget {
  const RolesPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 900;

    Widget buildBody() {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final headingColor = isDark ? Colors.white : const Color(0xFF1F2937);
      final subtitleColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF4B5563);
      final cardBg = Theme.of(context).cardTheme.color ?? (isDark ? const Color(0xFF111827) : Colors.white);
      final borderColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

      return ListView(
        padding: const EdgeInsets.all(32),
        children: [
          Text(
            'User Access Management',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: headingColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Check roles and standard access privileges configured for each registration type.',
            style: TextStyle(
              fontSize: 15,
              color: subtitleColor,
            ),
          ),
          const SizedBox(height: 32),
          Card(
            color: cardBg,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: borderColor, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Text(
                          'Capability / Privilege',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: headingColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Center(
                          child: Text(
                            'Student',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        child: Center(
                          child: Text(
                            'Admin',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: headingColor,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildTableRow(context, 'Take assigned tests / view results', true, true, isDark),
                  _buildTableRow(context, 'Manage exam bank (CRUD)', false, true, isDark),
                  _buildTableRow(context, 'Manage student registry', false, true, isDark),
                  _buildTableRow(context, 'Send notification alerts', false, true, isDark),
                  _buildTableRow(context, 'Export PDF academic report files', false, true, isDark),
                  _buildTableRow(context, 'System settings access', false, true, isDark),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                appBar: const AdminAppBar(title: 'Roles & Permissions', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AdminAppBar(title: 'Roles & Permissions'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }

  TableRow _buildTableRow(
    BuildContext context,
    String title,
    bool studentAllowed,
    bool adminAllowed,
    bool isDark,
  ) {
    final titleColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151);
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: titleColor,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Icon(
              studentAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: studentAllowed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Icon(
              adminAllowed ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: adminAllowed ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
