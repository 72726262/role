import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/it/it_dashboard_cubit.dart';
import '../../models/it_policy_model.dart';

class ITPolicyFormScreen extends StatefulWidget {
  final ITPolicyModel? policy;

  const ITPolicyFormScreen({super.key, this.policy});

  @override
  State<ITPolicyFormScreen> createState() => _ITPolicyFormScreenState();
}

class _ITPolicyFormScreenState extends State<ITPolicyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _pdfUrlController;
  String? _selectedType;
  bool _isLoading = false;

  final List<String> _policyTypes = ['security', 'usage', 'compliance', 'other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.policy?.title ?? '');
    _descriptionController = TextEditingController(text: widget.policy?.description ?? '');
    _pdfUrlController = TextEditingController(text: widget.policy?.pdfUrl ?? '');
    _selectedType = widget.policy?.policyType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pdfUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cubit = context.read<ITPolicyCubit>();

      if (widget.policy == null) {
        await cubit.createPolicy(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          policyType: _selectedType,
          pdfUrl: _pdfUrlController.text.trim().isEmpty ? null : _pdfUrlController.text.trim(),
        );
      } else {
        await cubit.updatePolicy(
          id: widget.policy!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          policyType: _selectedType,
          pdfUrl: _pdfUrlController.text.trim().isEmpty ? null : _pdfUrlController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEdit = widget.policy != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? localizations.editPolicy : localizations.addPolicy),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '${localizations.title} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '${localizations.description} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedType,
              decoration: InputDecoration(
                labelText: localizations.policyType,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
              ),
              items: _policyTypes.map((type) {
                IconData icon = Icons.policy;
                switch (type) {
                  case 'security':
                    icon = Icons.security;
                    break;
                  case 'usage':
                    icon = Icons.computer;
                    break;
                  case 'compliance':
                    icon = Icons.verified_user;
                    break;
                  case 'other':
                    icon = Icons.help_outline;
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 12),
                      Text(type.toUpperCase()),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pdfUrlController,
              decoration: InputDecoration(
                labelText: localizations.pdfUrl,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: isEdit ? localizations.update : localizations.create,
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
              icon: isEdit ? Icons.save : Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
