import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../bloc/api_providers.dart';
import '../widgets/widgets.dart';

class CourseDetailScreen extends ConsumerWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseAsync = ref.watch(apprenticeshipAdDetailProvider(courseId));

    return courseAsync.when(
      data: (course) {
        final courseData = course is Map<String, dynamic>
            ? course
            : Map<String, dynamic>.from(course as Map);

        final title = (courseData['title'] ?? 'Cours disponible').toString();
        final subtitle = (courseData['subtitle'] ?? 'Formation artisanale')
            .toString();
        final description =
            (courseData['description'] ?? 'Aucune description fournie')
                .toString();
        final imageUrl = (courseData['imageUrl'] ?? '').toString();
        final viewsCount = (courseData['viewsCount'] ?? 0).toString();
        final clicksCount = (courseData['clicksCount'] ?? 0).toString();

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.background,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 220,
                        color: AppColors.surfaceVariant,
                        child: const Center(child: AppLoadingIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 220,
                        color: AppColors.surfaceVariant,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.school,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    AppBadge(
                      label: 'FORMATION',
                      backgroundColor: AppColors.secondary,
                      textColor: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    AppBadge(
                      label: '$viewsCount vues',
                      backgroundColor: AppColors.surfaceVariant,
                      textColor: AppColors.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 12),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.visibility, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Vues: $viewsCount'),
                      const SizedBox(width: 16),
                      const Icon(Icons.touch_app, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('Clics: $clicksCount'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Postuler maintenant',
                        onPressed: () =>
                            _openApplicationSheet(context, courseTitle: title),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Retour',
                        onPressed: () => context.pop(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: AppLoadingIndicator())),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text('Erreur: ${err.toString()}'),
              const SizedBox(height: 12),
              AppButton(
                label: 'Retour',
                onPressed: () => context.pop(),
                isSmall: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openApplicationSheet(
    BuildContext context, {
    required String courseTitle,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final formKey = GlobalKey<FormState>();
        final nameController = TextEditingController();
        final emailController = TextEditingController();
        final motivationController = TextEditingController(
          text: 'Je souhaite postuler à cette formation artisanale.',
        );

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Postuler à ce cours',
                  style: Theme.of(sheetContext).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Veuillez renseigner votre nom'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez renseigner votre email';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+').hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: motivationController,
                  decoration: const InputDecoration(
                    labelText: 'Motivation',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Veuillez renseigner votre motivation'
                      : null,
                ),
                const SizedBox(height: 16),
                AppButton(
                  label: 'Envoyer la candidature',
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) {
                      return;
                    }
                    Navigator.pop(sheetContext);
                    showSuccessSnackbar(
                      context,
                      'Candidature envoyée pour $courseTitle',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
