import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({Key? key}) : super(key: key);

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  // Mock data
  final Map<String, String> studentInfo = {
    'name': 'Marie Sow',
    'email': 'marie.sow@example.com',
    'phone': '+229 95 12 34 56',
    'joinDate': '15 Janvier 2025',
  };

  final List<Map<String, dynamic>> apprenticeships = [
    {
      'title': 'Menuiserie',
      'artisan': 'Jean Dupont',
      'startDate': '01 Février 2025',
      'endDate': '01 Août 2025',
      'progress': 0.65,
      'status': 'En cours',
    },
    {
      'title': 'Électricité',
      'artisan': 'Ahmed Ibrahim',
      'startDate': '15 Juillet 2024',
      'endDate': '15 Novembre 2024',
      'progress': 1.0,
      'status': 'Complété',
    },
  ];

  final List<Map<String, String>> certificates = [
    {
      'title': 'Certificat Menuiserie',
      'issuer': 'Jean Dupont',
      'date': '15 Nov 2024',
      'icon': '🎓',
    },
    {
      'title': 'Certificat Participation',
      'issuer': 'ALONU Platform',
      'date': '20 Jan 2025',
      'icon': '📜',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon apprentissage'),
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
            // Student Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppColors.cardShadows,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.primaryLight,
                        child: const Icon(Icons.person, size: 40, color: AppColors.primary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              studentInfo['name']!,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentInfo['email']!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Membre depuis ${studentInfo['joinDate']}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Apprenticeships en cours
            Text('Mes apprentissages', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: apprenticeships.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final app = apprenticeships[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FadeInWidget(
                    delay: Duration(milliseconds: index * 100),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primaryLight),
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.surface,
                        boxShadow: AppColors.cardShadows,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                app['title'],
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppBadge(
                                label: app['status'],
                                backgroundColor: app['status'] == 'Complété'
                                    ? AppColors.secondary.withValues(alpha: 0.2)
                                    : AppColors.primaryLight,
                                textColor: app['status'] == 'Complété'
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Maître: ${app['artisan']}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${app['startDate']} → ${app['endDate']}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Progress Bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: app['progress'] as double,
                              minHeight: 8,
                              backgroundColor: AppColors.surfaceVariant,
                              valueColor: AlwaysStoppedAnimation(
                                app['progress'] == 1.0
                                    ? AppColors.secondary
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((app['progress'] as double) * 100).toInt()}% complété',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Certificates
            Text('Mes certificats', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: certificates.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return FadeInWidget(
                  delay: Duration(milliseconds: index * 100),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.primaryLight,
                      boxShadow: AppColors.cardShadows,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cert['icon']!,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cert['title']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cert['date']!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Download Certificate Button
            AppButton(
              label: 'Télécharger mes certificats',
              onPressed: () {
                showSuccessSnackbar(context, 'Téléchargement en cours...');
              },
            ),
            const SizedBox(height: 12),
            SecondaryButton(
              label: 'Contacter mon maître',
              onPressed: () {
                showSuccessSnackbar(context, 'Message envoyé!');
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
