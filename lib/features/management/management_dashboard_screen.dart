import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/management/management_dashboard_cubit.dart';
import '../../cubits/management/management_dashboard_state.dart';

class ManagementDashboardScreen extends StatelessWidget {
  const ManagementDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManagementDashboardCubit()..loadDashboard(),
      child: const _ManagementDashboardView(),
    );
  }
}

class _ManagementDashboardView extends StatelessWidget {
  const _ManagementDashboardView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.managementDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ManagementDashboardCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<ManagementDashboardCubit, ManagementDashboardState>(
        builder: (context, state) {
          if (state is ManagementDashboardLoading) {
            return const LoadingIndicator();
          }

          if (state is ManagementDashboardError) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<ManagementDashboardCubit>().loadDashboard(),
            );
          }

          if (state is ManagementDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<ManagementDashboardCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Engagement Overview
                    _EngagementOverview(
                      moodStats: state.moodStats,
                      totalEmployees: state.totalEmployees,
                    ),
                    const SizedBox(height: 24),

                    // Mood Chart
                    _MoodChartSection(moodStats: state.moodStats),
                    const SizedBox(height: 24),

                    // Published Messages
                    _PublishedMessages(messages: state.messages),
                    const SizedBox(height: 16),

                    // Publish New Message Button
                    _PublishMessageButton(),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EngagementOverview extends StatelessWidget {
  final Map<String, int> moodStats;
  final int totalEmployees;

  const _EngagementOverview({
    required this.moodStats,
    required this.totalEmployees,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final totalMoods = moodStats.values.fold(0, (a, b) => a + b);
    final engagementRate = totalEmployees > 0 
        ? (totalMoods / totalEmployees * 100).toInt()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.engagementOverview,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.trending_up, color: Colors.green, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        localizations.engagementRate,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$engagementRate%',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomCard(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.groups, color: Colors.blue, size: 32),
                      const SizedBox(height: 12),
                      Text(
                        localizations.totalEmployees,
                        style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalEmployees.toString(),
                        style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MoodChartSection extends StatelessWidget {
  final Map<String, int> moodStats;

  const _MoodChartSection({required this.moodStats});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.moodDistribution,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _generateSections(moodStats),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _LegendItem(Colors.green, localizations.happy, moodStats['happy'] ?? 0),
                    _LegendItem(Colors.blue, localizations.normal, moodStats['normal'] ?? 0),
                    _LegendItem(Colors.orange, localizations.tired, moodStats['tired'] ?? 0),
                    _LegendItem(Colors.red, localizations.needSupport, moodStats['need_support'] ?? 0),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generateSections(Map<String, int> stats) {
    return [
      PieChartSectionData(
        value: (stats['happy'] ?? 0).toDouble(),
        color: Colors.green,
        radius: 50,
      ),
      PieChartSectionData(
        value: (stats['normal'] ?? 0).toDouble(),
        color: Colors.blue,
        radius: 50,
      ),
      PieChartSectionData(
        value: (stats['tired'] ?? 0).toDouble(),
        color: Colors.orange,
        radius: 50,
      ),
      PieChartSectionData(
        value: (stats['need_support'] ?? 0).toDouble(),
        color: Colors.red,
        radius: 50,
      ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem(this.color, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}

class _PublishedMessages extends StatelessWidget {
  final List messages;

  const _PublishedMessages({required this.messages});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.publishedMessages,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (messages.isEmpty)
          CustomCard(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(child: Text(localizations.noMessagesPublished)),
            ),
          )
        else
          ...messages.take(5).map((msg) {
            Color priorityColor = Colors.blue;
            switch (msg.priority) {
              case 'urgent':
                priorityColor = Colors.red;
                break;
              case 'high':
                priorityColor = Colors.orange;
                break;
              case 'medium':
                priorityColor = Colors.blue;
                break;
              case 'low':
                priorityColor = Colors.grey;
                break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CustomCard(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: priorityColor.withOpacity(0.2),
                    child: Icon(Icons.message, color: priorityColor),
                  ),
                  title: Text(msg.title),
                  subtitle: Text(msg.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: Chip(
                    label: Text(msg.priority.toUpperCase()),
                    backgroundColor: priorityColor.withOpacity(0.2),
                  ),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }
}

class _PublishMessageButton extends StatelessWidget {
  const _PublishMessageButton();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return CustomCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.comingSoon)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              localizations.publishNewMessage,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
