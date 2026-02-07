import 'package:employee_portal/core/theme/theme_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/advanced_theme_system.dart';
import '../../core/widgets/glassmorphic_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ⚙️ Settings Screen
/// Premium settings interface with dark mode support

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackgroundGradient
              : AppGradients.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'الإعدادات',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: AppGradients.primaryGradient,
                    ),
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.md),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Profile Section
                    _buildSection(
                      context,
                      title: 'الحساب',
                      icon: Icons.person_outline,
                      children: [
                        _buildTile(
                          context,
                          icon: Icons.email_outlined,
                          title: 'البريد الإلكتروني',
                          subtitle: user?.email ?? 'غير متوفر',
                          onTap: () {},
                        ),
                        _buildTile(
                          context,
                          icon: Icons.lock_outline,
                          title: 'تغيير كلمة المرور',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Appearance Section
                    _buildSection(
                      context,
                      title: 'المظهر',
                      icon: Icons.palette_outlined,
                      children: [
                        _buildThemeToggle(context),
                        _buildTile(
                          context,
                          icon: Icons.language_outlined,
                          title: 'اللغة',
                          subtitle: 'العربية',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Notifications Section
                    _buildSection(
                      context,
                      title: 'الإشعارات',
                      icon: Icons.notifications_outlined,
                      children: [
                        _buildSwitchTile(
                          context,
                          icon: Icons.notifications_active_outlined,
                          title: 'تفعيل الإشعارات',
                          value: true,
                          onChanged: (value) {},
                        ),
                        _buildSwitchTile(
                          context,
                          icon: Icons.email_outlined,
                          title: 'إشعارات البريد',
                          value: true,
                          onChanged: (value) {},
                        ),
                        _buildSwitchTile(
                          context,
                          icon: Icons.phone_android_outlined,
                          title: 'الإشعارات الفورية',
                          value: true,
                          onChanged: (value) {},
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // About Section
                    _buildSection(
                      context,
                      title: 'حول',
                      icon: Icons.info_outline,
                      children: [
                        _buildTile(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'سياسة الخصوصية',
                          onTap: () {},
                        ),
                        _buildTile(
                          context,
                          icon: Icons.description_outlined,
                          title: 'الشروط والأحكام',
                          onTap: () {},
                        ),
                        _buildTile(
                          context,
                          icon: Icons.info_outlined,
                          title: 'عن التطبيق',
                          subtitle: 'الإصدار 1.0.0',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Logout Button
                    GlassmorphicCard(
                      onTap: () async {
                        await Supabase.instance.client.auth.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacementNamed('/');
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.logout,
                            color: AppColors.accentError,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'تسجيل الخروج',
                            style: TextStyle(
                              color: AppColors.accentError,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        GlassmorphicCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggle(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return ListTile(
          leading: Icon(state.isDark ? Icons.dark_mode : Icons.light_mode),
          title: const Text('الوضع الداكن'),
          trailing: Switch(
            value: state.isDark,
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
