import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// ✏️ Compose Message Screen
/// Create and send messages to employees

class ComposeMessageScreen extends StatefulWidget {
  final String? messageId; // For editing

  const ComposeMessageScreen({super.key, this.messageId});

  @override
  State<ComposeMessageScreen> createState() => _ComposeMessageScreenState();
}

class _ComposeMessageScreenState extends State<ComposeMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();
  
  String _selectedRole = 'all';
  bool _isImportant = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _attachments = [];
  List<File> _selectedFiles = [];

  final List<Map<String, String>> _roles = [
    {'value': 'all', 'label': 'الجميع'},
    {'value': 'Employee', 'label': 'الموظفين'},
    {'value': 'HR', 'label': 'الموارد البشرية'},
    {'value': 'IT', 'label': 'تقنية المعلومات'},
    {'value': 'Management', 'label': 'الإدارة'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickAttachments() async {
    final List<XFile> files = await _imagePicker.pickMultiImage();
    if (files.isNotEmpty) {
      setState(() {
        _selectedFiles = files.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _uploadAttachments() async {
    if (_selectedFiles.isEmpty) return;

    final storageService = StorageService();
    _attachments.clear();

    for (var file in _selectedFiles) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        final url = await storageService.uploadFile(
          file,
          'messages',
          'attachments/$fileName',
        );
        _attachments.add({
          'type': 'image',
          'url': url,
          'title': file.path.split('/').last,
        });
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _uploadAttachments();

      final user = Supabase.instance.client.auth.currentUser;
      final dbService = DatabaseService();

      final messageData = {
        'sender_id': user?.id,
        'receiver_role': _selectedRole,
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'attachments': _attachments,
        'is_important': _isImportant,
        'created_at': DateTime.now().toIso8601String(),
      };

      await dbService.create('messages', messageData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إرسال الرسالة بنجاح'),
            backgroundColor: AppColors.accentLight,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: AppColors.accentError,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackgroundGradient
              : AppGradients.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'رسالة جديدة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Recipient Role
                        GlassmorphicCard(
                          child: DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: const InputDecoration(
                              labelText: 'المستلمون',
                              prefixIcon: Icon(Icons.people),
                              border: InputBorder.none,
                            ),
                            items: _roles.map((role) {
                              return DropdownMenuItem(
                                value: role['value'],
                                child: Text(role['label']!),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedRole = value);
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Title
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'العنوان',
                              prefixIcon: Icon(Icons.title),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال العنوان';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Content
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _contentController,
                            decoration: const InputDecoration(
                              labelText: 'المحتوى',
                              prefixIcon: Icon(Icons.message),
                              border: InputBorder.none,
                            ),
                            maxLines: 8,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال المحتوى';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Important Toggle
                        GlassmorphicCard(
                          child: SwitchListTile(
                            title: const Text('رسالة هامة'),
                            subtitle: const Text('سيتم تمييز الرسالة للمستلمين'),
                            value: _isImportant,
                            onChanged: (value) {
                              setState(() => _isImportant = value);
                            },
                            secondary: Icon(
                              Icons.priority_high,
                              color: _isImportant ? AppColors.accentError : null,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Attachments
                        GlassmorphicCard(
                          onTap: _pickAttachments,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.attach_file),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Text('المرفقات'),
                                ],
                              ),
                              if (_selectedFiles.isNotEmpty) ...[
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: _selectedFiles.map((file) {
                                    return Chip(
                                      label: Text(
                                        file.path.split('/').last,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 16),
                                      onDeleted: () {
                                        setState(() {
                                          _selectedFiles.remove(file);
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Send Button
                        AnimatedButton(
                          text: 'إرسال',
                          icon: Icons.send,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _sendMessage,
                          width: double.infinity,
                          gradient: AppGradients.primaryGradient,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
