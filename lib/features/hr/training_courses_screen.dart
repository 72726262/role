import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/error_widget.dart' as custom_widgets;
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/hr/hr_dashboard_cubit.dart';
import '../../cubits/hr/hr_dashboard_state.dart';
import '../../models/training_course_model.dart';
import 'training_course_form_screen.dart';

class TrainingCoursesScreen extends StatelessWidget {
  const TrainingCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TrainingCourseCubit()..loadCourses(),
      child: const _TrainingCoursesView(),
    );
  }
}

class _TrainingCoursesView extends StatelessWidget {
  const _TrainingCoursesView();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.trainingCourses),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TrainingCourseFormScreen(),
                ),
              ).then((result) {
                if (result == true) {
                  context.read<TrainingCourseCubit>().loadCourses();
                }
              });
            },
          ),
        ],
      ),
      body: BlocConsumer<TrainingCourseCubit, TrainingCourseState>(
        listener: (context, state) {
          if (state is TrainingCourseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.green),
            );
          }
          if (state is TrainingCourseError && state is! TrainingCourseLoading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is TrainingCourseLoading) {
            return const LoadingIndicator();
          }

          if (state is TrainingCourseError && state is! TrainingCourseSuccess) {
            return custom_widgets.ErrorWidget(
              message: state.message,
              onRetry: () => context.read<TrainingCourseCubit>().loadCourses(),
            );
          }

          final courses = state is TrainingCourseLoaded ? state.courses : <TrainingCourseModel>[];

          if (state is TrainingCourseSuccess && courses.isEmpty) {
            Future.delayed(Duration.zero, () {
              context.read<TrainingCourseCubit>().loadCourses();
            });
          }

          if (courses.isEmpty) {
            return Center(child: Text(localizations.noCoursesAvailable));
          }

          return RefreshIndicator(
            onRefresh: () => context.read<TrainingCourseCubit>().loadCourses(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CourseCard(course: courses[index]),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final TrainingCourseModel course;

  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    final dateFormat = DateFormat.yMMMd();

    return CustomCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.2),
                  child: const Icon(Icons.school, color: Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (course.instructor != null)
                        Text(
                          '${localizations.instructor}: ${course.instructor}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
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
                          builder: (context) => TrainingCourseFormScreen(course: course),
                        ),
                      ).then((result) {
                        if (result == true) {
                          context.read<TrainingCourseCubit>().loadCourses();
                        }
                      });
                    } else if (value == 'delete') {
                      _showDeleteDialog(context);
                    }
                  },
                ),
              ],
            ),
            if (course.description != null) ...[
              const SizedBox(height: 12),
              Text(course.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (course.durationHours != null)
                  Chip(
                    avatar: const Icon(Icons.access_time, size: 16),
                    label: Text('${course.durationHours} ${localizations.hours}'),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                if (course.startDate != null)
                  Chip(
                    avatar: const Icon(Icons.calendar_today, size: 16),
                    label: Text(dateFormat.format(course.startDate!)),
                    backgroundColor: Colors.green.withOpacity(0.1),
                  ),
                if (course.maxParticipants != null)
                  Chip(
                    avatar: const Icon(Icons.people, size: 16),
                    label: Text('${localizations.max}: ${course.maxParticipants}'),
                    backgroundColor: Colors.purple.withOpacity(0.1),
                  ),
              ],
            ),
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
              context.read<TrainingCourseCubit>().deleteCourse(course.id);
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
