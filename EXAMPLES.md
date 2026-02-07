# 🎯 Usage Examples

## 🎨 Using Premium Widgets

### Example 1: Login Form with Premium Widgets

```dart
import 'package:flutter/material.dart';
import 'package:role/core/widgets/widgets.dart';
import 'package:role/core/utils/utils.dart';
import 'package:role/core/theme/theme.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email Field
          PremiumTextField(
            controller: _emailController,
            label: 'البريد الإلكتروني',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.email,
          ),
          
          const SizedBox(height: 16),
          
          // Password Field
          PremiumTextField(
            controller: _passwordController,
            label: 'كلمة المرور',
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: _obscurePassword 
                ? Icons.visibility_off 
                : Icons.visibility,
            onSuffixTap: () {
              setState(() => _obscurePassword = !_obscurePassword);
            },
            validator: (value) => Validators.required(value, fieldName: 'كلمة المرور'),
          ),
          
          const SizedBox(height: 24),
          
          // Login Button
          AnimatedButton(
            text: 'تسجيل الدخول',
            icon: Icons.login,
            isLoading: _isLoading,
            onPressed: _handleLogin,
            gradient: AppGradients.primaryGradient,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Login logic here
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        UIHelpers.showSuccessSnackbar(context, 'تم تسجيل الدخول بنجاح');
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackbar(
          context, 
          ErrorHandler.handleError(e),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
```

### Example 2: News List with Skeleton Loading

```dart
import 'package:flutter/material.dart';
import 'package:role/core/widgets/widgets.dart';
import 'package:role/services/database_service.dart';

class NewsList extends StatefulWidget {
  const NewsList({super.key});

  @override
  State<NewsList> createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  final _dbService = DatabaseService();
  List<Map<String, dynamic>> _news = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() => _isLoading = true);
    
    try {
      final news = await _dbService.getAll('news');
      setState(() => _news = news);
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SkeletonLoader(
      isLoading: _isLoading,
      child: ListView.builder(
        itemCount: _news.length,
        itemBuilder: (context, index) {
          final item = _news[index];
          return GlassmorphicCard(
            onTap: () => _navigateToDetail(item['id']),
            child: ListTile(
              title: Text(item['title']),
              subtitle: Text(item['content']),
              trailing: Icon(Icons.chevron_right),
            ),
          );
        },
      ),
    );
  }

  void _navigateToDetail(String id) {
    context.pushWithTransition(
      NewsDetailScreen(newsId: id),
      type: TransitionType.slideFade,
    );
  }
}
```

### Example 3: Settings with Theme Toggle

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:role/core/theme/theme.dart';
import 'package:role/core/widgets/widgets.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicCard(
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return SwitchListTile(
            title: const Text('الوضع الداكن'),
            subtitle: const Text('تفعيل الوضع الليلي'),
            value: state.isDark,
            onChanged: (_) {
              context.read<ThemeCubit>().toggleTheme();
            },
            secondary: Icon(
              state.isDark ? Icons.dark_mode : Icons.light_mode,
            ),
          );
        },
      ),
    );
  }
}
```

### Example 4: Using Validators

```dart
import 'package:role/core/utils/utils.dart';

// Simple validation
PremiumTextField(
  validator: Validators.email,
)

// Required with custom field name
PremiumTextField(
  validator: (value) => Validators.required(value, fieldName: 'الاسم'),
)

// Combine multiple validators
PremiumTextField(
  validator: Validators.combine([
    Validators.required,
    (value) => Validators.minLength(value, 8, fieldName: 'كلمة المرور'),
    Validators.password,
  ]),
)

// Password confirmation
PremiumTextField(
  validator: (value) => Validators.match(
    value, 
    _passwordController.text,
    fieldName: 'تأكيد كلمة المرور',
  ),
)
```

### Example 5: Using Extensions

```dart
import 'package:role/core/utils/utils.dart';

// String extensions
final email = 'test@example.com';
print(email.isEmail);  // true

final text = 'hello world';
print(text.capitalize);  // 'Hello World'

// DateTime extensions
final now = DateTime.now();
print(now.timeAgo);  // 'الآن'
print(now.toArabicDate);  // '7 فبراير 2026'

// int extensions
final bytes = 1024 * 5;
print(bytes.toFileSize);  // '5.0 KB'

final seconds = 3600;
print(seconds.toDurationString);  // '1س 0د 0ث'
```

### Example 6: Error Handling

```dart
import 'package:role/core/utils/utils.dart';

try {
  // Your code here
  await someAsyncOperation();
} catch (e) {
  // Log error
  ErrorHandler.logError(e);
  
  // Get user-friendly message
  final message = ErrorHandler.handleError(e);
  
  // Show to user
  UIHelpers.showErrorSnackbar(context, message);
  
  // Check error type
  if (ErrorHandler.isNetworkError(e)) {
    // Handle network error specifically
  }
}
```

### Example 7: Using UIHelpers

```dart
import 'package:role/core/utils/utils.dart';

// Success message
UIHelpers.showSuccessSnackbar(context, 'تم الحفظ بنجاح');

// Error message
UIHelpers.showErrorSnackbar(context, 'حدث خطأ');

// Info message
UIHelpers.showInfoSnackbar(context, 'معلومة مهمة');

// Loading dialog
UIHelpers.showLoadingDialog(context, message: 'جاري التحميل...');
await someAsyncOperation();
UIHelpers.hideLoadingDialog(context);

// Confirmation dialog
final confirmed = await UIHelpers.showConfirmDialog(
  context,
  title: 'تأكيد الحذف',
  message: 'هل أنت متأكد من حذف هذا العنصر؟',
  isDangerous: true,
);
if (confirmed) {
  // Delete
}

// Bottom sheet
UIHelpers.showCustomBottomSheet(
  context,
  child: YourWidget(),
);
```

### Example 8: Complete Screen Example

```dart
import 'package:flutter/material.dart';
import 'package:role/core/widgets/widgets.dart';
import 'package:role/core/utils/utils.dart';
import 'package:role/core/theme/theme.dart';

class CreateItemScreen extends StatefulWidget {
  const CreateItemScreen({super.key});

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppGradients.darkBackgroundGradient
              : AppGradients.lightBackgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: UIHelpers.getResponsivePadding(context),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  PremiumTextField(
                    controller: _titleController,
                    label: 'العنوان',
                    prefixIcon: Icons.title,
                    validator: (value) => Validators.required(
                      value,
                      fieldName: 'العنوان',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  PremiumTextField(
                    controller: _descriptionController,
                    label: 'الوصف',
                    prefixIcon: Icons.description,
                    maxLines: 5,
                    validator: Validators.combine([
                      Validators.required,
                      (value) => Validators.minLength(
                        value,
                        10,
                        fieldName: 'الوصف',
                      ),
                    ]),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Submit Button
                  AnimatedButton(
                    text: 'حفظ',
                    icon: Icons.save,
                    isLoading: _isLoading,
                    onPressed: _handleSubmit,
                    gradient: AppGradients.successGradient,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      // Your save logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        UIHelpers.showSuccessSnackbar(context, 'تم الحفظ بنجاح');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        UIHelpers.showErrorSnackbar(
          context,
          ErrorHandler.handleError(e),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

---

## 🎯 Best Practices

1. **Always use barrel files** للاستيراد النظيف:
   ```dart
   import 'package:role/core/widgets/widgets.dart';
   import 'package:role/core/utils/utils.dart';
   import 'package:role/core/theme/theme.dart';
   ```

2. **استخدم Validators.combine** للـ validations المعقدة

3. **استخدم ErrorHandler.handleError** لمعالجة كل الأخطاء

4. **استخدم UIHelpers** للـ Snackbars والـ Dialogs

5. **استخدم Extensions** لتبسيط الكود
