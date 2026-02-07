import 'package:employee_portal/cubits/admin/news_management_cubit.dart';
import 'package:employee_portal/cubits/admin/news_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';

import '../../models/news_model.dart';
import 'create_news_screen.dart';

/// 📰 News Management Screen
/// Comprehensive news management for Admin

class NewsManagementScreen extends StatefulWidget {
  const NewsManagementScreen({super.key});

  @override
  State<NewsManagementScreen> createState() => _NewsManagementScreenState();
}

class _NewsManagementScreenState extends State<NewsManagementScreen> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'all';
  String _selectedStatus = 'all';
  String _selectedPriority = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NewsManagementCubit>().loadNews();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              _buildHeader(isDark),
              _buildFilters(isDark),
              Expanded(
                child: BlocBuilder<NewsManagementCubit, NewsManagementState>(
                  builder: (context, state) {
                    if (state is NewsManagementError) {
                      return _buildError(state.message);
                    }

                    final news =
                        state is NewsManagementLoaded ? state.news : _mockNews;
                    final isLoading = state is NewsManagementLoading;

                    final filteredNews = _filterNews(news);

                    return Skeletonizer(
                      enabled: isLoading,
                      child: filteredNews.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => context
                                  .read<NewsManagementCubit>()
                                  .loadNews(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: filteredNews.length,
                                itemBuilder: (context, index) {
                                  return _buildNewsCard(
                                    filteredNews[index],
                                    isDark,
                                    isLoading,
                                  );
                                },
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToCreateNews(),
        icon: const Icon(Icons.add),
        label: const Text('نشر خبر'),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: AppGradients.primaryGradient,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'إدارة الأخبار',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<NewsManagementCubit, NewsManagementState>(
            builder: (context, state) {
              if (state is NewsManagementLoaded) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    '${state.news.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Search
          GlassmorphicCard(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث في الأخبار...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Status Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('الحالة: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFilterChip(
                    'all', 'الكل', Icons.all_inclusive, _selectedStatus, (v) {
                  setState(() => _selectedStatus = v);
                }),
                _buildFilterChip(
                    'published', 'منشور', Icons.check_circle, _selectedStatus,
                    (v) {
                  setState(() => _selectedStatus = v);
                }),
                _buildFilterChip('draft', 'مسودة', Icons.edit, _selectedStatus,
                    (v) {
                  setState(() => _selectedStatus = v);
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Category Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('التصنيف: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFilterChip(
                    'all', 'الكل', Icons.all_inclusive, _selectedCategory, (v) {
                  setState(() => _selectedCategory = v);
                }),
                _buildFilterChip(
                    'announcement', 'إعلان', Icons.campaign, _selectedCategory,
                    (v) {
                  setState(() => _selectedCategory = v);
                }),
                _buildFilterChip(
                    'event', 'فعالية', Icons.event, _selectedCategory, (v) {
                  setState(() => _selectedCategory = v);
                }),
                _buildFilterChip(
                    'update', 'تحديث', Icons.info, _selectedCategory, (v) {
                  setState(() => _selectedCategory = v);
                }),
                _buildFilterChip('achievement', 'إنجاز', Icons.emoji_events,
                    _selectedCategory, (v) {
                  setState(() => _selectedCategory = v);
                }),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Priority Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                const Text('الأولوية: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                _buildFilterChip(
                    'all', 'الكل', Icons.all_inclusive, _selectedPriority, (v) {
                  setState(() => _selectedPriority = v);
                }),
                _buildFilterChip(
                    'low', 'منخفضة', Icons.arrow_downward, _selectedPriority,
                    (v) {
                  setState(() => _selectedPriority = v);
                }, color: Colors.blue),
                _buildFilterChip(
                    'normal', 'عادية', Icons.remove, _selectedPriority, (v) {
                  setState(() => _selectedPriority = v);
                }, color: Colors.green),
                _buildFilterChip(
                    'high', 'عالية', Icons.arrow_upward, _selectedPriority,
                    (v) {
                  setState(() => _selectedPriority = v);
                }, color: Colors.orange),
                _buildFilterChip(
                    'urgent', 'عاجلة', Icons.priority_high, _selectedPriority,
                    (v) {
                  setState(() => _selectedPriority = v);
                }, color: Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String value,
    String label,
    IconData icon,
    String selectedValue,
    Function(String) onSelected, {
    Color? color,
  }) {
    final isSelected = selectedValue == value;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
        onSelected: (_) => onSelected(value),
        backgroundColor: color?.withOpacity(0.1) ?? AppColors.surfaceLight,
        selectedColor: color ?? AppColors.primaryLight,
      ),
    );
  }

  Widget _buildNewsCard(NewsModel news, bool isDark, bool isLoading) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              // Category Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: _getCategoryColor(news.category).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(
                  _getCategoryIcon(news.category),
                  color: _getCategoryColor(news.category),
                  size: 20,
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(news.createdAt),
                      style: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Priority Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(news.priority).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPriorityIcon(news.priority),
                      color: _getPriorityColor(news.priority),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getPriorityLabel(news.priority),
                      style: TextStyle(
                        color: _getPriorityColor(news.priority),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Content Preview
          Text(
            news.content,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.grey[300] : Colors.grey[700],
              fontSize: 14,
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Status & Actions Row
          Row(
            children: [
              // Published Status
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: news.isPublished
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      news.isPublished ? Icons.check_circle : Icons.edit,
                      color: news.isPublished ? Colors.green : Colors.orange,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      news.isPublished ? 'منشور' : 'مسودة',
                      style: TextStyle(
                        color: news.isPublished ? Colors.green : Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Edit Button
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: isLoading ? null : () => _navigateToEditNews(news),
                color: AppColors.primaryLight,
              ),

              // Delete Button
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: isLoading ? null : () => _confirmDelete(news),
                color: AppColors.accentError,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد أخبار',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ابدأ بنشر الأخبار للموظفين',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.accentError,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.accentError,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedButton(
            text: 'إعادة المحاولة',
            icon: Icons.refresh,
            onPressed: () => context.read<NewsManagementCubit>().loadNews(),
          ),
        ],
      ),
    );
  }

  List<NewsModel> _filterNews(List<NewsModel> news) {
    var filtered = news;

    // Filter by status
    if (_selectedStatus != 'all') {
      final isPublished = _selectedStatus == 'published';
      filtered = filtered.where((n) => n.isPublished == isPublished).toList();
    }

    // Filter by category
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((n) => n.category == _selectedCategory).toList();
    }

    // Filter by priority
    if (_selectedPriority != 'all') {
      filtered =
          filtered.where((n) => n.priority == _selectedPriority).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((n) =>
              n.title.toLowerCase().contains(query) ||
              n.content.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  void _navigateToCreateNews() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateNewsScreen(),
      ),
    );

    if (result == true && mounted) {
      context.read<NewsManagementCubit>().loadNews();
    }
  }

  void _navigateToEditNews(NewsModel news) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateNewsScreen(newsId: news.id),
      ),
    );

    if (result == true && mounted) {
      context.read<NewsManagementCubit>().loadNews();
    }
  }

  void _confirmDelete(NewsModel news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${news.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<NewsManagementCubit>().deleteNews(news.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'announcement':
        return Colors.blue;
      case 'event':
        return Colors.purple;
      case 'update':
        return Colors.orange;
      case 'achievement':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'announcement':
        return Icons.campaign;
      case 'event':
        return Icons.event;
      case 'update':
        return Icons.info;
      case 'achievement':
        return Icons.emoji_events;
      default:
        return Icons.article;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'urgent':
        return Icons.priority_high;
      case 'high':
        return Icons.arrow_upward;
      case 'normal':
        return Icons.remove;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.flag;
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority) {
      case 'urgent':
        return 'عاجل';
      case 'high':
        return 'عالية';
      case 'normal':
        return 'عادية';
      case 'low':
        return 'منخفضة';
      default:
        return priority;
    }
  }

  // Mock data for skeleton
  List<NewsModel> get _mockNews => List.generate(
        3,
        (i) => NewsModel(
          id: 'mock_$i',
          title: 'عنوان الخبر رقم $i',
          content: 'محتوى الخبر الطويل هنا...',
          category: 'announcement',
          priority: 'normal',
          isPublished: true,
          createdAt: DateTime.now().subtract(Duration(hours: i)),
          updatedAt: DateTime.now(),
        ),
      );
}
