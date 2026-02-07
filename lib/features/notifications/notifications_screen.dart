import 'package:flutter/material.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../services/realtime_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 🔔 Notifications Center
/// Real-time notifications with premium UI

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _realtimeService = RealtimeService();
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  @override
  void dispose() {
    _realtimeService.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    setState(() => _isLoading = true);
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _userId = user?.id;
      _isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _markAllAsRead() async {
    if (_userId == null) return;
    
    try {
      await Supabase.instance.client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعليم جميع الإشعارات كمقروءة'),
            backgroundColor: AppColors.accentLight,
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading || _userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'الإشعارات',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.done_all, color: Colors.white),
                      onPressed: _markAllAsRead,
                    ),
                  ],
                ),
              ),

              // Notifications Stream
              Expanded(
                child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: _realtimeService.subscribeToNotifications(_userId!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SkeletonLoader(
                        isLoading: true,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          itemCount: 8,
                          itemBuilder: (context, index) => _buildNotificationSkeleton(),
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: theme.iconTheme.color?.withOpacity(0.3),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'لا توجد إشعارات',
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      );
                    }

                    final notifications = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return _buildNotificationCard(context, notification);
                      },
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

  Widget _buildNotificationCard(BuildContext context, Map<String, dynamic> notification) {
    final isRead = notification['is_read'] ?? false;
    final type = notification['type'] ?? 'system';
    final createdAt = DateTime.tryParse(notification['created_at'] ?? '');
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassmorphicCard(
        opacity: isRead ? 0.05 : 0.15,
        onTap: () {
          if (!isRead) {
            _markAsRead(notification['id']);
          }
          // Navigate to related content
          if (notification['link'] != null) {
            // Handle navigation
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: _getGradientForType(type),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconForType(type),
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] ?? 'إشعار',
                          style: TextStyle(
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  if (notification['body'] != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notification['body'],
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassmorphicCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, width: double.infinity, color: Colors.grey),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 200, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.mail;
      case 'news':
        return Icons.newspaper;
      case 'event':
        return Icons.event;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }

  Gradient _getGradientForType(String type) {
    switch (type) {
      case 'message':
        return AppGradients.primaryGradient;
      case 'news':
        return AppGradients.secondaryGradient;
      case 'event':
        return AppGradients.successGradient;
      case 'announcement':
        return AppGradients.warningGradient;
      default:
        return AppGradients.primaryGradient;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) {
      return 'الآن';
    } else if (diff.inHours < 1) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inDays == 0) {
      return 'منذ ${diff.inHours} ساعة';
    } else if (diff.inDays == 1) {
      return 'أمس';
    } else if (diff.inDays < 7) {
      return 'منذ ${diff.inDays} أيام';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
