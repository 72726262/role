import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../services/database_service.dart';
import '../../services/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

/// ✍️ Create News Screen
/// Premium UI for creating and publishing news

class CreateNewsScreen extends StatefulWidget {
  final String? newsId; // For editing existing news

  const CreateNewsScreen({super.key, this.newsId});

  @override
  State<CreateNewsScreen> createState() => _CreateNewsScreenState();
}

class _CreateNewsScreenState extends State<CreateNewsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _selectedCategory = 'announcement';
  String _selectedPriority = 'normal';
  bool _isPublished = true;
  bool _isLoading = false;
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];

  final List<Map<String, dynamic>> _categories = [
    {'value': 'announcement', 'label': 'إعلان', 'icon': Icons.campaign},
    {'value': 'event', 'label': 'فعالية', 'icon': Icons.event},
    {'value': 'update', 'label': 'تحديث', 'icon': Icons.info},
    {'value': 'achievement', 'label': 'إنجاز', 'icon': Icons.emoji_events},
  ];

  final List<Map<String, dynamic>> _priorities = [
    {'value': 'low', 'label': 'منخفضة', 'color': Colors.blue},
    {'value': 'normal', 'label': 'عادية', 'color': Colors.green},
    {'value': 'high', 'label': 'عالية', 'color': Colors.orange},
    {'value': 'urgent', 'label': 'عاجلة', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _imagePicker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages = images.map((e) => File(e.path)).toList();
      });
    }
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    final storageService = StorageService();
    _uploadedImageUrls.clear();

    for (var image in _selectedImages) {
      try {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
        final url = await storageService.uploadFile(
          image,
          'news',
          'images/$fileName',
        );
        _uploadedImageUrls.add(url);
      } catch (e) {
        // Handle error
      }
    }
  }

  Future<void> _saveNews() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Upload images first
      await _uploadImages();

      final dbService = DatabaseService();
      final user = Supabase.instance.client.auth.currentUser;

      final newsData = {
        'title': _titleController.text.trim(),
        'content': _contentController.text.trim(),
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'is_published': _isPublished,
        'author_id': user?.id,
        'image_urls': _uploadedImageUrls,
        'created_at': DateTime.now().toIso8601String(),
      };

      if (widget.newsId != null) {
        // Update existing
        await dbService.update('news', widget.newsId!, newsData);
      } else {
        // Create new
        await dbService.create('news', newsData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.newsId != null ? 'تم التحديث بنجاح' : 'تم النشر بنجاح',
            ),
            backgroundColor: AppColors.accentLight,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 100,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.newsId != null ? 'تعديل الخبر' : 'إنشاء خبر جديد',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                    ),
                  ),
                ),
              ),

              // Form
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title Field
                          GlassmorphicCard(
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'عنوان الخبر',
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

                          // Content Field
                          GlassmorphicCard(
                            child: TextFormField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                labelText: 'المحتوى',
                                prefixIcon: Icon(Icons.description),
                                border: InputBorder.none,
                              ),
                              maxLines: 10,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال المحتوى';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Category Selection
                          _buildLabel('التصنيف'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassmorphicCard(
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              children: _categories.map((cat) {
                                final isSelected =
                                    _selectedCategory == cat['value'];
                                return FilterChip(
                                  selected: isSelected,
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(cat['icon'], size: 16),
                                      const SizedBox(width: 4),
                                      Text(cat['label']),
                                    ],
                                  ),
                                  onSelected: (_) {
                                    setState(
                                        () => _selectedCategory = cat['value']);
                                  },
                                  backgroundColor: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surfaceLight,
                                  selectedColor: AppColors.primaryLight,
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Priority Selection
                          _buildLabel('الأولوية'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassmorphicCard(
                            child: Wrap(
                              spacing: AppSpacing.sm,
                              children: _priorities.map((priority) {
                                final isSelected =
                                    _selectedPriority == priority['value'];
                                return FilterChip(
                                  selected: isSelected,
                                  label: Text(priority['label']),
                                  onSelected: (_) {
                                    setState(() =>
                                        _selectedPriority = priority['value']);
                                  },
                                  backgroundColor: isDark
                                      ? AppColors.surfaceDark
                                      : AppColors.surfaceLight,
                                  selectedColor: priority['color'],
                                );
                              }).toList(),
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Images
                          _buildLabel('الصور'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassmorphicCard(
                            onTap: _pickImages,
                            child: Column(
                              children: [
                                if (_selectedImages.isEmpty)
                                  Column(
                                    children: [
                                      Icon(
                                        Icons.add_photo_alternate,
                                        size: 48,
                                        color: theme.iconTheme.color,
                                      ),
                                      const SizedBox(height: AppSpacing.sm),
                                      const Text('اضغط لإضافة صور'),
                                    ],
                                  )
                                else
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _selectedImages.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8),
                                          child: Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Image.file(
                                                  _selectedImages[index],
                                                  width: 100,
                                                  height: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              Positioned(
                                                top: 4,
                                                left: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedImages
                                                          .removeAt(index);
                                                    });
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(height: AppSpacing.lg),

                          // Publish Toggle
                          GlassmorphicCard(
                            child: SwitchListTile(
                              title: const Text('نشر فوراً'),
                              subtitle: Text(
                                _isPublished
                                    ? 'سيتم نشر الخبر للموظفين'
                                    : 'حفظ كمسودة',
                              ),
                              value: _isPublished,
                              onChanged: (value) {
                                setState(() => _isPublished = value);
                              },
                            ),
                          ),

                          const SizedBox(height: AppSpacing.xxl),

                          // Submit Button
                          AnimatedButton(
                            text: widget.newsId != null ? 'تحديث' : 'نشر',
                            icon: Icons.publish,
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _saveNews,
                            width: double.infinity,
                          ),

                          const SizedBox(height: AppSpacing.xxl),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }
}
