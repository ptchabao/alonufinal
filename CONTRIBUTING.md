# Contributing to ALONU

First off, thank you for considering contributing to ALONU! It's people like you that make ALONU such a great platform.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the issue list as you might find out that you don't need to create one.

When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title**
* **Describe the exact steps which reproduce the problem**
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps**
* **Explain which behavior you expected to see instead and why**
* **Include screenshots if possible**
* **Include your environment details**:
  - Flutter version (`flutter --version`)
  - Device/Emulator OS and version
  - App version

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title**
* **Provide a step-by-step description of the suggested enhancement**
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain the expected behavior**
* **Explain why this enhancement would be useful**

### Pull Requests

* Fill in the required template
* Follow the Dart styleguides (see below)
* Include appropriate test cases
* Update documentation as needed
* End all files with a newline

## Styleguides

### Git Commit Messages

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line
* Consider starting the commit message with an applicable emoji:
  - 🎨 when improving the format/structure of the code
  - 🚀 when improving performance
  - 📝 when writing docs
  - 🐛 when fixing a bug
  - ✨ when adding a new feature
  - ♻️ when refactoring code
  - 🧪 when adding tests
  - 🔒 when dealing with security
  - ⬆️ when upgrading dependencies
  - ⬇️ when downgrading dependencies

### Dart Styleguide

* Follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
* Use `flutter format` to format your code
* Use `flutter analyze` to check for issues
* Name classes with PascalCase
* Name variables and functions with camelCase
* Use meaningful variable names
* Add documentation comments for public APIs:

```dart
/// Calculates the sum of [a] and [b].
///
/// Returns the sum of the two integers.
int add(int a, int b) => a + b;
```

### Architecture Guidelines

* Follow Clean Architecture principles
* Keep layers separated: presentation, domain, data
* Use repository pattern for data access
* Keep business logic in use cases
* Use Riverpod providers for state management
* Map API responses to domain entities

### Testing Guidelines

* Write tests for all new features
* Maintain test coverage above 80%
* Use descriptive test names
* Group related tests with `group()`
* Test both success and failure cases

```dart
void main() {
  group('AuthRepository', () {
    test('login should return user on success', () {
      // Arrange
      // Act
      // Assert
    });

    test('login should return failure on error', () {
      // Arrange
      // Act
      // Assert
    });
  });
}
```

## Development Setup

1. **Fork and clone the repository**
```bash
git clone https://github.com/yourusername/alonu_app.git
cd alonu_app
```

2. **Create a branch for your feature**
```bash
git checkout -b feature/your-feature-name
```

3. **Install dependencies**
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

4. **Make your changes**
- Write clean, well-documented code
- Add tests for new functionality
- Update documentation as needed

5. **Test your changes**
```bash
flutter test
flutter analyze
flutter format lib/
```

6. **Commit and push**
```bash
git add .
git commit -m "✨ Add your feature description"
git push origin feature/your-feature-name
```

7. **Create a Pull Request**
- Provide a clear description of changes
- Link related issues
- Wait for review and address feedback

## PR Review Process

* At least one code review is required
* CI/CD checks must pass
* Code must follow style guidelines
* Tests must be included and passing
* Documentation must be updated

## Documentation

* Keep README up to date
* Add docstrings to public APIs
* Update API documentation when endpoints change
* Add inline comments for complex logic
* Include examples in documentation

## Release Process

When releasing a new version:

1. Update version in `pubspec.yaml`
2. Update `CHANGELOG.md`
3. Create a release branch: `git checkout -b release/v1.0.0`
4. Submit PR for review
5. After merge, create a GitHub release with release notes
6. Build and submit to app stores

## Additional Notes

### Issue and Pull Request Labels

* `bug` - Something isn't working
* `enhancement` - New feature or request
* `documentation` - Improvements or additions to documentation
* `good first issue` - Good for newcomers
* `help wanted` - Extra attention is needed
* `in progress` - Currently being worked on
* `ready for review` - Ready for code review
* `blocked` - Blocked by another issue or PR

### Project Board

We use GitHub Projects to track progress. Issues are organized by:
* **Backlog** - Ideas to be evaluated
* **Ready** - Ready to be worked on
* **In Progress** - Currently being developed
* **Review** - Under code review
* **Done** - Completed

## Questions?

Feel free to open an issue with the label `question` or contact us at support@alonu.com.

---

Thank you for contributing to ALONU! 🎉
