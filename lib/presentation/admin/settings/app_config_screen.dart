import 'package:flutter/material.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_appbar.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_drawer.dart';
import 'package:exam_paper/presentation/admin/widgets/admin_sidebar.dart';

class AppConfigScreen extends StatefulWidget {
  const AppConfigScreen({super.key});

  @override
  State<AppConfigScreen> createState() => _AppConfigScreenState();
}

class _AppConfigScreenState extends State<AppConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _maintenanceMode = false;
  bool _oneDeviceRestriction = true;
  final _firebaseTimeoutController = TextEditingController(text: '30');

  @override
  void dispose() {
    _firebaseTimeoutController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuration saved successfully!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

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

      return Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            Text(
              'Global Parameters',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: headingColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Manage technical parameters, timeout bounds, and platform operational modes.',
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: Text(
                        'Maintenance Operational Mode',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'Blocks user dashboards showing a maintenance notice page',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      value: _maintenanceMode,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(height: 32),
                    SwitchListTile(
                      title: Text(
                        'Single-Session Device Restriction',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: headingColor,
                          fontSize: 15,
                        ),
                      ),
                      subtitle: Text(
                        'Restricts examinee profile logins to one active device',
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 12,
                        ),
                      ),
                      value: _oneDeviceRestriction,
                      onChanged: (val) => setState(() => _oneDeviceRestriction = val),
                    ),
                    const Divider(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextFormField(
                        controller: _firebaseTimeoutController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: headingColor),
                        decoration: InputDecoration(
                          labelText: 'Firebase Query Timeout (seconds)',
                          labelStyle: TextStyle(color: subtitleColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (v) => v!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _save,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Parameters',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            const AdminSidebar(),
            Expanded(
              child: Scaffold(
                appBar: const AdminAppBar(title: 'Application Config', showLeading: false),
                body: buildBody(),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: const AdminAppBar(title: 'Application Config'),
      drawer: const AdminDrawer(),
      body: buildBody(),
    );
  }
}
