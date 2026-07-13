import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import 'widgets.dart';

/// Feuille de préférences branchée sur GET/PUT /preferences et
/// POST /preferences/reset (langue, thème, notifications, son).
void showPreferencesSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _PreferencesSheetContent(),
  );
}

ThemeMode _themeModeFromString(String? value) {
  switch (value) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.light:
      return 'light';
    case ThemeMode.system:
      return 'system';
  }
}

class _PreferencesSheetContent extends ConsumerStatefulWidget {
  const _PreferencesSheetContent();

  @override
  ConsumerState<_PreferencesSheetContent> createState() => _PreferencesSheetContentState();
}

class _PreferencesSheetContentState extends ConsumerState<_PreferencesSheetContent> {
  String _language = 'fr';
  ThemeMode _themeMode = ThemeMode.system;
  bool _notifications = true;
  bool _soundEnabled = true;
  bool _initialized = false;
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(updatePreferencesActionProvider)({
        'language': _language,
        'theme': _themeModeToString(_themeMode),
        'notifications': _notifications,
        'soundEnabled': _soundEnabled,
      });
      ref.read(themeModeProvider.notifier).state = _themeMode;
      ref.invalidate(preferencesProvider);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Préférences enregistrées');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferencesAsync = ref.watch(preferencesProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: preferencesAsync.when(
        loading: () => const SizedBox(height: 160, child: Center(child: CircularProgressIndicator())),
        error: (e, st) => SizedBox(height: 120, child: Center(child: Text('Erreur: $e'))),
        data: (prefs) {
          if (!_initialized) {
            _language = prefs['language']?.toString() ?? 'fr';
            _themeMode = _themeModeFromString(prefs['theme']?.toString());
            _notifications = prefs['notifications'] as bool? ?? true;
            _soundEnabled = prefs['soundEnabled'] as bool? ?? true;
            _initialized = true;
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Préférences', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              Text('Langue', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'fr', label: Text('Français')),
                  ButtonSegment(value: 'en', label: Text('English')),
                ],
                selected: {_language},
                onSelectionChanged: (s) => setState(() => _language = s.first),
              ),
              const SizedBox(height: 16),
              Text('Thème', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(value: ThemeMode.light, label: Text('Clair')),
                  ButtonSegment(value: ThemeMode.dark, label: Text('Sombre')),
                  ButtonSegment(value: ThemeMode.system, label: Text('Auto')),
                ],
                selected: {_themeMode},
                onSelectionChanged: (s) => setState(() => _themeMode = s.first),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Notifications'),
                value: _notifications,
                onChanged: (v) => setState(() => _notifications = v),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Son'),
                value: _soundEnabled,
                onChanged: (v) => setState(() => _soundEnabled = v),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: _saving ? 'Enregistrement…' : 'Enregistrer',
                isEnabled: !_saving,
                isLoading: _saving,
                onPressed: _save,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _saving
                    ? null
                    : () async {
                        try {
                          await ref.read(resetPreferencesActionProvider)();
                          ref.invalidate(preferencesProvider);
                          ref.read(themeModeProvider.notifier).state = ThemeMode.system;
                          if (!context.mounted) return;
                          Navigator.of(context).pop();
                        } catch (e) {
                          if (!context.mounted) return;
                          showErrorSnackbar(context, 'Erreur: $e');
                        }
                      },
                child: const Text('Réinitialiser', style: TextStyle(color: AppColors.error)),
              ),
            ],
          );
        },
      ),
    );
  }
}
