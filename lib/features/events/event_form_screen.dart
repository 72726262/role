import 'package:flutter/material.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../models/event_model.dart';
import '../../services/database_service.dart';

/// Event Form Screen
/// Create or edit event

class EventFormScreen extends StatefulWidget {
  final EventModel? event;

  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  bool get _isEditing => widget.event != null;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _descriptionController.text = widget.event!.description ?? '';
      _selectedDate = widget.event!.eventDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.eventDate);
      _locationController.text = widget.event!.location ?? '';
      _maxAttendeesController.text = widget.event!.maxAttendees?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
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
              // Header
              Container(
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
                    Expanded(
                      child: Text(
                        _isEditing ? 'تعديل فعالية' : 'إنشاء فعالية',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Title
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'عنوان الفعالية',
                              prefixIcon: Icon(Icons.title),
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال عنوان الفعالية';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Description
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'الوصف',
                              prefixIcon: Icon(Icons.description),
                              border: InputBorder.none,
                            ),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال وصف الفعالية';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Date & Time
                        Row(
                          children: [
                            Expanded(
                              child: GlassmorphicCard(
                                onTap: () => _selectDate(),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          _selectedDate != null
                                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                              : 'اختر التاريخ',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: GlassmorphicCard(
                                onTap: () => _selectTime(),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.access_time),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          _selectedTime != null
                                              ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                              : 'اختر الوقت',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Location
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _locationController,
                            decoration: const InputDecoration(
                              labelText: 'الموقع (اختياري)',
                              prefixIcon: Icon(Icons.location_on),
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Max Attendees
                        GlassmorphicCard(
                          child: TextFormField(
                            controller: _maxAttendeesController,
                            decoration: const InputDecoration(
                              labelText: 'الحد الأقصى للحضور (اختياري)',
                              prefixIcon: Icon(Icons.people),
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // Submit Button
                        AnimatedButton(
                          text: _isEditing ? 'تحديث' : 'إنشاء',
                          icon: _isEditing ? Icons.save : Icons.add,
                          isLoading: _isLoading,
                          onPressed: _isLoading ? null : _submit,
                          width: double.infinity,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار التاريخ والوقت'),
          backgroundColor: AppColors.accentError,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'event_date': eventDateTime.toIso8601String(),
        'location': _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        'max_attendees': _maxAttendeesController.text.isEmpty
            ? null
            : int.tryParse(_maxAttendeesController.text),
      };

      final dbService = DatabaseService();

      if (_isEditing) {
        await dbService.update('events', widget.event!.id, eventData);
      } else {
        await dbService.create('events', {
          ...eventData,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم التحديث بنجاح' : 'تم الإنشاء بنجاح'),
            backgroundColor: AppColors.accentLight,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppColors.accentError,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
