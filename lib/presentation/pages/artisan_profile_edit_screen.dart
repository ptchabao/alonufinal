import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';
import '../providers/artisan_provider.dart';
import '../bloc/auth_provider.dart';

class ArtisanProfileEditScreen extends ConsumerStatefulWidget {
  final String? artisanId;
  final int initialTabIndex;
  const ArtisanProfileEditScreen({Key? key, this.artisanId, this.initialTabIndex = 0}) : super(key: key);

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

  Future<void> _saveProfile(String artisanId) async {
    final userId = ref.read(authProvider).user?.id;
    try {
      // Téléphone/adresse/réseaux vivent sur l'artisan (PUT /artisans/{id})
      final updateArtisan = ref.read(updateArtisanActionProvider);
      await updateArtisan(artisanId, {
        'telephone': _telephoneController.text.trim(),
        'adresse': _adresseController.text.trim(),
        'facebook': _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
        'whatsapp': _whatsappController.text.trim().isEmpty ? null : _whatsappController.text.trim(),
        'instagram': _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
      });

      // Nom/prénom vivent sur l'utilisateur (PUT /users/{id})
      if (userId != null) {
        final updateUser = ref.read(updateUserActionProvider);
        await updateUser(userId, {
          'nom': _nameController.text.trim(),
          'prenom': _prenomController.text.trim(),
        });
      }

      ref.invalidate(artisanDetailProvider(artisanId));
      ref.invalidate(myArtisanProvider);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Profil mis à jour');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    }
  }

  Future<void> _showPublishProductDialog(String artisanId) async {
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
        await publisher(artisanId, productData);
        ref.invalidate(artisanProductsProvider(artisanId));
        if (!mounted) return;
        showSuccessSnackbar(context, 'Produit publié');
      } catch (e) {
        if (!mounted) return;
        showErrorSnackbar(context, 'Erreur: $e');
      }
    }
  }

  Future<void> _showEditProductDialog(String artisanId, Map<String, dynamic> product) async {
    final titleController = TextEditingController(text: product['title']?.toString() ?? '');
    final priceController = TextEditingController(text: product['price']?.toString() ?? '');
    final descriptionController = TextEditingController(text: product['description']?.toString() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Modifier le produit'),
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
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Enregistrer')),
        ],
      ),
    );

    if (result == true) {
      final productId = product['id']?.toString() ?? '';
      final updater = ref.read(updateProductActionProvider);
      try {
        await updater(productId, {
          'title': titleController.text.trim(),
          'price': double.tryParse(priceController.text.trim()) ?? 0,
          'description': descriptionController.text.trim(),
        });
        ref.invalidate(artisanProductsProvider(artisanId));
        if (!mounted) return;
        showSuccessSnackbar(context, 'Produit mis à jour');
      } catch (e) {
        if (!mounted) return;
        showErrorSnackbar(context, 'Erreur: $e');
      }
    }
  }

  Future<void> _deleteProduct(String artisanId, String productId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer le produit',
      message: 'Cette action est irréversible. Confirmer la suppression ?',
      confirmText: 'Supprimer',
    );
    if (confirmed != true) return;
    try {
      await ref.read(deleteProductActionProvider)(productId);
      ref.invalidate(artisanProductsProvider(artisanId));
      if (!mounted) return;
      showSuccessSnackbar(context, 'Produit supprimé');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    }
  }

  Future<void> _toggleProductActive(String artisanId, String productId) async {
    try {
      await ref.read(toggleProductActiveActionProvider)(productId);
      ref.invalidate(artisanProductsProvider(artisanId));
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    }
  }

  Future<void> _showAddRealisationDialog(String artisanId) async {
    final libelleController = TextEditingController();
    final descriptionController = TextEditingController();
    final imagesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ajouter une réalisation'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: libelleController, decoration: const InputDecoration(labelText: 'Titre')),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              TextField(
                controller: imagesController,
                decoration: const InputDecoration(labelText: 'URLs des images (séparées par une virgule)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Annuler')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Ajouter')),
        ],
      ),
    );

    if (result == true) {
      final images = imagesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      try {
        await ref.read(addRealisationActionProvider)(artisanId, {
          'libelle': libelleController.text.trim(),
          'description': descriptionController.text.trim(),
          'images': images,
        });
        ref.invalidate(realisationsProvider(artisanId));
        if (!mounted) return;
        showSuccessSnackbar(context, 'Réalisation ajoutée');
      } catch (e) {
        if (!mounted) return;
        showErrorSnackbar(context, 'Erreur: $e');
      }
    }
  }

  Future<void> _deleteRealisation(String artisanId, String realisationId) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Supprimer la réalisation',
      message: 'Cette action est irréversible. Confirmer la suppression ?',
      confirmText: 'Supprimer',
    );
    if (confirmed != true) return;
    try {
      await ref.read(deleteRealisationActionProvider)(artisanId, realisationId);
      ref.invalidate(realisationsProvider(artisanId));
      if (!mounted) return;
      showSuccessSnackbar(context, 'Réalisation supprimée');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.artisanId != null && widget.artisanId!.isNotEmpty) {
      return _EditArtisanScaffold(
        artisanId: widget.artisanId!,
        initialTabIndex: widget.initialTabIndex,
        controllers: _Controllers(
          nom: _nameController,
          prenom: _prenomController,
          telephone: _telephoneController,
          adresse: _adresseController,
          facebook: _facebookController,
          whatsapp: _whatsappController,
          instagram: _instagramController,
        ),
        initialized: _initialized,
        onInitialized: () => setState(() => _initialized = true),
        onSave: _saveProfile,
        onShowPublishProductDialog: _showPublishProductDialog,
        onShowEditProductDialog: _showEditProductDialog,
        onDeleteProduct: _deleteProduct,
        onToggleProductActive: _toggleProductActive,
        onShowAddRealisationDialog: _showAddRealisationDialog,
        onDeleteRealisation: _deleteRealisation,
      );
    }

    final myArtisanAsync = ref.watch(myArtisanProvider);
    return myArtisanAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(
        appBar: AppBar(title: const Text('Mon profil artisan')),
        body: Center(child: Text('Erreur: $e')),
      ),
      data: (artisan) {
        if (artisan == null) {
          return const _CreateArtisanProfileScreen();
        }
        return _EditArtisanScaffold(
          artisanId: artisan.id,
          initialTabIndex: widget.initialTabIndex,
          controllers: _Controllers(
            nom: _nameController,
            prenom: _prenomController,
            telephone: _telephoneController,
            adresse: _adresseController,
            facebook: _facebookController,
            whatsapp: _whatsappController,
            instagram: _instagramController,
          ),
          initialized: _initialized,
          onInitialized: () => setState(() => _initialized = true),
          onSave: _saveProfile,
          onShowPublishProductDialog: _showPublishProductDialog,
          onShowEditProductDialog: _showEditProductDialog,
          onDeleteProduct: _deleteProduct,
          onToggleProductActive: _toggleProductActive,
          onShowAddRealisationDialog: _showAddRealisationDialog,
          onDeleteRealisation: _deleteRealisation,
        );
      },
    );
  }
}

class _Controllers {
  final TextEditingController nom;
  final TextEditingController prenom;
  final TextEditingController telephone;
  final TextEditingController adresse;
  final TextEditingController facebook;
  final TextEditingController whatsapp;
  final TextEditingController instagram;

  _Controllers({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.adresse,
    required this.facebook,
    required this.whatsapp,
    required this.instagram,
  });
}

class _EditArtisanScaffold extends ConsumerWidget {
  final String artisanId;
  final int initialTabIndex;
  final _Controllers controllers;
  final bool initialized;
  final VoidCallback onInitialized;
  final Future<void> Function(String artisanId) onSave;
  final Future<void> Function(String artisanId) onShowPublishProductDialog;
  final Future<void> Function(String artisanId, Map<String, dynamic> product) onShowEditProductDialog;
  final Future<void> Function(String artisanId, String productId) onDeleteProduct;
  final Future<void> Function(String artisanId, String productId) onToggleProductActive;
  final Future<void> Function(String artisanId) onShowAddRealisationDialog;
  final Future<void> Function(String artisanId, String realisationId) onDeleteRealisation;

  const _EditArtisanScaffold({
    required this.artisanId,
    required this.initialTabIndex,
    required this.controllers,
    required this.initialized,
    required this.onInitialized,
    required this.onSave,
    required this.onShowPublishProductDialog,
    required this.onShowEditProductDialog,
    required this.onDeleteProduct,
    required this.onToggleProductActive,
    required this.onShowAddRealisationDialog,
    required this.onDeleteRealisation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artisanAsync = ref.watch(artisanDetailProvider(artisanId));

    return DefaultTabController(
      length: 5,
      initialIndex: initialTabIndex,
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
            isScrollable: true,
            tabs: [
              Tab(text: 'Détails'),
              Tab(text: 'Réalisations'),
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
            if (!initialized) {
              controllers.nom.text = artisan.user.nom;
              controllers.prenom.text = artisan.user.prenom;
              controllers.telephone.text = artisan.telephone;
              controllers.adresse.text = artisan.adresse ?? '';
              controllers.facebook.text = artisan.facebook ?? '';
              controllers.whatsapp.text = artisan.whatsapp ?? '';
              controllers.instagram.text = artisan.instagram ?? '';
              onInitialized();
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
                        child: Container(
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
                      ),
                      const SizedBox(height: 24),
                      Text('Informations personnelles', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.nom, decoration: InputDecoration(labelText: 'Nom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.prenom, decoration: InputDecoration(labelText: 'Prénom', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.telephone, decoration: InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.adresse, decoration: InputDecoration(labelText: 'Adresse', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.facebook, decoration: InputDecoration(labelText: 'Facebook', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.whatsapp, decoration: InputDecoration(labelText: 'WhatsApp', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 12),
                      TextField(controller: controllers.instagram, decoration: InputDecoration(labelText: 'Instagram', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant)),
                      const SizedBox(height: 24),
                      AppButton(label: 'Enregistrer', onPressed: () => onSave(artisanId)),
                      const SizedBox(height: 12),
                      SecondaryButton(label: 'Annuler', onPressed: () => context.pop()),
                    ],
                  ),
                ),

                // Réalisations tab
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Consumer(builder: (context, ref, child) {
                    final realisationsAsync = ref.watch(realisationsProvider(artisanId));
                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: AppTextButton(
                            label: 'Ajouter une réalisation',
                            onPressed: () => onShowAddRealisationDialog(artisanId),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: realisationsAsync.when(
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (e, st) => Center(child: Text('Erreur: $e')),
                            data: (list) {
                              if (list.isEmpty) return const Center(child: Text('Aucune réalisation'));
                              return ListView.separated(
                                itemCount: list.length,
                                separatorBuilder: (context, index) => const Divider(),
                                itemBuilder: (context, i) {
                                  final r = list[i];
                                  return ListTile(
                                    leading: r.images.isNotEmpty
                                        ? CircleAvatar(backgroundImage: NetworkImage(r.images.first))
                                        : const CircleAvatar(child: Icon(Icons.photo)),
                                    title: Text(r.libelle),
                                    subtitle: r.description != null ? Text(r.description!) : null,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () => onDeleteRealisation(artisanId, r.id),
                                    ),
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
                          child: AppTextButton(label: 'Publier un produit', onPressed: () => onShowPublishProductDialog(artisanId)),
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
                                  final active = item?['active'] as bool? ?? true;
                                  final productId = item?['id']?.toString() ?? '';
                                  return ListTile(
                                    title: Text(title.toString()),
                                    subtitle: Text(price.toString()),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Switch(
                                          value: active,
                                          onChanged: (_) => onToggleProductActive(artisanId, productId),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
                                          onPressed: () => onShowEditProductDialog(artisanId, item ?? {}),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                          onPressed: () => onDeleteProduct(artisanId, productId),
                                        ),
                                      ],
                                    ),
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

/// Formulaire de création de profil artisan (POST /artisans), affiché quand
/// l'utilisateur connecté n'a pas encore de profil artisan (aucune correspondance
/// trouvée dans GET /artisans — voir myArtisanProvider pour la limite connue
/// concernant les profils en attente de validation).
class _CreateArtisanProfileScreen extends ConsumerStatefulWidget {
  const _CreateArtisanProfileScreen();

  @override
  ConsumerState<_CreateArtisanProfileScreen> createState() => _CreateArtisanProfileScreenState();
}

class _CreateArtisanProfileScreenState extends ConsumerState<_CreateArtisanProfileScreen> {
  final _numeroEnrController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _adresseController = TextEditingController();
  final Set<String> _selectedSubCategoryIds = {};
  bool _submitting = false;

  @override
  void dispose() {
    _numeroEnrController.dispose();
    _telephoneController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider).user;
    if (user == null || user.countryId == null) {
      showErrorSnackbar(context, 'Pays introuvable sur votre profil, contactez le support.');
      return;
    }
    if (_selectedSubCategoryIds.isEmpty) {
      showErrorSnackbar(context, 'Choisissez au moins une spécialité.');
      return;
    }
    if (_numeroEnrController.text.trim().isEmpty || _telephoneController.text.trim().isEmpty) {
      showErrorSnackbar(context, 'Numéro d\'enregistrement et téléphone sont requis.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final create = ref.read(createArtisanActionProvider);
      final artisan = await create({
        'userId': user.id,
        'numeroEnr': _numeroEnrController.text.trim(),
        'telephone': _telephoneController.text.trim(),
        if (_adresseController.text.trim().isNotEmpty) 'adresse': _adresseController.text.trim(),
        'countryId': user.countryId,
        'subCategoryIds': _selectedSubCategoryIds.toList(),
      });
      ref.invalidate(myArtisanProvider);
      if (!mounted) return;
      showSuccessSnackbar(context, 'Profil artisan créé');
      context.pushReplacement('/artisan-profile?artisanId=${artisan.id}');
    } catch (e) {
      if (!mounted) return;
      showErrorSnackbar(context, 'Erreur: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer mon profil artisan'),
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
            Text(
              'Complétez ces informations pour activer votre profil artisan sur ALONU.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numeroEnrController,
              decoration: InputDecoration(labelText: 'Numéro d\'enregistrement', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _telephoneController,
              decoration: InputDecoration(labelText: 'Téléphone', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _adresseController,
              decoration: InputDecoration(labelText: 'Adresse', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppColors.surfaceVariant),
            ),
            const SizedBox(height: 20),
            Text('Spécialités', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            categoriesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Erreur: $e'),
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.expand((c) => c.subCategories).map((sc) {
                  final selected = _selectedSubCategoryIds.contains(sc.id);
                  return FilterChip(
                    label: Text(sc.libelleFr),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        _selectedSubCategoryIds.add(sc.id);
                      } else {
                        _selectedSubCategoryIds.remove(sc.id);
                      }
                    }),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: _submitting ? 'Création…' : 'Créer mon profil',
              isEnabled: !_submitting,
              isLoading: _submitting,
              onPressed: _submit,
            ),
          ],
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
