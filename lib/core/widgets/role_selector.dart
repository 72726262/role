import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Professional Role Selector Widget
/// Shows roles from database with descriptions
class RoleSelector extends StatelessWidget {
  final String? selectedRoleId;
  final List<RoleOption> roles;
  final Function(String roleId, String roleName) onRoleSelected;
  final bool enabled;

  const RoleSelector({
    super.key,
    this.selectedRoleId,
    required this.roles,
    required this.onRoleSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Find selected role
    final selectedRole = roles.firstWhere(
      (r) => r.id == selectedRoleId,
      orElse: () => roles.first,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? Colors.white : AppTheme.surfaceColor,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: enabled ? () => _showRoleBottomSheet(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Icon(
                  Icons.badge_outlined,
                  color: enabled ? AppTheme.primaryColor : AppTheme.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                
                // Selected role info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الدور الوظيفي',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedRole.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (selectedRole.description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          selectedRole.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary.withValues(alpha: 0.8),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Dropdown icon
                Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? AppTheme.textSecondary : AppTheme.textSecondary.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRoleBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Text(
                    'اختر الدور الوظيفي',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Roles list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: roles.length,
                itemBuilder: (context, index) {
                  final role = roles[index];
                  final isSelected = role.id == selectedRoleId;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryColor.withValues(alpha: 0.1)
                            : AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        role.icon,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                    title: Text(
                      role.displayName,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                      ),
                    ),
                    subtitle: role.description != null
                        ? Text(
                            role.description!,
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_circle,
                            color: AppTheme.primaryColor,
                          )
                        : null,
                    onTap: () {
                      onRoleSelected(role.id, role.roleName);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Role Option Data Class
class RoleOption {
  final String id; // UUID from database
  final String roleName; // Employee, HR, IT, etc.
  final String displayName; // موظف، موارد بشرية، etc.
  final String? description;
  final IconData icon;

  const RoleOption({
    required this.id,
    required this.roleName,
    required this.displayName,
    this.description,
    required this.icon,
  });

  factory RoleOption.fromJson(Map<String, dynamic> json) {
    final roleName = json['role_name'] as String;
    
    return RoleOption(
      id: json['id'] as String,
      roleName: roleName,
      displayName: _getDisplayName(roleName),
      description: json['description'] as String?,
      icon: _getIcon(roleName),
    );
  }

  static String _getDisplayName(String roleName) {
    switch (roleName) {
      case 'Employee':
        return 'موظف';
      case 'HR':
        return 'موارد بشرية';
      case 'IT':
        return 'تقنية المعلومات';
      case 'Management':
        return 'إدارة';
      case 'Admin':
        return 'مسؤول';
      default:
        return roleName;
    }
  }

  static IconData _getIcon(String roleName) {
    switch (roleName) {
      case 'Employee':
        return Icons.person;
      case 'HR':
        return Icons.people;
      case 'IT':
        return Icons.computer;
      case 'Management':
        return Icons.business_center;
      case 'Admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.badge;
    }
  }
}
