import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/hr/hr_dashboard_cubit.dart';
import '../../cubits/hr/hr_dashboard_state.dart';
import '../../models/hr_policy_model.dart';
import 'hr_policy_form_screen.dart';

class HRPoliciesScreen extends StatelessWidget {
  const HRPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HRPolicyCubit()..loadPolicies(),
      child: const _HRPoliciesView(),
    );
  }
}

class _HRPoliciesView extends StatelessWidget {
  const _HRPoliciesView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.hrPolicies),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HRPolicyFormScreen(),
                ),
              ).then((result) {
                if (result == true) {
                  context.read<HRPolicyCubit>().loadPolicies();
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<HRPolicyCubit,HRPolicyState>(
        listener: (context, state) {
          if (state is HRPolicySuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is HRPolicyError && state is! HRPolicyLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is HRPolicyLoading) {
            return const LoadingIndicator();
          }

          if (state is HRPolicyError && state is! HRPolicySuccess) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<HRPolicyCubit>().loadPolicies(),
            );
          }

          if (state is HRPolicyLoaded || state is HRPolicySuccess) {
            final policies = state is HRPolicyLoaded 
                ? state.policies 
                : (state as HRPolicySuccess).props.isNotEmpty 
                    ? [] 
                    : [];

            // Reload after success
            if (state is HRPolicySuccess && policies.isEmpty) {
              Future.delayed(Duration.zero, () {
                context.read<HRPolicyCubit>().loadPolicies();
              });
            }

            final displayPolicies = state is HRPolicyLoaded ? state.policies : <HRPolicyModel>[];

            if (displayPolicies.isEmpty) {
              return Center(
                child: Text(localizations.noPoliciesAvailable),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<HRPolicyCubit>().loadPolicies(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayPolicies.length,
                itemBuilder: (context, index) {
                  final policy = displayPolicies[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PolicyCard(policy: policy),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final HRPolicyModel policy;

  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    policy.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
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
                          builder: (context) => HRPolicyFormScreen(policy: policy),
                        ),
                      ).then((result) {
                        if (result == true) {
                          context.read<HRPolicyCubit>().loadPolicies();
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
              const SizedBox(height: 8),
              Text(
                policy.description!,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (policy.category != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(policy.category!),
                backgroundColor: Colors.blue.withOpacity(0.2),
              ),
            ],
            if (policy.pdfUrl != null) ...[
              const SizedBox(height: 12),
              CustomButton(
                text: localizations.viewPDF,
                onPressed: () {
                  // TODO: Open PDF viewer
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(localizations.comingSoon)),
                  );
                },
                icon: Icons.picture_as_pdf,
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
              context.read<HRPolicyCubit>().deletePolicy(policy.id);
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
