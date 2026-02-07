import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import '../../core/widgets/animated_button.dart';
import '../../cubits/admin/users_list_cubit.dart';
import '../../cubits/admin/users_list_state.dart';
import '../../models/user_model.dart';
import '../auth/register_screen.dart';
import 'user_detail_screen.dart';

/// 👥 Users List Screen
/// Displays all users with search, filter, and management options

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final _searchController = TextEditingController();
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    context.read<UsersListCubit>().loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
              _buildHeader(isDark),

              // Search and Filter
              _buildSearchFilter(isDark),

              // Users List
              Expanded(
                child: BlocBuilder<UsersListCubit, UsersListState>(
                  builder: (context, state) {
                    if (state is UsersListError) {
                      return _buildError(state.message);
                    }

                    final users =
                        state is UsersListLoaded ? state.users : _mockUsers;
                    final isLoading = state is UsersListLoading;

                    final filteredUsers = _filterUsers(users);

                    return Skeletonizer(
                      enabled: isLoading,
                      child: filteredUsers.isEmpty
                          ? _buildEmptyState()
                          : RefreshIndicator(
                              onRefresh: () =>
                                  context.read<UsersListCubit>().loadUsers(),
                              child: ListView.builder(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                itemCount: filteredUsers.length,
                                itemBuilder: (context, index) {
                                  return _buildUserCard(
                                    filteredUsers[index],
                                    isDark,
                                    isLoading,
                                  );
                                },
                              ),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddUser(),
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة موظف'),
        backgroundColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
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
          const Expanded(
            child: Text(
              'إدارة المستخدمين',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<UsersListCubit, UsersListState>(
            builder: (context, state) {
              if (state is UsersListLoaded) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    '${state.users.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchFilter(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          // Search Field
          GlassmorphicCard(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن موظف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Role Filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('all', 'الكل', Icons.people),
                _buildFilterChip('Employee', 'موظف', Icons.person),
                _buildFilterChip('HR', 'موارد بشرية', Icons.badge),
                _buildFilterChip('IT', 'تقنية', Icons.computer),
                _buildFilterChip('Management', 'إدارة', Icons.business),
                _buildFilterChip('Admin', 'مسؤول', Icons.admin_panel_settings),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _selectedRole == value;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sm),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
        onSelected: (_) {
          setState(() {
            _selectedRole = value;
          });
        },
        backgroundColor: AppColors.surfaceLight,
        selectedColor: AppColors.primaryLight,
      ),
    );
  }

  Widget _buildUserCard(UserModel user, bool isDark, bool isLoading) {
    return GlassmorphicCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: isLoading ? null : () => _navigateToUserDetail(user),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: _getRoleColor(user.role),
            backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null || user.photoUrl!.isEmpty
                ? Text(
                    user.fullName.isNotEmpty
                        ? user.fullName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      _getRoleIcon(user.role),
                      size: 16,
                      color: _getRoleColor(user.role),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getRoleLabel(user.role),
                      style: TextStyle(
                        color: _getRoleColor(user.role),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status & Arrow
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: user.isActive
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Text(
                  user.isActive ? 'نشط' : 'معطل',
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'لا يوجد مستخدمين',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ابدأ بإضافة موظفين جدد',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppColors.accentError,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.accentError,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AnimatedButton(
            text: 'إعادة المحاولة',
            icon: Icons.refresh,
            onPressed: () => context.read<UsersListCubit>().loadUsers(),
          ),
        ],
      ),
    );
  }

  List<UserModel> _filterUsers(List<UserModel> users) {
    var filtered = users;

    // Filter by role
    if (_selectedRole != 'all') {
      filtered = filtered.where((u) => u.role == _selectedRole).toList();
    }

    // Filter by search
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filtered = filtered
          .where((u) =>
              u.fullName.toLowerCase().contains(query) ||
              u.email.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  void _navigateToAddUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RegisterScreen(isAdminCreating: true),
      ),
    );

    if (result == true && mounted) {
      context.read<UsersListCubit>().loadUsers();
    }
  }

  void _navigateToUserDetail(UserModel user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(userId: user.id),
      ),
    );

    if (result == true && mounted) {
      context.read<UsersListCubit>().loadUsers();
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Management':
        return Colors.purple;
      case 'HR':
        return Colors.blue;
      case 'IT':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'Admin':
        return Icons.admin_panel_settings;
      case 'Management':
        return Icons.business;
      case 'HR':
        return Icons.badge;
      case 'IT':
        return Icons.computer;
      default:
        return Icons.person;
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'Admin':
        return 'مسؤول';
      case 'Management':
        return 'إدارة';
      case 'HR':
        return 'موارد بشرية';
      case 'IT':
        return 'تقنية معلومات';
      default:
        return 'موظف';
    }
  }

  // Mock users for skeleton loading
  List<UserModel> get _mockUsers => List.generate(
        5,
        (i) => UserModel(
          id: 'mock_$i',
          email: 'user$i@company.com',
          fullName: 'المستخدم رقم $i',
          roleId: 'mock-role-id',
          role: i % 2 == 0 ? 'Admin' : 'Employee',
          isActive: i % 3 != 0,
          createdAt: DateTime.now().subtract(Duration(days: i * 10)),
          updatedAt: DateTime.now(),
        ),
      );
}
