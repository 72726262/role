import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_card.dart';

class EventsManagementScreen extends StatefulWidget {
  const EventsManagementScreen({super.key});

  @override
  State<EventsManagementScreen> createState() => _EventsManagementScreenState();
}

class _EventsManagementScreenState extends State<EventsManagementScreen> {
  final List<Map<String, dynamic>> _events = [
    {
      'title': 'عيد ميلاد أحمد',
      'description': 'الاحتفال بعيد ميلاد أحمد',
      'type': 'birthday',
      'date': DateTime.now().add(Duration(days: 3)),
      'icon': 'cake',
    },
    {
      'title': 'اجتماع فريق IT',
      'description': 'اجتماع شهري',
      'type': 'meeting',
      'date': DateTime.now().add(Duration(days: 7)),
      'icon': 'groups',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.eventsManagement),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showEventDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          final dateFormat = DateFormat.yMMMd();
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getEventColor(event['type']).withOpacity(0.2),
                  child: Icon(_getEventIcon(event['icon']), color: _getEventColor(event['type'])),
                ),
                title: Text(event['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event['description'] != null) Text(event['description']),
                    SizedBox(height: 4),
                    Text(dateFormat.format(event['date']), style: TextStyle(fontSize: 12)),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text(localizations.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text(localizations.delete, style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEventDialog(event: event);
                    } else if (value == 'delete') {
                      setState(() => _events.remove(event));
                    }
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getEventColor(String type) {
    switch (type) {
      case 'birthday': return Colors.pink;
      case 'meeting': return Colors.blue;
      case 'celebration': return Colors.orange;
      case 'training': return Colors.purple;
      default: return Colors.grey;
    }
  }

  IconData _getEventIcon(String icon) {
    switch (icon) {
      case 'cake': return Icons.cake;
      case 'groups': return Icons.groups;
      case 'celebration': return Icons.celebration;
      case 'security': return Icons.security;
      default: return Icons.event;
    }
  }

  void _showEventDialog({Map<String, dynamic>? event}) {
    final localizations = AppLocalizations.of(context);
    final isEdit = event != null;
    final titleController = TextEditingController(text: event?['title'] ?? '');
    final descController = TextEditingController(text: event?['description'] ?? '');
    DateTime selectedDate = event?['date'] ?? DateTime.now();
    String selectedType = event?['type'] ?? 'meeting';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? localizations.editEvent : localizations.addEvent),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: localizations.title,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: localizations.description,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: localizations.eventType,
                    border: OutlineInputBorder(),
                  ),
                  items: ['birthday', 'meeting', 'celebration', 'training']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedType = value!);
                  },
                ),
                SizedBox(height: 12),
                ListTile(
                  title: Text(localizations.date),
                  subtitle: Text(DateFormat.yMMMd().format(selectedDate)),
                  trailing: Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () {
                if (isEdit) {
                  setState(() {
                    event['title'] = titleController.text;
                    event['description'] = descController.text;
                    event['type'] = selectedType;
                    event['date'] = selectedDate;
                  });
                } else {
                  setState(() {
                    _events.add({
                      'title': titleController.text,
                      'description': descController.text,
                      'type': selectedType,
                      'date': selectedDate,
                      'icon': selectedType == 'birthday' ? 'cake' : 'groups',
                    });
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: Text(isEdit ? localizations.update : localizations.create),
            ),
          ],
        ),
      ),
    );
  }
}
