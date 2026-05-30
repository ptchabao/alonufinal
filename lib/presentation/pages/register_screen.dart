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

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _telephoneController;
  late TextEditingController _workshopLocationController;
  String _selectedRole = 'CLIENT';
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inscription'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Créer un compte',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Rejoignez la communauté ALONU',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _prenomController,
              decoration: InputDecoration(hintText: 'Prénom'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomController,
              decoration: InputDecoration(hintText: 'Nom'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(hintText: 'Username'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(hintText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _telephoneController,
              decoration: InputDecoration(hintText: 'Téléphone'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(hintText: 'Mot de passe'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              isExpanded: true,
              items: ['CLIENT', 'ARTISAN', 'STUDENT']
                  .map(
                    (role) => DropdownMenuItem(value: role, child: Text(role)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value ?? 'CLIENT';
                  if (_selectedRole != 'ARTISAN') {
                    _workshopLocationController.clear();
                  }
                  if (_selectedRole == 'ARTISAN') {
                    _captureWorkshopGps();
                  }
                });
              },
              decoration: InputDecoration(
                hintText: 'Rôle',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            if (_selectedRole == 'ARTISAN') ...[
              const SizedBox(height: 16),
              // show captured GPS coordinates and allow refresh
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _workshopLocationController,
                      decoration: const InputDecoration(
                        hintText: 'Localisation de l\'atelier (lat,lng)',
                      ),
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _captureWorkshopGps,
                    child: const Text('Utiliser ma position'),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            if (_isLoadingCountries)
              const Center(child: CircularProgressIndicator())
            else if (_countriesError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _countriesError!,
                  style: TextStyle(color: AppColors.error),
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
                decoration: InputDecoration(
                  labelText: 'Pays',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
                              workshopLocation: _selectedRole == 'ARTISAN'
                                  ? _workshopLocationController.text.trim()
                                  : null,
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('S\'inscrire'),
              ),
            ),
            const SizedBox(height: 20),
            if (authState.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  authState.error!,
                  style: TextStyle(color: AppColors.error),
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
          ],
        ),
      ),
    );
  }
}
