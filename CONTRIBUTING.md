# Contributing to Employee Portal

Thank you for your interest in contributing to the Employee Portal project! 🎉

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Standards](#code-standards)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)

---

## 🤝 Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Help others learn and grow
- Keep discussions professional

---

## 🚀 Getting Started

### 1. Fork & Clone

```bash
git clone https://github.com/yourcompany/employee-portal.git
cd employee-portal
```

### 2. Setup Development Environment

```bash
flutter pub get
```

### 3. Create Feature Branch

```bash
git checkout -b feature/your-feature-name
```

---

## 💻 Development Workflow

### Branch Naming Convention

- `feature/` - New features (e.g., `feature/add-notifications`)
- `bugfix/` - Bug fixes (e.g., `bugfix/login-error`)
- `hotfix/` - Urgent production fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates

### Commit Message Format

```
<type>: <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code formatting (no logic change)
- `refactor`: Code restructuring
- `test`: Adding tests
- `chore`: Build process or dependencies

**Example:**
```
feat: Add user management screen

- Implemented user CRUD operations
- Added role change functionality
- Included activate/deactivate toggle

Closes #123
```

---

## 📝 Code Standards

### Flutter/Dart Guidelines

1. **Follow Effective Dart**: https://dart.dev/guides/language/effective-dart
2. **Use Linter**: Run `flutter analyze` before committing
3. **Format Code**: Run `dart format .` to auto-format
4. **Write Tests**: Add tests for new features

### File Naming

- **Screens**: `screen_name_screen.dart` (e.g., `login_screen.dart`)
- **Widgets**: `widget_name.dart` (e.g., `custom_button.dart`)
- **Cubits**: `feature_cubit.dart` (e.g., `auth_cubit.dart`)
- **Models**: `model_name_model.dart` (e.g., `user_model.dart`)

### Code Structure

```dart
// 1. Imports (Flutter, Packages, then Local)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';

// 2. Class Definition
class MyWidget extends StatelessWidget {
  // 3. Constructor
  const MyWidget({super.key});

  // 4. Methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Localization

Always add translations for both Arabic and English:

```dart
// In app_localizations.dart
String get myFeature => isArabic ? 'ميزتي' : 'My Feature';
```

---

## 🔄 Submitting Changes

### 1. Ensure Quality

```bash
# Format code
dart format .

# Run analyzer
flutter analyze

# Run tests
flutter test
```

### 2. Commit Changes

```bash
git add .
git commit -m "feat: your feature description"
```

### 3. Push to Fork

```bash
git push origin feature/your-feature-name
```

### 4. Create Pull Request

1. Go to repository on GitHub
2. Click "New Pull Request"
3. Select your branch
4. Fill in PR template:
   - **Title**: Brief description
   - **Description**: What changed and why
   - **Screenshots**: For UI changes
   - **Testing**: How you tested it
5. Request review from maintainers

### PR Review Process

- Code review by 1-2 maintainers
- All checks must pass (linter, tests)
- Address feedback promptly
- Once approved, it will be merged

---

## 🐛 Reporting Bugs

### Before Submitting

1. Check existing issues
2. Verify it's reproducible
3. Gather necessary info:
   - Flutter version (`flutter --version`)
   - Device/Emulator details
   - Steps to reproduce
   - Expected vs Actual behavior

### Bug Report Template

```markdown
**Describe the bug**
A clear description of what the bug is.

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What you expected to happen.

**Screenshots**
Add screenshots if applicable.

**Environment:**
- Flutter version: [e.g., 3.10.0]
- Device: [e.g., Pixel 5]
- OS: [e.g., Android 13]
```

---

## ✨ Feature Requests

We welcome feature suggestions! Please include:

1. **Use case**: Why is this needed?
2. **Proposed solution**: How should it work?
3. **Alternatives**: Other approaches you considered
4. **Impact**: Who benefits from this?

---

## 📚 Documentation

When adding features, update:

- `README.md` - If user-facing
- Code comments - For complex logic
- `walkthrough.md` - For major features
- Inline documentation - For public APIs

---

## 🧪 Testing

### Write Tests For:
- New features
- Bug fixes
- Complex business logic

### Test Types:
```bash
# Unit tests
flutter test test/unit

# Widget tests
flutter test test/widgets

# Integration tests
flutter test integration_test
```

---

## 🏗️ Architecture

### Follow 3-Layer Architecture:

```
lib/
├── models/       # Data models
├── services/     # Business logic
├── cubits/       # State management
└── features/     # UI (screens & widgets)
```

### State Management Rules:
- Use **Cubit** for all state management
- Keep UI logic separate from business logic
- Emit states, don't mutate

---

## 🎨 UI/UX Guidelines

1. **Material Design 3**: Follow Material Design principles
2. **RTL Support**: Test all screens in Arabic (RTL)
3. **Responsive**: Test on different screen sizes
4. **Accessibility**: Use semantic widgets, proper contrast
5. **Loading States**: Show loading indicators
6. **Error Handling**: User-friendly error messages

---

## 📦 Dependencies

Before adding new dependencies:

1. Check if existing package can be used
2. Verify package is actively maintained
3. Check for breaking changes
4. Update `pubspec.yaml` and `pubspec.lock`

---

## 🔐 Security

- Never commit sensitive data (API keys, passwords)
- Use `.env` for configuration
- Follow RLS best practices
- Validate all user inputs
- Report security vulnerabilities privately

---

## 📞 Questions?

- Open a discussion in GitHub Discussions
- Ask in team chat
- Email: dev@company.com

---

## 🙏 Thank You!

Your contributions make this project better! Every PR, issue, and suggestion helps improve the Employee Portal.

**Happy Coding! 🚀**
