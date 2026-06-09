import 'package:flutter/material.dart';

class RolesPermissionScreen extends StatelessWidget {
  const RolesPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles & Permissions Matrix'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'User Access Management',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Check roles and standard access privileges configured for each registration type.'),
          const SizedBox(height: 24),
          Table(
            border: TableBorder.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                children: const [
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('Capability / Privilege', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: Text('Student', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: Text('Admin', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ],
              ),
              _buildTableRow('Take assigned tests / view results', true, true),
              _buildTableRow('Manage exam bank (CRUD)', false, true),
              _buildTableRow('Manage student registry', false, true),
              _buildTableRow('Send notification alerts', false, true),
              _buildTableRow('Export PDF academic report files', false, true),
              _buildTableRow('System settings access', false, true),
            ],
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String title, bool studentAllowed, bool adminAllowed) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(title, style: const TextStyle(fontSize: 13)),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              studentAllowed ? Icons.check_circle : Icons.cancel,
              color: studentAllowed ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              adminAllowed ? Icons.check_circle : Icons.cancel,
              color: adminAllowed ? Colors.green : Colors.red,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}
