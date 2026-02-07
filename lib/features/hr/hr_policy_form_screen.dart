import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/hr/hr_dashboard_cubit.dart';
import '../../models/hr_policy_model.dart';

class HRPolicyFormScreen extends StatefulWidget {
  final HRPolicyModel? policy; // null = create, not null = edit

  const HRPolicyFormScreen({super.key, this.policy});

  @override
  State<HRPolicyFormScreen> createState() => _HRPolicyFormScreenState();
}

class _HRPolicyFormScreenState extends State<HRPolicyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _pdfUrlController;
  late TextEditingController _categoryController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.policy?.title ?? '');
    _descriptionController = TextEditingController(text: widget.policy?.description ?? '');
    _pdfUrlController = TextEditingController(text: widget.policy?.pdfUrl ?? '');
    _categoryController = TextEditingController(text: widget.policy?.category ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pdfUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cubit = context.read<HRPolicyCubit>();

      if (widget.policy == null) {
        // Create
        await cubit.createPolicy(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          pdfUrl: _pdfUrlController.text.trim().isEmpty ? null : _pdfUrlController.text.trim(),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
        );
      } else {
        // Update
        await cubit.updatePolicy(
          id: widget.policy!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          pdfUrl: _pdfUrlController.text.trim().isEmpty ? null : _pdfUrlController.text.trim(),
          category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
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
    final theme = Theme.of(context);
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
            // Title
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Description
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
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(
                labelText: localizations.category,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.category),
                hintText: localizations.categoryHint,
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // PDF URL
            TextFormField(
              controller: _pdfUrlController,
              decoration: InputDecoration(
                labelText: localizations.pdfUrl,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.link),
                hintText: 'https://...',
              ),
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.policyFormHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save Button
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
