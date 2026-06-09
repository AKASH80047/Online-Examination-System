import 'package:flutter/material.dart';

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
      const SnackBar(content: Text('Configuration saved successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Config'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Global Parameters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Manage technical parameters, timeout bounds, and platform operational modes.'),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Maintenance Operational Mode'),
                      subtitle: const Text('Blocks user dashboards showing a maintenance notice page'),
                      value: _maintenanceMode,
                      onChanged: (val) => setState(() => _maintenanceMode = val),
                    ),
                    const Divider(height: 16),
                    SwitchListTile(
                      title: const Text('Single-Session Device Restriction'),
                      subtitle: const Text('Restricts examinee profile logins to one active device'),
                      value: _oneDeviceRestriction,
                      onChanged: (val) => setState(() => _oneDeviceRestriction = val),
                    ),
                    const Divider(height: 16),
                    TextFormField(
                      controller: _firebaseTimeoutController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Firebase Query Timeout (seconds)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _save,
                        child: const Text('Save Parameters'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
