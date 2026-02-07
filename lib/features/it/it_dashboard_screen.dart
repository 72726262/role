import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/it/it_dashboard_cubit.dart';
import '../../cubits/it/it_dashboard_state.dart';
import 'it_policies_screen.dart';

class ITDashboardScreen extends StatelessWidget {
  const ITDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ITDashboardCubit()..loadDashboard(),
      child: const _ITDashboardView(),
    );
  }
}

class _ITDashboardView extends StatelessWidget {
  const _ITDashboardView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.itDashboard),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ITDashboardCubit>().refresh(),
          ),
        ],
      ),
      body: BlocBuilder<ITDashboardCubit, ITDashboardState>(
        builder: (context, state) {
          if (state is ITDashboardLoading) {
            return const LoadingIndicator();
          }

          if (state is ITDashboardError) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<ITDashboardCubit>().loadDashboard(),
            );
          }

          if (state is ITDashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () => context.read<ITDashboardCubit>().refresh(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overview Stats
                    _OverviewSection(
                      totalUsers: state.totalUsers,
                      activeDevices: state.activeDevices,
                      policiesCount: state.policies.length,
                    ),
                    const SizedBox(height: 24),

                    // IT Policies
                    _ITPoliciesSection(policiesCount: state.policies.length),
                    const SizedBox(height: 16),

                    // Support Contacts
                    const _SupportSection(),
                    const SizedBox(height: 16),

                    // System Announcements
                    const _AnnouncementsSection(),
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

class _OverviewSection extends StatelessWidget {
  final int totalUsers;
  final int activeDevices;
  final int policiesCount;

  const _OverviewSection({
    required this.totalUsers,
    required this.activeDevices,
    required this.policiesCount,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.overview,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                title: localizations.totalUsers,
                value: totalUsers.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.devices,
                title: localizations.activeDevices,
                value: activeDevices.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.policy,
                title: localizations.itPolicies,
                value: policiesCount.toString(),
                color: Colors.purple,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: const SizedBox()),
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
            Text(title, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _ITPoliciesSection extends StatelessWidget {
  final int policiesCount;

  const _ITPoliciesSection({required this.policiesCount});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return CustomCard(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ITPoliciesScreen()),
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
                    localizations.itPolicies,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$policiesCount ${localizations.policies}',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
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

class _SupportSection extends StatelessWidget {
  const _SupportSection();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.supportContacts,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.email)),
                  title: Text(localizations.emailSupport),
                  subtitle: const Text('it-support@company.com'),
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.phone)),
                  title: Text(localizations.phoneSupport),
                  subtitle: const Text('+966 11 234 5678'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementsSection extends StatelessWidget {
  const _AnnouncementsSection();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.systemAnnouncements,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        CustomCard(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blue),
                  title: Text(localizations.systemMaintenance),
                  subtitle: Text(localizations.scheduledMaintenanceMessage),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.security, color: Colors.orange),
                  title: Text(localizations.securityUpdate),
                  subtitle: Text(localizations.securityUpdateMessage),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
