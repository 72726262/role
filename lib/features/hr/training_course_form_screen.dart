import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/localization/app_localizations.dart';
import '../../cubits/hr/hr_dashboard_cubit.dart';
import '../../models/training_course_model.dart';

class TrainingCourseFormScreen extends StatefulWidget {
  final TrainingCourseModel? course;

  const TrainingCourseFormScreen({super.key, this.course});

  @override
  State<TrainingCourseFormScreen> createState() => _TrainingCourseFormScreenState();
}

class _TrainingCourseFormScreenState extends State<TrainingCourseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _instructorController;
  late TextEditingController _durationController;
  late TextEditingController _maxParticipantsController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.course?.title ?? '');
    _descriptionController = TextEditingController(text: widget.course?.description ?? '');
    _instructorController = TextEditingController(text: widget.course?.instructor ?? '');
    _durationController = TextEditingController(
      text: widget.course?.durationHours?.toString() ?? '',
    );
    _maxParticipantsController = TextEditingController(
      text: widget.course?.maxParticipants?.toString() ?? '',
    );
    _startDate = widget.course?.startDate;
    _endDate = widget.course?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final cubit = context.read<TrainingCourseCubit>();
      final durationHours = _durationController.text.trim().isEmpty
          ? null
          : int.tryParse(_durationController.text.trim());
      final maxParticipants = _maxParticipantsController.text.trim().isEmpty
          ? null
          : int.tryParse(_maxParticipantsController.text.trim());

      if (widget.course == null) {
        await cubit.createCourse(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          instructor: _instructorController.text.trim().isEmpty ? null : _instructorController.text.trim(),
          durationHours: durationHours,
          maxParticipants: maxParticipants,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await cubit.updateCourse(
          id: widget.course!.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          instructor: _instructorController.text.trim().isEmpty ? null : _instructorController.text.trim(),
          durationHours: durationHours,
          maxParticipants: maxParticipants,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEdit = widget.course != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? localizations.editCourse : localizations.addCourse),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: '${localizations.title} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.school),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: '${localizations.description} *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return localizations.required;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _instructorController,
              decoration: InputDecoration(
                labelText: localizations.instructor,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _durationController,
                    decoration: InputDecoration(
                      labelText: localizations.durationHours,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.access_time),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxParticipantsController,
                    decoration: InputDecoration(
                      labelText: localizations.maxParticipants,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.people),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(localizations.startDate),
              subtitle: Text(_startDate != null
                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                  : localizations.notSelected),
              leading: const Icon(Icons.calendar_today),
              tileColor: Colors.grey.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: Text(localizations.endDate),
              subtitle: Text(_endDate != null
                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                  : localizations.notSelected),
              leading: const Icon(Icons.event),
              tileColor: Colors.grey.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: isEdit ? localizations.update : localizations.create,
              onPressed: _isLoading ? null : _save,
              isLoading: _isLoading,
              icon: isEdit ? Icons.save : Icons.add,
            ),
          ],
        ),
      ),
    );
  }
}
