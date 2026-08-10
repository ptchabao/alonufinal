import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/service_locator.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/artisan_model.dart';
import '../bloc/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RegisterScreenState();
}

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;

  const _RoleOption(this.value, this.label, this.icon);
}

const List<_RoleOption> _roleOptions = [
  _RoleOption('CLIENT', 'Client', Icons.shopping_bag_outlined),
  _RoleOption('ARTISAN', 'Artisan', Icons.handyman_outlined),
  _RoleOption('STUDENT', 'Étudiant', Icons.school_outlined),
];

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  late TextEditingController _workshopLocationController;
  String _selectedRole = 'CLIENT';
  bool _obscurePassword = true;
  List<CountryModel> _countries = [];
  String? _selectedCountryId;
  bool _isLoadingCountries = true;
  String? _countriesError;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _nomController = TextEditingController();
    _prenomController = TextEditingController();
    _telephoneController = TextEditingController();
    _workshopLocationController = TextEditingController();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _isLoadingCountries = true;
      _countriesError = null;
    });

    try {
      final countries = await getIt<AuthRemoteDataSource>().getCountries();
      if (!mounted) return;

      setState(() {
        _countries = countries;
        _selectedCountryId = countries.isNotEmpty ? countries.first.id : null;
        _isLoadingCountries = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _countriesError = 'Impossible de charger la liste des pays';
        _isLoadingCountries = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _workshopLocationController.dispose();
    super.dispose();
  }

  Future<void> _captureWorkshopGps() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission de localisation refusée')),
        );
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      _workshopLocationController.text = '${pos.latitude},${pos.longitude}';
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible de récupérer la position: $e')),
      );
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColors.surfaceVariant,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== EN-TÊTE =====
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material(
                          shape: const CircleBorder(),
                          color: Colors.white24,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => context.go('/home'),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Créer un compte',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Rejoignez la communauté ALONU',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== FORMULAIRE =====
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppColors.cardShadowsElevated,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('INFORMATIONS PERSONNELLES'),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _prenomController,
                            decoration: _fieldDecoration(
                              hint: 'Prénom',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _nomController,
                            decoration: _fieldDecoration(
                              hint: 'Nom',
                              icon: Icons.badge_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _telephoneController,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration(
                        hint: 'Téléphone',
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionTitle('COMPTE'),
                    TextField(
                      controller: _usernameController,
                      decoration: _fieldDecoration(
                        hint: 'Nom d\'utilisateur',
                        icon: Icons.alternate_email,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDecoration(
                        hint: 'Email',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: _fieldDecoration(
                        hint: 'Mot de passe',
                        icon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    _sectionTitle('JE SUIS...'),
                    Row(
                      children: _roleOptions.map((role) {
                        final isSelected = _selectedRole == role.value;
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: role.value == _roleOptions.last.value ? 0 : 8,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = role.value;
                                  if (_selectedRole != 'ARTISAN') {
                                    _workshopLocationController.clear();
                                  }
                                  if (_selectedRole == 'ARTISAN') {
                                    _captureWorkshopGps();
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      role.icon,
                                      color: isSelected
                                          ? AppColors.onPrimary
                                          : AppColors.onSurfaceVariant,
                                      size: 22,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      role.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.onPrimary
                                            : AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedRole == 'ARTISAN') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _workshopLocationController,
                              readOnly: true,
                              decoration: _fieldDecoration(
                                hint: 'Localisation de l\'atelier',
                                icon: Icons.location_on_outlined,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Material(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: _captureWorkshopGps,
                              child: const Padding(
                                padding: EdgeInsets.all(14),
                                child: Icon(Icons.my_location, color: AppColors.primary),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),

                    _sectionTitle('PAYS'),
                    if (_isLoadingCountries)
                      const Center(child: CircularProgressIndicator())
                    else if (_countriesError != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _countriesError!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      )
                    else
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedCountryId,
                        items: _countries.map((country) {
                          final label = country.nameFr.isNotEmpty
                              ? country.nameFr
                              : country.name;
                          return DropdownMenuItem(
                            value: country.id,
                            child: Text('${country.flagEmoji} $label'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCountryId = value;
                          });
                        },
                        decoration: _fieldDecoration(
                          hint: 'Sélectionner un pays',
                          icon: Icons.public,
                        ),
                      ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: authState.isLoading || _isLoadingCountries
                            ? null
                            : () async {
                                final countryId = _selectedCountryId;
                                if (countryId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Veuillez sélectionner un pays'),
                                    ),
                                  );
                                  return;
                                }

                                if (_passwordController.text.trim().length < 6) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Le mot de passe doit contenir au moins 6 caractères',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final workshopLocation =
                                    _selectedRole == 'ARTISAN' &&
                                            _workshopLocationController.text.trim().isNotEmpty
                                        ? _workshopLocationController.text.trim()
                                        : null;

                                final success = await ref
                                    .read(authProvider.notifier)
                                    .register(
                                      username: _usernameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      nom: _nomController.text,
                                      prenom: _prenomController.text,
                                      telephone: _telephoneController.text,
                                      role: _selectedRole,
                                      countryId: countryId,
                                      workshopLocation: workshopLocation,
                                    );

                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Inscription réussie. Veuillez vous connecter.',
                                      ),
                                    ),
                                  );
                                  context.go('/login');
                                }
                              },
                        child: authState.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'S\'inscrire',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    if (authState.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          authState.error!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: RichText(
                  text: TextSpan(
                    text: 'Vous avez déjà un compte? ',
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(
                        text: 'Se connecter',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
