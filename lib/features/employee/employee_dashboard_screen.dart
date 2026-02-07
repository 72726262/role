import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/employee/employee_dashboard_cubit.dart';
import '../../cubits/employee/employee_dashboard_state.dart';
import '../../models/news_model.dart';
import '../../models/event_model.dart';
import 'news_detail_screen.dart';

class EmployeeDashboardScreen extends StatelessWidget {
  const EmployeeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => EmployeeDashboardCubit()..loadDashboard(),
        ),
        BlocProvider(
          create: (context) => MoodSubmissionCubit(),
        ),
      ],
      child: const _EmployeeDashboardView(),
    );
  }
}

class _EmployeeDashboardView extends StatelessWidget {
  const _EmployeeDashboardView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.employeeDashboard),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<EmployeeDashboardCubit>().refresh();
            },
          ),
        ],
      ),
      body: BlocBuilder<EmployeeDashboardCubit, EmployeeDashboardState>(
        builder: (context, state) {
          if (state is EmployeeDashboardLoading) {
            return const LoadingIndicator();
          }

          if (state is EmployeeDashboardError) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<EmployeeDashboardCubit>().loadDashboard();
              },
            );
          }

          if (state is EmployeeDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<EmployeeDashboardCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Welcome Header
                    _WelcomeHeader(profile: state.profile),
                    const SizedBox(height: 24),

                    // Section 2: Info Bar (Time, Date, Temperature)
                    const _InfoBar(),
                    const SizedBox(height: 24),

                    // Section 3: Daily Mood
                    _DailyMoodSection(
                      moodSubmittedToday: state.moodSubmittedToday,
                    ),
                    const SizedBox(height: 24),

                    // Section 4: Strategic Content
                    const _StrategicContentSection(),
                    const SizedBox(height: 24),

                    // Section 5: Company News
                    _CompanyNewsSection(news: state.news),
                    const SizedBox(height: 24),

                    // Section 6: Management Messages
                    _ManagementMessagesSection(messages: state.messages),
                    const SizedBox(height: 24),

                    // Section 7: Events & Polls
                    _EventsSection(events: state.events),
                    const SizedBox(height: 24),

                    // Section 8: Quick Links
                    _QuickLinksSection(links: state.links),
                    const SizedBox(height: 80), // Space for FAB
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      // Section 9: AI Chatbot (Floating Action Button)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement AI chatbot
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(localizations.comingSoon),
            ),
          );
        },
        child: const Icon(Icons.chat),
      ),
    );
  }
}

/// Section 1: Welcome Header
class _WelcomeHeader extends StatelessWidget {
  final dynamic profile;

  const _WelcomeHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 35,
              backgroundImage: profile.photoUrl != null
                  ? NetworkImage(profile.photoUrl!)
                  : null,
              child: profile.photoUrl == null
                  ? Text(
                      profile.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(fontSize: 28),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    '${localizations.welcome}, ${profile.fullName ?? localizations.user}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Job title
                  Text(
                    profile.jobTitle ?? '',
                    style: theme.textTheme.bodyMedium,
                  ),
                  // Department
                  Text(
                    profile.department ?? '',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 2: Info Bar (Clock, Date, Temperature)
class _InfoBar extends StatelessWidget {
  const _InfoBar();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final now = DateTime.now();
    final timeFormat = DateFormat.jm();
    final dateFormat = DateFormat.yMMMMd(localizations.locale.languageCode);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Clock
            _InfoItem(
              icon: Icons.access_time,
              label: localizations.time,
              value: timeFormat.format(now),
            ),
            // Date
            _InfoItem(
              icon: Icons.calendar_today,
              label: localizations.date,
              value: dateFormat.format(now),
            ),
            // Temperature (placeholder)
            _InfoItem(
              icon: Icons.thermostat,
              label: localizations.temperature,
              value: '25°C', // TODO: Integrate weather API
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: theme.primaryColor, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Section 3: Daily Mood
class _DailyMoodSection extends StatelessWidget {
  final bool moodSubmittedToday;

  const _DailyMoodSection({required this.moodSubmittedToday});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.howAreYouToday,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        BlocConsumer<MoodSubmissionCubit, MoodSubmissionState>(
          listener: (context, state) {
            if (state is MoodSubmissionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.moodSubmittedSuccessfully),
                  backgroundColor: Colors.green,
                ),
              );
              // Refresh dashboard
              context.read<EmployeeDashboardCubit>().refresh();
            }
            if (state is MoodSubmissionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (moodSubmittedToday && state is! MoodSubmissionSuccess) {
              return CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          localizations.moodAlreadySubmitted,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Row(
              children: [
                // Happy
                Expanded(
                  child: _MoodCard(
                    emoji: '😊',
                    label: localizations.happy,
                    moodType: 'happy',
                    color: Colors.green,
                    isLoading: state is MoodSubmissionLoading,
                  ),
                ),
                const SizedBox(width: 12),
                // Normal
                Expanded(
                  child: _MoodCard(
                    emoji: '😐',
                    label: localizations.normal,
                    moodType: 'normal',
                    color: Colors.blue,
                    isLoading: state is MoodSubmissionLoading,
                  ),
                ),
                const SizedBox(width: 12),
                // Tired
                Expanded(
                  child: _MoodCard(
                    emoji: '😴',
                    label: localizations.tired,
                    moodType: 'tired',
                    color: Colors.orange,
                    isLoading: state is MoodSubmissionLoading,
                  ),
                ),
                const SizedBox(width: 12),
                // Need Support
                Expanded(
                  child: _MoodCard(
                    emoji: '😔',
                    label: localizations.needSupport,
                    moodType: 'need_support',
                    color: Colors.red,
                    isLoading: state is MoodSubmissionLoading,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String moodType;
  final Color color;
  final bool isLoading;

  const _MoodCard({
    required this.emoji,
    required this.label,
    required this.moodType,
    required this.color,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: isLoading
          ? null
          : () {
              context.read<MoodSubmissionCubit>().submitMood(moodType);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 4: Strategic Content
class _StrategicContentSection extends StatelessWidget {
  const _StrategicContentSection();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.strategicContent,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StrategicCard(
                icon: Icons.rocket_launch,
                title: localizations.strategicPyramid,
                onTap: () {
                  // TODO: Open PDF viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.comingSoon)),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StrategicCard(
                icon: Icons.menu_book,
                title: localizations.cultureHandbook,
                onTap: () {
                  // TODO: Open PDF viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.comingSoon)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StrategicCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _StrategicCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.primaryColor),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 5: Company News
class _CompanyNewsSection extends StatelessWidget {
  final List<NewsModel> news;

  const _CompanyNewsSection({required this.news});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              localizations.companyNews,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to all news
              },
              child: Text(localizations.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 12),
        news.isEmpty
            ? CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(localizations.noNewsAvailable),
                  ),
                ),
              )
            : Column(
                children: news.take(3).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _NewsCard(news: item),
                  );
                }).toList(),
              ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;

  const _NewsCard({required this.news});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsDetailScreen(news: news),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (news.imageUrl != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                news.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 64),
                  );
                },
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  news.content,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (news.publishedAt != null)
                  Text(
                    dateFormat.format(news.publishedAt!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Section 6: Management Messages
class _ManagementMessagesSection extends StatelessWidget {
  final List messages;

  const _ManagementMessagesSection({required this.messages});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    if (messages.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.managementMessages,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...messages.map((message) {
          Color priorityColor = Colors.blue;
          IconData priorityIcon = Icons.info;
          
          switch (message.priority) {
            case 'urgent':
              priorityColor = Colors.red;
              priorityIcon = Icons.warning;
              break;
            case 'high':
              priorityColor = Colors.orange;
              priorityIcon = Icons.priority_high;
              break;
            case 'medium':
              priorityColor = Colors.blue;
              priorityIcon = Icons.info;
              break;
            case 'low':
              priorityColor = Colors.grey;
              priorityIcon = Icons.info_outline;
              break;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(priorityIcon, color: priorityColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            message.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message.message,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

/// Section 7: Events & Polls
class _EventsSection extends StatelessWidget {
  final List<EventModel> events;

  const _EventsSection({required this.events});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.eventsAndOccasions,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        events.isEmpty
            ? CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text(localizations.noEventsAvailable),
                  ),
                ),
              )
            : Column(
                children: events.take(5).map((event) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _EventCard(event: event),
                  );
                }).toList(),
              ),
      ],
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    IconData icon = Icons.event;
    Color color = Colors.blue;

    switch (event.eventType) {
      case 'birthday':
        icon = Icons.cake;
        color = Colors.pink;
        break;
      case 'meeting':
        icon = Icons.group;
        color = Colors.blue;
        break;
      case 'celebration':
        icon = Icons.celebration;
        color = Colors.amber;
        break;
      case 'training':
        icon = Icons.school;
        color = Colors.green;
        break;
    }

    return CustomCard(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(
          event.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description != null)
              Text(event.description!, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(dateFormat.format(event.eventDate)),
          ],
        ),
        isThreeLine: event.description != null,
      ),
    );
  }
}

/// Section 8: Quick Links
class _QuickLinksSection extends StatelessWidget {
  final List links;

  const _QuickLinksSection({required this.links});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.quickLinks,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: links.length > 6 ? 6 : links.length,
          itemBuilder: (context, index) {
            final link = links[index];
            return _QuickLinkCard(
              icon: _getIconData(link.iconName),
              title: link.title,
              onTap: () {
                // TODO: Handle link tap (open URL)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Opening ${link.title}')),
                );
              },
            );
          },
        ),
      ],
    );
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'news':
        return Icons.newspaper;
      case 'events':
        return Icons.event;
      case 'policies':
        return Icons.policy;
      case 'training':
        return Icons.school;
      case 'support':
        return Icons.support_agent;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.link;
    }
  }
}

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: theme.primaryColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
