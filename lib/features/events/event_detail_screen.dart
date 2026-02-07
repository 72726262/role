import 'package:flutter/material.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 📅 Event Detail Screen
/// Premium view of event information with RSVP

class EventDetailScreen extends StatefulWidget {
  final String eventId;

  const EventDetailScreen({super.key, required this.eventId});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final _dbService = DatabaseService();
  Map<String, dynamic>? _event;
  bool _isLoading = true;
  bool _isRegistered = false;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  Future<void> _loadEvent() async {
    setState(() => _isLoading = true);
    
    try {
      final event = await _dbService.getById('events', widget.eventId);
      setState(() => _event = event);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleRegistration() async {
    setState(() => _isRegistered = !_isRegistered);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isRegistered ? 'تم التسجيل في الفعالية' : 'تم إلغاء التسجيل',
          ),
          backgroundColor: AppColors.accentLight,
        ),
      );
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
          child: SkeletonLoader(
            isLoading: _isLoading,
            child: CustomScrollView(
              slivers: [
                // Image Header
                SliverAppBar(
                  expandedHeight: 250,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _event?['image_url'] != null
                        ? CachedNetworkImage(
                            imageUrl: _event!['image_url'],
                            fit: BoxFit.cover,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              gradient: AppGradients.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.event,
                              size: 80,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                // Content
                SliverPadding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Title Card
                      GlassmorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.successGradient,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _event?['category'] ?? 'فعالية',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _event?['title'] ?? 'عنوان الفعالية',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Date & Location
                      GlassmorphicCard(
                        child: Column(
                          children: [
                            _buildInfoRow(
                              icon: Icons.calendar_today,
                              label: 'التاريخ',
                              value: _formatDate(_event?['event_date']),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.access_time,
                              label: 'الوقت',
                              value: _formatTime(_event?['event_time']),
                            ),
                            const Divider(height: 24),
                            _buildInfoRow(
                              icon: Icons.location_on,
                              label: 'المكان',
                              value: _event?['location'] ?? 'غير محدد',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Description
                      GlassmorphicCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.description,
                                  size: 20,
                                  color: AppColors.primaryLight,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Text(
                                  'الوصف',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _event?['description'] ?? 'لا يوجد وصف',
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Attendees
                      GlassmorphicCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppGradients.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.people,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'المشاركون',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_event?['attendees_count'] ?? 0} مشارك',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Action Button
                      AnimatedButton(
                        text: _isRegistered ? 'إلغاء التسجيل' : 'التسجيل في الفعالية',
                        icon: _isRegistered ? Icons.cancel : Icons.check_circle,
                        onPressed: _toggleRegistration,
                        width: double.infinity,
                        gradient: _isRegistered 
                            ? AppGradients.errorGradient 
                            : AppGradients.successGradient,
                      ),

                      const SizedBox(height: AppSpacing.xxl),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'غير محدد';
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
      final months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 
                       'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
      return '${weekdays[date.weekday % 7]}, ${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'غير محدد';
    }
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'غير محدد';
    return timeStr;
  }
}
