import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_card.dart';

class NavigationLinksScreen extends StatefulWidget {
  const NavigationLinksScreen({super.key});

  @override
  State<NavigationLinksScreen> createState() => _NavigationLinksScreenState();
}

class _NavigationLinksScreenState extends State<NavigationLinksScreen> {
  final List<Map<String, dynamic>> _links = [
    {'title': 'دليل الموظف', 'icon': 'menu_book', 'url': 'https://company.com/handbook', 'order': 1, 'active': true},
    {'title': 'نظام الرواتب', 'icon': 'payments', 'url': 'https://payroll.company.com', 'order': 2, 'active': true},
    {'title': 'حجز قاعات', 'icon': 'meeting_room', 'url': 'https://booking.company.com', 'order': 3, 'active': true},
    {'title': 'الدعم الفني', 'icon': 'support', 'url': 'https://support.company.com', 'order': 4, 'active': true},
    {'title': 'بوابة التدريب', 'icon': 'school', 'url': 'https://training.company.com', 'order': 5, 'active': true},
    {'title': 'التقويم', 'icon': 'calendar_today', 'url': 'https://calendar.company.com', 'order': 6, 'active': true},
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.navigationLinks),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showLinkDialog(),
          ),
        ],
      ),
      body: ReorderableListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _links.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = _links.removeAt(oldIndex);
            _links.insert(newIndex, item);
            for (int i = 0; i < _links.length; i++) {
              _links[i]['order'] = i + 1;
            }
          });
        },
        itemBuilder: (context, index) {
          final link = _links[index];
          return Padding(
            key: ValueKey(link['title']),
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(_getIconData(link['icon'])),
                ),
                title: Text(link['title']),
                subtitle: Text(link['url']),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: link['active'],
                      onChanged: (value) {
                        setState(() {
                          link['active'] = value;
                        });
                      },
                    ),
                    PopupMenuButton(
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
                          _showLinkDialog(link: link);
                        } else if (value == 'delete') {
                          setState(() => _links.remove(link));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'menu_book': return Icons.menu_book;
      case 'payments': return Icons.payments;
      case 'meeting_room': return Icons.meeting_room;
      case 'support': return Icons.support_agent;
      case 'school': return Icons.school;
      case 'calendar_today': return Icons.calendar_today;
      default: return Icons.link;
    }
  }

  void _showLinkDialog({Map<String, dynamic>? link}) {
    final localizations = AppLocalizations.of(context);
    final isEdit = link != null;
    final titleController = TextEditingController(text: link?['title'] ?? '');
    final urlController = TextEditingController(text: link?['url'] ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? localizations.editLink : localizations.addLink),
        content: Column(
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
              controller: urlController,
              decoration: InputDecoration(
                labelText: localizations.url,
                border: OutlineInputBorder(),
              ),
            ),
          ],
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
                  link['title'] = titleController.text;
                  link['url'] = urlController.text;
                });
              } else {
                setState(() {
                  _links.add({
                    'title': titleController.text,
                    'icon': 'link',
                    'url': urlController.text,
                    'order': _links.length + 1,
                    'active': true,
                  });
                });
              }
              Navigator.pop(dialogContext);
            },
            child: Text(isEdit ? localizations.update : localizations.create),
          ),
        ],
      ),
    );
  }
}
