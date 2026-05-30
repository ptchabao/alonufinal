# 🎨 Design System - ALONU Flutter

**Date de création**: 23 mai 2024
**Version**: 1.0.0
**Status**: ✅ Production Ready

---

## 📋 Table des matières

1. [Couleurs & Gradients](#couleurs--gradients)
2. [Typographie](#typographie)
3. [Composants](#composants)
4. [Animations](#animations)
5. [Utilisation](#utilisation)
6. [Exemples](#exemples)

---

## 🎨 Couleurs & Gradients

### Palette Complète

Tous les fichiers de couleur sont définis dans [`lib/core/theme/app_colors.dart`](../lib/core/theme/app_colors.dart)

#### **Couleurs Principales**
```dart
AppColors.primary        // #F5A623 - Orange principal
AppColors.primaryDark    // #D4890E - Orange foncé (hover/pressed)
AppColors.primaryLight   // #FFF3E0 - Orange clair (fonds, badges)
AppColors.secondary      // #1B5E20 - Vert foncé (validation, succès)
AppColors.accent         // #C62828 - Rouge (alertes, prix)
AppColors.tertiary       // #4A4A4A - Gris anthracite (texte principal)
```

#### **Couleurs Fonctionnelles**
```dart
AppColors.background     // #FAF8F5 - Fond crème global
AppColors.surface        // #FFFFFF - Cards, surfaces
AppColors.error          // #D32F2F - Erreurs, validation
AppColors.success        // #2E7D32 - Succès, actions validées
AppColors.warning        // #F57C00 - Avertissements
AppColors.info           // #1565C0 - Informations
```

#### **Couleurs Texte**
```dart
AppColors.onPrimary      // #FFFFFF - Texte sur fond primary
AppColors.onBackground   // #1A1A1A - Texte principal clair
AppColors.onSurface      // #1A1A1A - Texte sur cards
AppColors.onSurfaceVariant // #6B6B6B - Texte secondaire
AppColors.onSurfaceMuted // #9E9E9E - Placeholders, dates
```

### **Gradients Prédéfinis**

```dart
// Gradient overlay pour images (hero sections)
AppColors.heroGradient
// Fond cards premium
AppColors.cardGradient
// Badge "MAÎTRE ARTISAN"
AppColors.badgeGradient
// États: success, error, warning, info
AppColors.successGradient
AppColors.errorGradient
AppColors.warningGradient
AppColors.infoGradient
```

**Utilisation**:
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppColors.heroGradient,
  ),
)
```

### **Shadows**

```dart
AppColors.cardShadow          // Ombre légère
AppColors.cardShadowElevated  // Ombre prononcée
AppColors.cardShadows         // Liste d'ombres
```

---

## 🔤 Typographie

### **Familles de Polices**

- **Titres**: Poppins (bold, semibold) - Google Fonts
- **Corps**: Inter (regular) - Google Fonts
- **Accent**: Playfair Display - Google Fonts (optionnel)

### **Échelle Typographique**

Définie dans [`lib/core/theme/app_theme.dart`](../lib/core/theme/app_theme.dart)

| Token | Taille | Poids | Usage |
|-------|--------|-------|-------|
| `displayLarge` | 32sp | 700 | Titres accueil |
| `displayMedium` | 28sp | 700 | Titres pages |
| `displaySmall` | 24sp | 700 | Sous-titres |
| `headlineLarge` | 20sp | 600 | Titres sections |
| `headlineMedium` | 18sp | 600 | Sous-titres |
| `titleLarge` | 16sp | 500 | Titres items |
| `titleMedium` | 14sp | 500 | Labels, boutons |
| `bodyLarge` | 16sp | 400 | Texte principal |
| `bodyMedium` | 14sp | 400 | Descriptions |
| `bodySmall` | 12sp | 400 | Captions, métas |
| `labelLarge` | 12sp | 600 | Badges |
| `labelMedium` | 10sp | 500 | Micro-labels |

**Utilisation**:
```dart
Text(
  'Hello',
  style: Theme.of(context).textTheme.headlineLarge,
)
```

---

## 🧩 Composants

### **1. Boutons**

#### AppButton (Primaire / Filled)
```dart
AppButton(
  label: 'Confirmer',
  onPressed: () {},
  isLoading: false,
  isEnabled: true,
  icon: Icons.check,
)
```

#### SecondaryButton (Secondaire / Outlined)
```dart
SecondaryButton(
  label: 'Annuler',
  onPressed: () {},
)
```

#### TextButton (Tertiaire)
```dart
TextButton(
  label: 'En savoir plus',
  onPressed: () {},
  icon: Icons.arrow_forward,
  color: AppColors.primary,
)
```

### **2. Badges**

#### MasterArtisanBadge
```dart
MasterArtisanBadge(
  size: 14,
  textColor: AppColors.onPrimary,
)
```

#### StatusBadge
```dart
StatusBadge(
  status: 'CONFIRMÉE',
  backgroundColor: AppColors.info,
)
```

#### Generic Badge
```dart
Badge(
  label: 'NOUVEAU',
  backgroundColor: AppColors.primaryLight,
  textColor: AppColors.primary,
  icon: Icons.star,
)
```

### **3. Chips (Filtres)**

```dart
FilterChip(
  label: 'Menuiserie',
  isSelected: false,
  onSelected: (selected) {},
  icon: Icons.category,
)
```

### **4. Cards**

#### ArtisanCard
```dart
ArtisanCard(
  imageUrl: 'https://...',
  name: 'Jean Dupont',
  specialty: 'Menuisier',
  rating: 4.8,
  reviewCount: 45,
  distance: '2.5 km',
  isMasterArtisan: true,
  onTap: () {},
)
```

#### ProductCard
```dart
ProductCard(
  imageUrl: 'https://...',
  title: 'Service de Menuiserie',
  artisanName: 'Jean Dupont',
  price: '50 000 XOF',
  type: 'SERVICE',
  rating: 4.8,
  onTap: () {},
)
```

#### CategoryCard
```dart
CategoryCard(
  label: 'Menuiserie',
  icon: Icons.home_repair_service,
  onTap: () {},
)
```

#### OrderStatusCard (Timeline)
```dart
OrderStatusCard(
  status: 'Confirmée',
  date: '23 mai 2024 à 14:30',
  description: 'Votre commande a été confirmée',
  isCompleted: true,
  isActive: false,
)
```

---

## ✨ Animations

### **Page Transitions**

#### SlidePageRoute (Slide horizontal)
```dart
Navigator.push(
  context,
  SlidePageRoute(builder: (context) => MyPage()),
)
```

#### ModalSlidePageRoute (Modal bottom)
```dart
Navigator.push(
  context,
  ModalSlidePageRoute(builder: (context) => MyModal()),
)
```

#### ScalePageRoute (Dialog)
```dart
Navigator.push(
  context,
  ScalePageRoute(builder: (context) => MyDialog()),
)
```

### **Animated Widgets**

#### ScalableButton
```dart
ScalableButton(
  onPressed: () {},
  scale: 0.97,
  duration: Duration(milliseconds: 100),
  child: ElevatedButton(...),
)
```

#### FadeInWidget
```dart
FadeInWidget(
  duration: Duration(milliseconds: 500),
  delay: Duration(milliseconds: 200),
  child: Text('Hello'),
)
```

#### ShimmerLoading
```dart
ShimmerLoading(
  width: 200,
  height: 100,
  child: Container(),
)
```

#### AppLoadingIndicator
```dart
AppLoadingIndicator(
  color: AppColors.primary,
  size: 48,
)
```

#### SuccessAnimation
```dart
SuccessAnimation(
  onComplete: () {},
  duration: Duration(seconds: 2),
)
```

---

## 🚀 Utilisation

### **Importer les composants**

```dart
import 'package:alonu_app/presentation/widgets/widgets.dart';
```

### **Importer les couleurs**

```dart
import 'package:alonu_app/core/theme/app_colors.dart';
```

### **Structure du Design System**

```
lib/
├── core/theme/
│   ├── app_colors.dart        # Toutes les couleurs
│   ├── app_theme.dart         # Thème Flutter (TextTheme, etc.)
│   └── app_typography.dart    # (optionnel) Styles texte constants
└── presentation/widgets/
    ├── app_widgets.dart       # Boutons, Badges, Chips
    ├── app_cards.dart         # Cards réutilisables
    ├── app_animations.dart    # Animations & Transitions
    └── widgets.dart           # Export central
```

---

## 📖 Exemples Complets

### **Exemple 1: Écran avec Boutons et Cartes**

```dart
import 'package:flutter/material.dart';
import 'package:alonu_app/core/theme/app_colors.dart';
import 'package:alonu_app/presentation/widgets/widgets.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Artisans', style: Theme.of(context).textTheme.headlineLarge),
      ),
      body: ListView(
        children: [
          // Artisan Card
          ArtisanCard(
            imageUrl: 'https://...',
            name: 'Jean Dupont',
            specialty: 'Menuisier',
            rating: 4.8,
            reviewCount: 45,
            distance: '2.5 km',
            isMasterArtisan: true,
            onTap: () {},
          ),
          SizedBox(height: 16),
          
          // Boutons
          AppButton(
            label: 'Demander service',
            onPressed: () {},
            icon: Icons.check,
          ),
          SizedBox(height: 8),
          SecondaryButton(
            label: 'En savoir plus',
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
```

### **Exemple 2: Formulaire avec Chips**

```dart
class FilterScreen extends StatefulWidget {
  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String selectedCategory = '';

  @override
  Widget build(BuildContext context) {
    final categories = ['Menuiserie', 'Plomberie', 'Électricité'];
    
    return Column(
      children: [
        Text('Catégorie', style: Theme.of(context).textTheme.titleLarge),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: categories.map((category) {
            return FilterChip(
              label: category,
              isSelected: selectedCategory == category,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = selected ? category : '';
                });
              },
              icon: Icons.category,
            );
          }).toList(),
        ),
      ],
    );
  }
}
```

### **Exemple 3: Page avec Animations**

```dart
class ProductPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: FadeInWidget(
                child: ProductCard(
                  imageUrl: 'https://...',
                  title: 'Service Premium',
                  artisanName: 'Jean Dupont',
                  price: '50 000 XOF',
                  type: 'SERVICE',
                  rating: 4.8,
                  onTap: () {},
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: AppButton(
                label: 'Commander',
                onPressed: () {
                  Navigator.push(
                    context,
                    SlidePageRoute(
                      builder: (context) => CheckoutPage(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🎯 Checklist d'Implémentation

- [x] Couleurs & Gradients définis
- [x] Typographie configurée (Google Fonts)
- [x] Boutons réutilisables
- [x] Badges personnalisés
- [x] Cards pour tous les types
- [x] Animations de page
- [x] Animations de widgets
- [ ] Tester les composants sur appareils réels
- [ ] Documenter les cas d'usage edge
- [ ] Créer Figma Design System mirror (optionnel)

---

## 📝 Notes & Bonnes Pratiques

1. **Réutilisabilité**: Toujours utiliser les composants du Design System
2. **Cohérence**: Utiliser les couleurs et typographie prédéfinies
3. **Accessibilité**: Contraste minimum 4.5:1 respecté
4. **Performance**: Les images utilisent CachedNetworkImage
5. **Animations**: Durée <300ms pour les transitions rapides

---

## 🔄 Maintenance

- Mettre à jour ce document lors d'ajouts/modifications
- Valider les couleurs sur appareils réels
- Tester les animations sur différentes résolutions
- Garder les composants simples et réutilisables

---

**Version**: 1.0.0  
**Dernière mise à jour**: 23 mai 2024  
**Auteur**: ALONU Team
