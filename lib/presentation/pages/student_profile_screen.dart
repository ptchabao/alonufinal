import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../bloc/auth_provider.dart';
import '../widgets/widgets.dart';

/// Espace étudiant, branché sur GET /students/me et POST /students.
/// L'API ne porte ni suivi de progression de cours, ni certificats : seuls
/// niveauEtude/apport/metier et l'artisan formateur assigné sont disponibles.
class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myProfileAsync = ref.watch(myStudentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace étudiant'),
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
      body: myProfileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (profile) {
          if (profile == null) {
            return const _CreateStudentProfileForm();
          }
          return _StudentProfileContent(profile: profile);
        },
      ),
    );
  }
}

class _StudentProfileContent extends ConsumerWidget {
  final Map<String, dynamic> profile;
  const _StudentProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final offersAsync = ref.watch(apprenticeshipAdsProvider);
    final artisanId = profile['artisanId']?.toString();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadows,
            ),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                  child: const Icon(Icons.school, color: Colors.white, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? 'Étudiant ALONU',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('Métier visé: ${profile['metier'] ?? 'Non renseigné'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text('Niveau d\'étude: ${profile['niveauEtude'] ?? 'Non renseigné'}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Maître formateur', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          if (artisanId == null || artisanId.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppColors.cardShadows,
              ),
              child: const Text('Aucun artisan formateur ne vous a encore été assigné.'),
            )
          else
            Consumer(builder: (context, ref, child) {
              final artisanAsync = ref.watch(artisanDetailProvider(artisanId));
              return artisanAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Erreur: $e'),
                data: (artisan) {
                  final whatsapp = artisan.whatsapp;
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: AppColors.cardShadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${artisan.user.prenom} ${artisan.user.nom}',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(artisan.telephone, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                label: 'Voir le profil',
                                onPressed: () => context.push('/artisan/$artisanId'),
                              ),
                            ),
                            if (whatsapp != null && whatsapp.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Expanded(
                                child: AppButton(
                                  label: 'WhatsApp',
                                  onPressed: () async {
                                    final normalized = whatsapp.replaceAll(RegExp(r'[^0-9+]'), '');
                                    await launchUrl(Uri.parse('https://wa.me/$normalized'));
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          const SizedBox(height: 24),

          Text('Offres recommandées', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          offersAsync.when(
            data: (offers) {
              if (offers.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.cardShadows,
                  ),
                  child: Text('Aucune offre disponible pour le moment.', style: Theme.of(context).textTheme.bodyMedium),
                );
              }
              return Column(
                children: offers.take(3).map((offer) {
                  final data = offer is Map<String, dynamic> ? offer : Map<String, dynamic>.from(offer as Map);
                  final title = (data['title'] ?? 'Offre d’apprentissage').toString();
                  final subtitle = (data['subtitle'] ?? 'Formation artisanale').toString();
                  final offerId = data['id']?.toString() ?? '';
                  final artisanName = (data['artisanName'] ?? 'ALONU').toString();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      onTap: offerId.isNotEmpty ? () => context.push('/course/$offerId') : null,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppColors.cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text(artisanName, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 10),
                            Text(subtitle, style: Theme.of(context).textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: AppLoadingIndicator()),
            error: (error, stack) => Text('Impossible de charger les offres: $error'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _CreateStudentProfileForm extends ConsumerStatefulWidget {
  const _CreateStudentProfileForm();

  @override
  ConsumerState<_CreateStudentProfileForm> createState() => _CreateStudentProfileFormState();
}

class _CreateStudentProfileFormState extends ConsumerState<_CreateStudentProfileForm> {
  final _niveauController = TextEditingController();
  final _apportController = TextEditingController();
  final _metierController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _niveauController.dispose();
    _apportController.dispose();
    _metierController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.countryId == null) {
      showErrorSnackbar(context, 'Pays introuvable sur votre profil, contactez le support.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref.read(createStudentActionProvider)({
        'userId': user.id,
        'countryId': user.countryId,
        if (_niveauController.text.trim().isNotEmpty) 'niveauEtude': _niveauController.text.trim(),
        if (_apportController.text.trim().isNotEmpty) 'apport': _apportController.text.trim(),
        if (_metierController.text.trim().isNotEmpty) 'metier': _metierController.text.trim(),
      });
      ref.invalidate(myStudentProfileProvider);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Profil étudiant créé');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Complétez votre profil étudiant pour être visible des artisans formateurs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _metierController,
            decoration: InputDecoration(labelText: 'Métier visé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _niveauController,
            decoration: InputDecoration(labelText: 'Niveau d\'étude', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _apportController,
            maxLines: 2,
            decoration: InputDecoration(labelText: 'Apport (financier, matériel...)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
          ),
          const SizedBox(height: 20),
          AppButton(
            label: _submitting ? 'Création…' : 'Créer mon profil',
            isEnabled: !_submitting,
            isLoading: _submitting,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
