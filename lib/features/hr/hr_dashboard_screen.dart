import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/hr/hr_dashboard_cubit.dart';
import '../../cubits/hr/hr_dashboard_state.dart';
import 'hr_policies_screen.dart';
import 'training_courses_screen.dart';

class HRDashboardScreen extends StatelessWidget {
  const HRDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HRDashboardCubit()..loadDashboard(),
      child: const _HRDashboardView(),
    );
  }
}

class _HRDashboardView extends StatelessWidget {
  const _HRDashboardView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.hrDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<HRDashboardCubit>().refresh();
            },
          ),
        ],
      ),
      body: BlocBuilder<HRDashboardCubit, HRDashboardState>(
        builder: (context, state) {
          if (state is HRDashboardLoading) {
            return const LoadingIndicator();
          }

          if (state is HRDashboardError) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () {
                context.read<HRDashboardCubit>().loadDashboard();
              },
            );
          }

          if (state is HRDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<HRDashboardCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Overview Cards
                    _OverviewSection(
                      totalEmployees: state.totalEmployees,
                      moodStats: state.moodStats,
                    ),
                    const SizedBox(height: 24),

                    // Section 2: HR Policies
                    _HRPoliciesSection(policiesCount: state.policies.length),
                    const SizedBox(height: 16),

                    // Section 3: Training Courses
                    _TrainingCoursesSection(coursesCount: state.courses.length),
                    const SizedBox(height: 16),

                    // Section 4: Recruitment  
                    _RecruitmentSection(),
                    const SizedBox(height: 16),

                    // Section 5: Mood Analytics
                    _MoodAnalyticsSection(moodStats: state.moodStats),
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

/// Section 1: Overview Cards
class _OverviewSection extends StatelessWidget {
  final int totalEmployees;
  final Map<String, int> moodStats;

  const _OverviewSection({
    required this.totalEmployees,
    required this.moodStats,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    // Calculate mood average
    final totalMoods = moodStats.values.fold(0, (a, b) => a + b);
    final happyCount = moodStats['happy'] ?? 0;
    final normalCount = moodStats['normal'] ?? 0;
    final moodPercentage = totalMoods > 0 
        ? ((happyCount + normalCount) / totalMoods * 100).toInt()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.overview,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                title: localizations.totalEmployees,
                value: totalEmployees.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.sentiment_satisfied,
                title: localizations.moodAverage,
                value: '$moodPercentage%',
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section 2: HR Policies
class _HRPoliciesSection extends StatelessWidget {
  final int policiesCount;

  const _HRPoliciesSection({required this.policiesCount});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HRPoliciesScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.purple.withOpacity(0.2),
              child: const Icon(Icons.policy, color: Colors.purple),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.hrPolicies,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$policiesCount ${localizations.policies}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Section 3: Training Courses
class _TrainingCoursesSection extends StatelessWidget {
  final int coursesCount;

  const _TrainingCoursesSection({required this.coursesCount});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TrainingCoursesScreen(),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: const Icon(Icons.school, color: Colors.orange),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.trainingCourses,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$coursesCount ${localizations.courses}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Section 4: Recruitment Portal
class _RecruitmentSection extends StatelessWidget {
  const _RecruitmentSection();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.comingSoon)),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.teal.withOpacity(0.2),
              child: const Icon(Icons.work, color: Colors.teal),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.recruitmentPortal,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    localizations.manageJobPostings,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Section 5: Mood Analytics with Charts
class _MoodAnalyticsSection extends StatelessWidget {
  final Map<String, int> moodStats;

  const _MoodAnalyticsSection({required this.moodStats});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.moodAnalytics,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Pie Chart
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _generatePieSections(moodStats),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Legend
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _LegendItem(
                      color: Colors.green,
                      label: localizations.happy,
                      value: moodStats['happy'] ?? 0,
                    ),
                    _LegendItem(
                      color: Colors.blue,
                      label: localizations.normal,
                      value: moodStats['normal'] ?? 0,
                    ),
                    _LegendItem(
                      color: Colors.orange,
                      label: localizations.tired,
                      value: moodStats['tired'] ?? 0,
                    ),
                    _LegendItem(
                      color: Colors.red,
                      label: localizations.needSupport,
                      value: moodStats['need_support'] ?? 0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _generatePieSections(Map<String, int> stats) {
    final total = stats.values.fold(0, (a, b) => a + b);
    if (total == 0) return [];

    return [
      PieChartSectionData(
        value: (stats['happy'] ?? 0).toDouble(),
        color: Colors.green,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: (stats['normal'] ?? 0).toDouble(),
        color: Colors.blue,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: (stats['tired'] ?? 0).toDouble(),
        color: Colors.orange,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: (stats['need_support'] ?? 0).toDouble(),
        color: Colors.red,
        radius: 50,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: $value'),
      ],
    );
  }
}
