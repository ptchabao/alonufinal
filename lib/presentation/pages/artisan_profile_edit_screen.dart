import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';

class ArtisanProfileEditScreen extends StatefulWidget {
  const ArtisanProfileEditScreen({Key? key}) : super(key: key);

  @override
  State<ArtisanProfileEditScreen> createState() => _ArtisanProfileEditScreenState();
}

class _ArtisanProfileEditScreenState extends State<ArtisanProfileEditScreen> {
  late TextEditingController _nameController;
  late TextEditingController _specialtyController;
  late TextEditingController _bioController;
  final List<Map<String, String>> _services = [
    {'name': 'Service 1', 'price': '50000'},
    {'name': 'Service 2', 'price': '75000'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: 'Jean Dupont');
    _specialtyController = TextEditingController(text: 'Menuisier Expert');
    _bioController = TextEditingController(
      text: 'Artisan passionné avec 15 ans d\'expérience en menuiserie',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier mon profil'),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            shape: const CircleBorder(),
            color: AppColors.surface,
            child: InkWell(
              onTap: () => context.pop(),
              child: const Icon(Icons.arrow_back, color: AppColors.primary),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight,
                    ),
                    child: const Icon(Icons.person, size: 60, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: GestureDetector(
                        onTap: () {
                          showSuccessSnackbar(context, 'Avatar mis à jour!');
                        },
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Infos
            Text('Informations personnelles', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _specialtyController,
              decoration: InputDecoration(
                labelText: 'Spécialité',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bioController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: AppColors.surfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Services
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mes services', style: Theme.of(context).textTheme.titleMedium),
                AppTextButton(
                  label: 'Ajouter',
                  onPressed: () {
                    setState(() {
                      _services.add({'name': 'Nouveau service', 'price': '0'});
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: _services.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Nom du service',
                            hintText: _services[index]['name'],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Prix XOF',
                            hintText: _services[index]['price'],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            filled: true,
                            fillColor: AppColors.surfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, color: AppColors.error),
                        onPressed: () {
                          setState(() => _services.removeAt(index));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Badges
            Text('Accréditations', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                AppBadge(
                  label: 'Master Artisan',
                  backgroundColor: AppColors.primaryLight,
                  textColor: AppColors.primary,
                ),
                const SizedBox(width: 8),
                AppBadge(
                  label: 'Vérifié',
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.2),
                  textColor: AppColors.secondary,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Buttons
            AppButton(
              label: 'Enregistrer',
              onPressed: () {
                showSuccessSnackbar(context, 'Profil mis à jour!');
                context.pop();
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Annuler',
              onPressed: () => context.pop(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
