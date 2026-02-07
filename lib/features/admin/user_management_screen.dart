import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/custom_button.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Admin User',
      'email': 'admin@company.com',
      'role': 'Admin',
      'active': true,
    },
    {
      'name': 'HR Manager',
      'email': 'hr@company.com',
      'role': 'HR',
      'active': true,
    },
    {
      'name': 'IT Manager',
      'email': 'it@company.com',
      'role': 'IT',
      'active': true,
    },
    {
      'name': 'General Manager',
      'email': 'manager@company.com',
      'role': 'Management',
      'active': true,
    },
    {
      'name': 'John Doe',
      'email': 'employee@company.com',
      'role': 'Employee',
      'active': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.userManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showUserFormDialog(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CustomCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getRoleColor(user['role']).withOpacity(0.2),
                  child: Text(
                    user['name'][0].toUpperCase(),
                    style: TextStyle(
                      color: _getRoleColor(user['role']),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user['name'],
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(user['email'], style: theme.textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user['role']).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user['role'],
                        style: TextStyle(
                          fontSize: 12,
                          color: _getRoleColor(user['role']),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
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
                      value: 'change_role',
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz),
                          const SizedBox(width: 8),
                          Text(localizations.changeRole),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(user['active'] ? Icons.block : Icons.check_circle),
                          const SizedBox(width: 8),
                          Text(user['active'] ? localizations.deactivate : localizations.activate),
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
                      _showUserFormDialog(user: user);
                    } else if (value == 'change_role') {
                      _showRoleChangeDialog(user);
                    } else if (value == 'toggle_status') {
                      setState(() {
                        user['active'] = !user['active'];
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            user['active'] ? localizations.userActivated : localizations.userDeactivated,
                          ),
                        ),
                      );
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, user);
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

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'HR':
        return Colors.purple;
      case 'IT':
        return Colors.blue;
      case 'Management':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showUserFormDialog({Map<String, dynamic>? user}) {
    final localizations = AppLocalizations.of(context);
    final isEdit = user != null;
    final nameController = TextEditingController(text: user?['name'] ?? '');
    final emailController = TextEditingController(text: user?['email'] ?? '');
    String selectedRole = user?['role'] ?? 'Employee';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? localizations.editUser : localizations.addUser),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: localizations.fullName,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: localizations.email,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: localizations.role,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.admin_panel_settings),
                ),
                items: ['Admin', 'HR', 'IT', 'Management', 'Employee']
                    .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                    .toList(),
                onChanged: (value) {
                  selectedRole = value!;
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
                  user['name'] = nameController.text;
                  user['email'] = emailController.text;
                  user['role'] = selectedRole;
                });
              } else {
                setState(() {
                  _users.add({
                    'name': nameController.text,
                    'email': emailController.text,
                    'role': selectedRole,
                    'active': true,
                  });
                });
              }
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? localizations.userUpdated : localizations.userCreated),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(isEdit ? localizations.update : localizations.create),
          ),
        ],
      ),
    );
  }

  void _showRoleChangeDialog(Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context);
    String selectedRole = user['role'];

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.changeRole),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${user['name']} - ${user['email']}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedRole,
              decoration: InputDecoration(
                labelText: localizations.newRole,
                border: const OutlineInputBorder(),
              ),
              items: ['Admin', 'HR', 'IT', 'Management', 'Employee']
                  .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                  .toList(),
              onChanged: (value) {
                selectedRole = value!;
              },
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
              setState(() {
                user['role'] = selectedRole;
              });
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.roleChanged),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(localizations.change),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Map<String, dynamic> user) {
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.confirmDelete),
        content: Text('${localizations.deleteUserConfirm} ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.cancel),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _users.remove(user);
              });
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.userDeleted),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(localizations.delete),
          ),
        ],
      ),
    );
  }
}
