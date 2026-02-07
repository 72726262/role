import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.notificationsCenter),
        actions: [
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () => _showSendNotificationDialog(context),
          ),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(text: localizations.email, icon: Icon(Icons.email)),
                Tab(text: localizations.push, icon: Icon(Icons.notifications)),
                Tab(text: 'WhatsApp', icon: Icon(Icons.message)),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _NotificationsList(type: 'email'),
                  _NotificationsList(type: 'push'),
                  _NotificationsList(type: 'whatsapp'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'email';
    String selectedTarget = 'all';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(localizations.sendNotification),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: localizations.notificationType,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'email', child: Text(localizations.email)),
                    DropdownMenuItem(value: 'push', child: Text(localizations.push)),
                    DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                  ],
                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedTarget,
                  decoration: InputDecoration(
                    labelText: localizations.target,
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    DropdownMenuItem(value: 'all', child: Text(localizations.allUsers)),
                    DropdownMenuItem(value: 'role', child: Text(localizations.byRole)),
                    DropdownMenuItem(value: 'specific', child: Text(localizations.specificUsers)),
                  ],
                  onChanged: (value) => setState(() => selectedTarget = value!),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: localizations.title,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  decoration: InputDecoration(
                    labelText: localizations.message,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
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
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(localizations.notificationSent),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(localizations.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsList extends StatelessWidget {
  final String type;

  const _NotificationsList({required this.type});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final notifications = _getSampleNotifications(type);

    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(localizations.noNotifications),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notif = notifications[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CustomCard(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: _getTypeColor(type).withOpacity(0.2),
                child: Icon(_getTypeIcon(type), color: _getTypeColor(type)),
              ),
              title: Text(notif['title']),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(notif['message']),
                  SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_Hm().format(notif['date']),
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              trailing: Icon(
                notif['sent'] ? Icons.check_circle : Icons.pending,
                color: notif['sent'] ? Colors.green : Colors.orange,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getSampleNotifications(String type) {
    return [
      {
        'title': 'Welcome Message',
        'message': 'Welcome to the employee portal',
        'date': DateTime.now().subtract(Duration(hours: 2)),
        'sent': true,
      },
      {
        'title': 'System Update',
        'message': 'New features available',
        'date': DateTime.now().subtract(Duration(days: 1)),
        'sent': true,
      },
    ];
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'email': return Colors.blue;
      case 'push': return Colors.orange;
      case 'whatsapp': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'email': return Icons.email;
      case 'push': return Icons.notifications;
      case 'whatsapp': return Icons.message;
      default: return Icons.info;
    }
  }
}
