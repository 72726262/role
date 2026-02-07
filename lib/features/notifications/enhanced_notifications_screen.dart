import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../cubits/notifications/notifications_cubit.dart';
import '../../cubits/notifications/notifications_state.dart';
import '../../models/notification_model.dart';

/// 🔔 Enhanced Notifications Center
/// Real-time notifications with click navigation

class EnhancedNotificationsScreen extends StatefulWidget {
  const EnhancedNotificationsScreen({super.key});

  @override
  State<EnhancedNotificationsScreen> createState() =>
      _EnhancedNotificationsScreenState();
}

class _EnhancedNotificationsScreenState
    extends State<EnhancedNotificationsScreen> {
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    context.read<NotificationsCubit>().loadNotifications();
    context.read<NotificationsCubit>().subscribeToNotifications();
  }

  @override
  void dispose() {
    context.read<NotificationsCubit>().unsubscribeFromNotifications();
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
                child: BlocBuilder<NotificationsCubit, NotificationsState>(
                  builder: (context, state) {
                    if (state is NotificationsError) {
                      return _buildError(state.message);
                    }

                    final notifications = state is NotificationsLoaded
                        ? state.notifications
                        : _mockNotifications;
                    final isLoading = state is NotificationsLoading;

                    final filtered = _filterNotifications(notifications);

                    return Skeletonizer(
                      enabled: isLoading,
                      child: filtered.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () => context
                                  .read<NotificationsCubit>()
                                  .loadNotifications(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  return _buildNotificationCard(
                                    filtered[index],
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
              'مركز الإشعارات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<NotificationsCubit, NotificationsState>(
            builder: (context, state) {
              if (state is NotificationsLoaded) {
                final unreadCount =
                    state.notifications.where((n) => !n.isRead).length;
                if (unreadCount > 0) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () {
              context.read<NotificationsCubit>().markAllAsRead();
            },
            tooltip: 'تعليم الكل كمقروء',
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'الكل', Icons.all_inclusive),
            _buildFilterChip('message', 'رسائل', Icons.message),
            _buildFilterChip('news', 'أخبار', Icons.article),
            _buildFilterChip('event', 'فعاليات', Icons.event),
            _buildFilterChip('system', 'نظام', Icons.settings),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedCategory == value;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (_) {
          setState(() {
            _selectedCategory = value;
          });
        },
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isDark,
    bool isLoading,
  ) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<NotificationsCubit>().deleteNotification(notification.id);
      },
      child: GlassmorphicCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        onTap: isLoading ? null : () => _handleNotificationClick(notification),
        child: Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: _getCategoryColor(notification.category).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIcon(notification.category),
                color: _getCategoryColor(notification.category),
                size: 24,
              ),
            ),

            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight:
                          notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(notification.createdAt),
                    style: TextStyle(
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
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
            onPressed: () =>
                context.read<NotificationsCubit>().loadNotifications(),
          ),
        ],
      ),
    );
  }

  List<NotificationModel> _filterNotifications(
      List<NotificationModel> notifications) {
    if (_selectedCategory == 'all') {
      return notifications;
    }
    return notifications
        .where((n) => n.category == _selectedCategory)
        .toList();
  }

  void _handleNotificationClick(NotificationModel notification) {
    // Mark as read
    context.read<NotificationsCubit>().markAsRead(notification.id);

    // Navigate based on category
    if (notification.actionUrl != null) {
      _navigateToAction(notification);
    }
  }

  void _navigateToAction(NotificationModel notification) {
    // TODO: Implement navigation based on actionUrl
    // For now, just show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال إلى: ${notification.actionUrl}'),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'message':
        return Colors.blue;
      case 'news':
        return Colors.orange;
      case 'event':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'message':
        return Icons.message;
      case 'news':
        return Icons.article;
      case 'event':
        return Icons.event;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  List<NotificationModel> get _mockNotifications => List.generate(
        5,
        (i) => NotificationModel(
          id: 'mock_$i',
          userId: 'mock-user',
          title: 'إشعار رقم $i',
          message: 'محتوى الإشعار هنا...',
          category: i % 2 == 0 ? 'message' : 'news',
          isRead: i % 3 == 0,
          createdAt: DateTime.now().subtract(Duration(hours: i)),
        ),
      );
}
