import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

class MainBottomNavBar extends StatelessWidget {
  final Widget child;

  const MainBottomNavBar({super.key, required this.child});

  static const double _homeButtonSize = 60;

  @override
  Widget build(BuildContext context) {
    final activeTab = _activeTab(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        child: SizedBox(
          height: 92,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                top: 28,
                child: ColoredBox(
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      _NavItem(
                        icon: Icons.tv,
                        label: 'TV',
                        isActive: activeTab == _Tab.tv,
                        onTap: () => context.go('/tv'),
                      ),
                      _NavItem(
                        icon: Icons.search,
                        label: 'Recherche',
                        isActive: activeTab == _Tab.search,
                        onTap: () => context.go('/search'),
                      ),
                      const SizedBox(width: _homeButtonSize),
                      _NavItem(
                        icon: Icons.shopping_bag,
                        label: 'Commandes',
                        isActive: activeTab == _Tab.orders,
                        onTap: () => context.go('/orders'),
                      ),
                      _NavItem(
                        icon: Icons.person,
                        label: 'Profil',
                        isActive: activeTab == _Tab.profile,
                        onTap: () => context.go('/profile'),
                      ),
                    ],
                  ),
                ),
              ),
              // Bouton Accueil : rond, en avant-plan, toujours centré.
              GestureDetector(
                onTap: () => context.go('/home'),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: _homeButtonSize,
                      height: _homeButtonSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: AppColors.surface, width: 3),
                      ),
                      child: const Icon(
                        Icons.home,
                        color: AppColors.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Accueil',
                      style: TextStyle(
                        fontSize: 11,
                        color: activeTab == _Tab.home
                            ? AppColors.primaryDark
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _Tab _activeTab(BuildContext context) {
    final location =
        GoRouter.of(context).routerDelegate.currentConfiguration.uri.path;
    if (location.startsWith('/tv')) return _Tab.tv;
    if (location.startsWith('/search')) return _Tab.search;
    if (location.startsWith('/orders')) return _Tab.orders;
    if (location.startsWith('/profile')) return _Tab.profile;
    return _Tab.home;
  }
}

enum _Tab { home, tv, search, orders, profile }

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryDark : AppColors.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
