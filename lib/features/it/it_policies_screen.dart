import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/it/it_dashboard_cubit.dart';
import '../../cubits/it/it_dashboard_state.dart';
import '../../models/it_policy_model.dart';
import 'it_policy_form_screen.dart';

class ITPoliciesScreen extends StatelessWidget {
  const ITPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ITPolicyCubit()..loadPolicies(),
      child: const _ITPoliciesView(),
    );
  }
}

class _ITPoliciesView extends StatelessWidget {
  const _ITPoliciesView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.itPolicies),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ITPolicyFormScreen()),
              ).then((result) {
                if (result == true) {
                  context.read<ITPolicyCubit>().loadPolicies();
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<ITPolicyCubit, ITPolicyState>(
        listener: (context, state) {
          if (state is ITPolicySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
        },
        builder: (context, state) {
          if (state is ITPolicyLoading) {
            return const LoadingIndicator();
          }

          if (state is ITPolicyError) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<ITPolicyCubit>().loadPolicies(),
            );
          }

          final policies = state is ITPolicyLoaded ? state.policies : <ITPolicyModel>[];

          if (state is ITPolicySuccess && policies.isEmpty) {
            Future.delayed(Duration.zero, () {
              context.read<ITPolicyCubit>().loadPolicies();
            });
          }

          if (policies.isEmpty) {
            return Center(child: Text(localizations.noPoliciesAvailable));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<ITPolicyCubit>().loadPolicies(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: policies.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PolicyCard(policy: policies[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final ITPolicyModel policy;

  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    IconData icon = Icons.policy;
    Color color = Colors.purple;

    switch (policy.policyType) {
      case 'security':
        icon = Icons.security;
        color = Colors.red;
        break;
      case 'usage':
        icon = Icons.computer;
        color = Colors.blue;
        break;
      case 'compliance':
        icon = Icons.verified_user;
        color = Colors.green;
        break;
    }

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: color.withOpacity(0.2),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    policy.title,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit),
                          const SizedBox(width: 8),
                          Text(localizations.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(localizations.delete, style: const TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ITPolicyFormScreen(policy: policy),
                        ),
                      ).then((result) {
                        if (result == true) {
                          context.read<ITPolicyCubit>().loadPolicies();
                        }
                      });
                    } else if (value == 'delete') {
                      _showDeleteDialog(context);
                    }
                  },
                ),
              ],
            ),
            if (policy.description != null) ...[
              const SizedBox(height: 12),
              Text(policy.description!, style: theme.textTheme.bodyMedium),
            ],
            if (policy.policyType != null) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: Icon(icon, size: 16, color: color),
                label: Text(policy.policyType!.toUpperCase()),
                backgroundColor: color.withOpacity(0.2),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.confirmDelete),
        content: Text(localizations.deleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<ITPolicyCubit>().deletePolicy(policy.id);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}
