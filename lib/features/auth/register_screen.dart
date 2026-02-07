import 'package:employee_portal/core/widgets/custom_text_field.dart';
import 'package:employee_portal/core/widgets/role_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_theme.dart';

import '../../cubits/auth/register_cubit.dart';
import '../../cubits/auth/register_state.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _phoneController = TextEditingController();

  String? _selectedRoleId;
  String _selectedRoleName = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loadingRoles = true;
  List<RoleOption> _roles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _loadingRoles = true);

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('roles')
          .select('id, role_name, description')
          .order('role_name');

      final rolesList =
          (response as List).map((json) => RoleOption.fromJson(json)).toList();

      setState(() {
        _roles = rolesList;
        if (_roles.isNotEmpty) {
          _selectedRoleId = _roles.first.id;
          _selectedRoleName = _roles.first.roleName;
        }
        _loadingRoles = false;
      });
    } catch (e) {
      setState(() => _loadingRoles = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحميل الأدوار: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedRoleId == null || _selectedRoleName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء اختيار الدور الوظيفي'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<RegisterCubit>().register(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: _selectedRoleName,
            department: _departmentController.text.trim(),
            phoneNumber: _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(); // Go back to login
          } else if (state is RegisterError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is RegisterLoading;

          return Scaffold(
              body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Back Button
                            Align(
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ),

                            // Title
                            const Text(
                              'إنشاء حساب جديد',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'أدخل بياناتك لإنشاء حساب موظف',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // Full Name
                            CustomTextField(
                              controller: _fullNameController,
                              label: 'الاسم الكامل',
                              prefixIcon: Icons.person_outline,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الاسم الكامل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Email
                            CustomTextField(
                              controller: _emailController,
                              label: 'البريد الإلكتروني',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!value.contains('@')) {
                                  return 'البريد الإلكتروني غير صحيح';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password
                            CustomTextField(
                              controller: _passwordController,
                              label: 'كلمة المرور',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Confirm Password
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'تأكيد كلمة المرور',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword;
                                  });
                                },
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء تأكيد كلمة المرور';
                                }
                                if (value != _passwordController.text) {
                                  return 'كلمة المرور غير متطابقة';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Role Selector
                            if (_loadingRoles)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else
                              RoleSelector(
                                selectedRoleId: _selectedRoleId,
                                roles: _roles,
                                enabled: !isLoading,
                                onRoleSelected: (roleId, roleName) {
                                  setState(() {
                                    _selectedRoleId = roleId;
                                    _selectedRoleName = roleName;
                                  });
                                },
                              ),
                            const SizedBox(height: 16),

                            // Department
                            CustomTextField(
                              controller: _departmentController,
                              label: 'القسم',
                              prefixIcon: Icons.business_outlined,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال القسم';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Phone Number (Optional)
                            CustomTextField(
                              controller: _phoneController,
                              label: 'رقم الهاتف (اختياري)',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 32),

                            // Register Button
                            SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _handleRegister(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text(
                                        'إنشاء حساب',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Login Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('لديك حساب بالفعل؟'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'تسجيل الدخول',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ));
        },
      ),
    );
  }
}
