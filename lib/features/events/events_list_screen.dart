import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../cubits/events/events_list_cubit.dart';
import '../../cubits/events/events_list_state.dart';
import '../../models/event_model.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';

/// 🎉 Events Management Screen
/// Manage all events with filters

class EventsListScreen extends StatefulWidget {
  const EventsListScreen({super.key});

  @override
  State<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends State<EventsListScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'all'; // all, upcoming, past

  @override
  void initState() {
    super.initState();
    context.read<EventsListCubit>().loadEvents();
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
              _buildSearchAndFilter(isDark),
              Expanded(
                child: BlocBuilder<EventsListCubit, EventsListState>(
                  builder: (context, state) {
                    if (state is EventsListError) {
                      return _buildError(state.message);
                    }

                    final events =
                        state is EventsListLoaded ? state.events : _mockEvents;
                    final isLoading = state is EventsListLoading;

                    final filteredEvents = _filterEvents(events);

                    return Skeletonizer(
                      enabled: isLoading,
                      child: filteredEvents.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () =>
                                  context.read<EventsListCubit>().loadEvents(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: filteredEvents.length,
                                itemBuilder: (context, index) {
                                  return _buildEventCard(
                                    filteredEvents[index],
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
        onPressed: () => _navigateToCreateEvent(),
        icon: const Icon(Icons.add),
        label: const Text('إنشاء فعالية'),
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
              'إدارة الفعاليات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<EventsListCubit, EventsListState>(
            builder: (context, state) {
              if (state is EventsListLoaded) {
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
                    '${state.events.length}',
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

  Widget _buildSearchAndFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Search
          GlassmorphicCard(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن فعالية...',
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

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'الكل', Icons.all_inclusive),
                _buildFilterChip('upcoming', 'القادمة', Icons.upcoming),
                _buildFilterChip('past', 'السابقة', Icons.history),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedFilter == value;

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
            _selectedFilter = value;
          });
        },
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildEventCard(EventModel event, bool isDark, bool isLoading) {
    final dateFormat = DateFormat('dd/MM/yyyy - HH:mm');
    final now = DateTime.now();
    final isPast = event.eventDate.isBefore(now);

    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: isLoading ? null : () => _navigateToEventDetail(event),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image (if exists)
          if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.lg),
              ),
              child: Image.network(
                event.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // Date & Location
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: isPast ? Colors.grey : AppColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(event.eventDate),
                      style: TextStyle(
                        color: isPast ? Colors.grey : null,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                if (event.location != null && event.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location!,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: AppSpacing.sm),

                // Description preview
                Text(
                  event.description.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Status & Actions
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPast
                            ? Colors.grey.withOpacity(0.2)
                            : Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                      ),
                      child: Text(
                        isPast ? 'منتهية' : 'قادمة',
                        style: TextStyle(
                          color: isPast ? Colors.grey : Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Edit
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed:
                          isLoading ? null : () => _navigateToEditEvent(event),
                      color: AppColors.primaryLight,
                    ),

                    // Delete
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: isLoading ? null : () => _confirmDelete(event),
                      color: AppColors.accentError,
                    ),
                  ],
                ),
              ],
            ),
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
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا توجد فعاليات',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ابدأ بإنشاء فعالية جديدة',
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
            onPressed: () => context.read<EventsListCubit>().loadEvents(),
          ),
        ],
      ),
    );
  }

  List<EventModel> _filterEvents(List<EventModel> events) {
    var filtered = events;
    final now = DateTime.now();

    // Filter by time
    if (_selectedFilter == 'upcoming') {
      filtered = filtered.where((e) => e.eventDate.isAfter(now)).toList();
    } else if (_selectedFilter == 'past') {
      filtered = filtered.where((e) => e.eventDate.isBefore(now)).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((e) =>
              e.title.toLowerCase().contains(query) ||
              e.description.toString().toLowerCase().contains(query))
          .toList();
    }

    // Sort by date
    filtered.sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return filtered;
  }

  void _navigateToCreateEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const EventFormScreen(),
      ),
    );

    if (result == true && mounted) {
      context.read<EventsListCubit>().loadEvents();
    }
  }

  void _navigateToEditEvent(EventModel event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventFormScreen(event: event),
      ),
    );

    if (result == true && mounted) {
      context.read<EventsListCubit>().loadEvents();
    }
  }

  void _navigateToEventDetail(EventModel event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailScreen(eventId: event.id),
      ),
    );

    if (result == true && mounted) {
      context.read<EventsListCubit>().loadEvents();
    }
  }

  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "${event.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EventsListCubit>().deleteEvent(event.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  // Mock data for skeleton
  List<EventModel> get _mockEvents => List.generate(
        5,
        (i) => EventModel(
          id: 'mock_$i',
          title: 'فعالية رقم $i',
          description: 'وصف الفعالية...',
          eventDate: DateTime.now().add(Duration(days: i * 3)),
          eventType: 'meeting',
          location: 'مكان الفعالية',
          maxAttendees: 50,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
}
