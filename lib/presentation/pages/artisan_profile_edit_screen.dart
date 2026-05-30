import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../providers/artisan_provider.dart';
// removed unused import

class ArtisanProfileEditScreen extends ConsumerStatefulWidget {
  final String artisanId;
  final int initialTabIndex;
  const ArtisanProfileEditScreen({Key? key, this.artisanId = 'artisan1', this.initialTabIndex = 0}) : super(key: key);

  @override
  ConsumerState<ArtisanProfileEditScreen> createState() => _ArtisanProfileEditScreenState();
}

class _ArtisanProfileEditScreenState extends ConsumerState<ArtisanProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    _facebookController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildUpdatePayload(String artisanId) {
    return {
      'user': {
        'nom': _nameController.text.trim(),
        'prenom': _prenomController.text.trim(),
      },
      'telephone': _telephoneController.text.trim(),
      'adresse': _adresseController.text.trim(),
      'facebook': _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
      'whatsapp': _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
      'instagram': _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
    };
  }

  Future<void> _saveProfile() async {
    final artisanId = widget.artisanId;
    final updater = ref.read(updateArtisanActionProvider);
    final payload = _buildUpdatePayload(artisanId);
    try {
      await updater(artisanId, payload);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Profil mis à jour');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    }
  }

  Future<void> _showPublishProductDialog() async {
    final titleController = TextEditingController();
    final priceController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Publier un produit'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Prix')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Publier')),
        ],
      ),
    );

    if (result == true) {
      final publisher = ref.read(publishProductActionProvider);
      final productData = {
        'title': titleController.text.trim(),
        'price': double.tryParse(priceController.text.trim()) ?? 0,
        'description': descriptionController.text.trim(),
      };
      try {
        await publisher(widget.artisanId, productData);
        if (!mounted) return;
        showSuccessSnackbar(context, 'Produit publié');
      } catch (e) {
        if (!mounted) return;
        showErrorSnackbar(context, 'Erreur: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final artisanId = widget.artisanId;
    final artisanAsync = ref.watch(artisanDetailProvider(artisanId));

    return DefaultTabController(
      length: 4,
      initialIndex: widget.initialTabIndex,
      child: Scaffold(
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
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Détails'),
              Tab(text: 'Apprentis'),
              Tab(text: 'Produits'),
              Tab(text: 'Commandes'),
            ],
          ),
        ),
        body: artisanAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('Erreur: $e')),
          data: (artisan) {
            if (!_initialized) {
              _nameController.text = artisan.user.nom;
              _prenomController.text = artisan.user.prenom;
              _telephoneController.text = artisan.telephone;
              _adresseController.text = artisan.adresse ?? '';
              _facebookController.text = artisan.facebook ?? '';
              _whatsappController.text = artisan.whatsapp ?? '';
              _instagramController.text = artisan.instagram ?? '';
              _initialized = true;
            }

            return TabBarView(
              children: [
                // Details tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                              child: artisan.user.avatar != null
                                  ? ClipOval(
                                      child: Image.network(artisan.user.avatar!, fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.person, size: 60, color: AppColors.primary),
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
                                  onTap: () => showSuccessSnackbar(context, 'Avatar mis à jour!'),
                                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('Informations personnelles', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _prenomController, decoration: InputDecoration(labelText: 'Prénom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _telephoneController, decoration: InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _adresseController, decoration: InputDecoration(labelText: 'Adresse', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _facebookController, decoration: InputDecoration(labelText: 'Facebook', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _whatsappController, decoration: InputDecoration(labelText: 'WhatsApp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: _instagramController, decoration: InputDecoration(labelText: 'Instagram', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 24),
                      AppButton(label: 'Enregistrer', onPressed: _saveProfile),
                      const SizedBox(height: 12),
                      SecondaryButton(label: 'Annuler', onPressed: () => context.pop()),
                    ],
                  ),
                ),

                // Apprentices tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(builder: (context, ref, child) {
                    final studentsAsync = ref.watch(studentsByArtisanProvider(artisanId));
                    return studentsAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Erreur: $e')),
                      data: (list) {
                        if (list.isEmpty) return const Center(child: Text('Aucun apprenti'));
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, i) {
                            final item = list[i] as Map<String, dynamic>?;
                            final name = item != null ? (item['nom'] ?? item['name'] ?? item['fullName'] ?? 'Apprenti') : 'Apprenti';
                            return ListTile(
                              title: Text(name.toString()),
                              subtitle: Text(item?['telephone']?.toString() ?? ''),
                              onTap: () {
                                // open detail - use provided provider
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentDetailPage(studentId: item?['id']?.toString() ?? '')));
                              },
                            );
                          },
                        );
                      },
                    );
                  }),
                ),

                // Products tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(builder: (context, ref, child) {
                    final productsAsync = ref.watch(artisanProductsProvider(artisanId));
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppTextButton(label: 'Publier un produit', onPressed: _showPublishProductDialog),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: productsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => Center(child: Text('Erreur: $e')),
                            data: (list) {
                              if (list.isEmpty) return const Center(child: Text('Aucun produit'));
                              return ListView.separated(
                                itemCount: list.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, i) {
                                  final item = list[i] as Map<String, dynamic>?;
                                  final title = item?['title'] ?? item?['name'] ?? 'Produit';
                                  final price = item?['price']?.toString() ?? '';
                                  return ListTile(
                                    title: Text(title.toString()),
                                    subtitle: Text(price.toString()),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),

                // Orders tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(builder: (context, ref, child) {
                    final ordersAsync = ref.watch(artisanOrdersProvider(artisanId));
                    return ordersAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Center(child: Text('Erreur: $e')),
                      data: (list) {
                        if (list.isEmpty) return const Center(child: Text('Aucune commande'));
                        return ListView.separated(
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, i) {
                            final item = list[i] as Map<String, dynamic>?;
                            final id = item?['id'] ?? item?['orderId'] ?? '—';
                            final status = item?['status'] ?? '';
                            return ListTile(
                              title: Text(id.toString()),
                              subtitle: Text(status.toString()),
                            );
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
}

}
// Minimal student detail page fallback (used when detailed page not yet present)
class StudentDetailPage extends ConsumerWidget {
  final String studentId;
  const StudentDetailPage({Key? key, required this.studentId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studentAsync = ref.watch(studentDetailProvider(studentId));
    return Scaffold(
      appBar: AppBar(title: const Text('Détails apprenti')),
      body: studentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
        data: (data) {
          final map = data as Map<String, dynamic>?;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nom: ${map?['nom'] ?? map?['name'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Téléphone: ${map?['telephone'] ?? ''}'),
                const SizedBox(height: 8),
                Text('Email: ${map?['email'] ?? ''}'),
              ],
            ),
          );
        },
      ),
    );
  }
}
