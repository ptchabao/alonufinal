# ALONU App - Quick Reference

## Getting Started (2 minutes)

```bash
cd alonu_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Common Commands

### Development
| Command | Purpose |
|---------|---------|
| `flutter run` | Run app in debug mode |
| `flutter run --release` | Run in release mode |
| `flutter pub get` | Install dependencies |
| `flutter format lib/` | Format code |
| `flutter analyze` | Check for issues |
| `flutter test` | Run tests |

### Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Building
| Command | Output |
|---------|--------|
| `flutter build apk --release` | Android APK (testing) |
| `flutter build appbundle --release` | Android AAB (Play Store) |
| `flutter build ios --release` | iOS app (App Store) |

### Using Build Script
```bash
./build.sh setup               # Initial setup
./build.sh build-apk           # Debug APK
./build.sh build-aab           # Release bundle (Play Store)
./build.sh analyze             # Code analysis
./build.sh release-prep        # Pre-release checks
```

## Project Files

### Key Locations
- **App Code**: `lib/`
- **Tests**: `test/`
- **Configuration**: `pubspec.yaml`
- **Android**: `android/`
- **iOS**: `ios/`

### Important Files
| File | Purpose |
|------|---------|
| `lib/main.dart` | App entry point |
| `lib/presentation/routes/app_router.dart` | Navigation setup |
| `lib/core/service_locator.dart` | Dependency injection |
| `pubspec.yaml` | Dependencies & version |
| `.env.example` | Environment template |
| `android/app/build.gradle.kts` | Android build config |

## Configuration

### API Endpoint
Edit `.env.example` or `.env.production`:
```
API_BASE_URL=https://api.alonu.com
```

### Version
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

### App IDs
- **Android**: `com.alonu.alonu_app` (in `android/app/build.gradle.kts`)
- **iOS**: `com.alonu.alonuApp` (in Xcode)

## Architecture

```
lib/
├── core/          # Constants, theme, network, utilities
├── data/          # API, models, repositories
├── domain/        # Business logic, entities, interfaces
└── presentation/  # UI, state management, navigation
```

## State Management (Riverpod)

### Watching State
```dart
final authState = ref.watch(authProvider);
```

### Calling Methods
```dart
await ref.read(authProvider.notifier).login(email, password);
```

### Creating Providers
```dart
final myProvider = StateNotifierProvider((ref) => MyNotifier());
```

## Adding New Features

### 1. Create Entity
`lib/domain/entities/my_entity.dart`

### 2. Create Model
`lib/data/models/my_model.dart` with `@JsonSerializable()`

### 3. Create Repository Interface
`lib/domain/repositories/my_repository.dart`

### 4. Implement Repository
`lib/data/repositories/my_repository_impl.dart`

### 5. Create Use Cases
`lib/domain/usecases/my_usecases.dart`

### 6. Create Provider
`lib/presentation/bloc/my_provider.dart`

### 7. Build UI
`lib/presentation/pages/my_screen.dart`

### 8. Update Router
Edit `lib/presentation/routes/app_router.dart`

### 9. Generate Code
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Troubleshooting

### Build Issues
```bash
flutter clean
rm pubspec.lock
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Device Not Found
```bash
flutter devices
flutter doctor
```

### Port Already in Use
```bash
flutter run -d <device-id>
```

### Version Conflicts
```bash
flutter pub upgrade
flutter pub outdated
```

## Testing

### Unit Tests
```bash
flutter test test/path/to/test.dart
flutter test --coverage
```

### Widget Tests
```bash
flutter test
```

### Specific Test
```bash
flutter test -k "test_name"
```

## Performance Tips

- Use `const` constructors
- Cache network images
- Implement pagination for lists
- Use `shouldRebuild` in providers
- Profile with DevTools

## Security Reminders

- ⚠️ Never commit `.env` files
- ⚠️ Never hardcode API keys
- ⚠️ Use `flutter_secure_storage` for tokens
- ⚠️ Always use HTTPS in production
- ⚠️ Validate all user inputs

## Documentation

- **Full Guide**: See `README.md`
- **Build Guide**: See `BUILD_GUIDE.md`
- **API Docs**: See `docs/API.md`
- **Deployment**: See `DEPLOYMENT.md`
- **Contributing**: See `CONTRIBUTING.md`

## Useful Links

- [Flutter Documentation](https://flutter.dev)
- [Riverpod Documentation](https://riverpod.dev)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
- [Dio Documentation](https://pub.dev/packages/dio)

## Getting Help

1. Check documentation in `docs/` and root `*.md` files
2. Run `flutter doctor -v` for environment info
3. Check error logs in console
4. Search Flutter/Dart issues online
5. Contact support team

## Before Releasing

- [ ] Update version in `pubspec.yaml`
- [ ] Update `CHANGELOG.md`
- [ ] Run `flutter analyze`
- [ ] Run `flutter test`
- [ ] Build and test on real devices
- [ ] Update `.env.production`
- [ ] Run `./build.sh release-prep`

---

**Last Updated**: May 23, 2024
**App Status**: ✅ Ready for Development & Deployment
