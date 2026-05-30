import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../widgets/widgets.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({Key? key}) : super(key: key);

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  String _selectedCause = '';
  String _selectedAmount = '';
  late TextEditingController _customAmountController;

  final List<Map<String, dynamic>> causes = [
    {
      'title': 'Bourses pour apprentis',
      'description': 'Aider les jeunes à accéder à la formation',
      'icon': '🎓',
      'progress': 0.625,
    },
    {
      'title': 'Équipement artisanal',
      'description': 'Fournir des outils modernes aux artisans',
      'icon': '🔧',
      'progress': 0.30,
    },
    {
      'title': 'Centre de formation',
      'description': 'Construire un centre de formation régional',
      'icon': '🏫',
      'progress': 0.42,
    },
    {
      'title': 'Plateforme numérique',
      'description': 'Développer la technologie ALONU',
      'icon': '💻',
      'progress': 0.63,
    },
  ];

  final List<String> predefinedAmounts = ['5000', '10000', '25000', '50000', '100000'];

  @override
  void initState() {
    super.initState();
    _customAmountController = TextEditingController();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soutenir ALONU'),
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
            // Impact Stats
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
                  Text('Impact collectif', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text('12M+',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('XOF levés', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text('624',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Donateurs', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                      Column(
                        children: [
                          Text('2300+',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Bénéficiaires', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Causes
            Text('Causes à soutenir', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ListView.builder(
              itemCount: causes.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final cause = causes[index];
                final isSelected = _selectedCause == cause['title'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FadeInWidget(
                    delay: Duration(milliseconds: index * 100),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCause = isSelected ? '' : cause['title'];
                          _selectedAmount = '';
                          _customAmountController.clear();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.primaryLight,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected ? AppColors.primaryLight : AppColors.surface,
                          boxShadow: AppColors.cardShadows,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(cause['icon'], style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cause['title'],
                                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(cause['description'],
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: cause['progress'] as double,
                                minHeight: 6,
                                backgroundColor: AppColors.surfaceVariant,
                                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${((cause['progress'] as double) * 100).toInt()}% atteint',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Donation Amount
            if (_selectedCause.isNotEmpty) ...[
              Text('Montant du don', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: predefinedAmounts.map((amount) {
                  final isSelected = _selectedAmount == amount;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAmount = isSelected ? '' : amount;
                        _customAmountController.clear();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? AppColors.primaryLight : AppColors.surface,
                      ),
                      child: Text(
                        '$amount XOF',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.primary : AppColors.onSurface,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _customAmountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Montant personnalisé (XOF)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Faire un don',
                onPressed: () {
                  final amount = _selectedAmount.isNotEmpty
                      ? _selectedAmount
                      : _customAmountController.text;
                  if (amount.isNotEmpty) {
                    showSuccessSnackbar(context, 'Don de $amount XOF confirmé!');
                    setState(() {
                      _selectedCause = '';
                      _selectedAmount = '';
                      _customAmountController.clear();
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
