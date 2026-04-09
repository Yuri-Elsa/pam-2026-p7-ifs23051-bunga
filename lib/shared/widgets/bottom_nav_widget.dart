// lib/shared/widgets/bottom_nav_widget.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';

class _NavItem {
  const _NavItem({
    required this.label,
    required this.route,
    required this.icon,
    required this.activeIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key, required this.child});

  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      route: RouteConstants.home,
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    _NavItem(
      label: 'Tanaman',
      route: RouteConstants.plants,
      icon: Icons.eco_outlined,
      activeIcon: Icons.eco,
    ),
    _NavItem(
      label: 'Bunga',
      route: RouteConstants.flowers,
      icon: Icons.local_florist_outlined,
      activeIcon: Icons.local_florist,
    ),
    _NavItem(
      label: 'Profile',
      route: RouteConstants.profile,
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  String _getCurrentRoute(BuildContext context) {
    return GoRouterState.of(context).uri.toString();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = _getCurrentRoute(context);
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: ColoredBox(
          color: colorScheme.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: NavigationBar(
              height: 70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: Colors.transparent,
              selectedIndex: _getSelectedIndex(currentLocation),
              onDestinationSelected: (index) {
                context.go(_items[index].route);
              },
              destinations: _items.map((item) {
                final isSelected =
                    currentLocation.startsWith(item.route) &&
                        (item.route == RouteConstants.home
                            ? currentLocation == RouteConstants.home
                            : true);

                return NavigationDestination(
                  key: Key(item.label),
                  icon: _NavIcon(item: item, isSelected: isSelected),
                  label: item.label,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location == RouteConstants.home) return 0;
    if (location.startsWith(RouteConstants.plants)) return 1;
    if (location.startsWith(RouteConstants.flowers)) return 2;
    if (location.startsWith(RouteConstants.profile)) return 3;
    return 0;
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.item, required this.isSelected});

  final _NavItem item;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Warna aktif untuk bunga menggunakan secondary (kuning/amber),
    // untuk item lainnya tetap primary (hijau)
    final isFlower = item.route == RouteConstants.flowers;
    final activeColor =
    isFlower ? colorScheme.secondary : colorScheme.primary;
    final activeBg = isFlower
        ? colorScheme.secondaryContainer.withValues(alpha: 0.25)
        : colorScheme.primaryContainer.withValues(alpha: 0.2);
    final activeBorder = isFlower
        ? colorScheme.secondary.withValues(alpha: 0.35)
        : colorScheme.primary.withValues(alpha: 0.3);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 48,
      decoration: isSelected
          ? BoxDecoration(
        color: activeBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: activeBorder),
      )
          : null,
      child: Icon(
        isSelected ? item.activeIcon : item.icon,
        color: isSelected ? activeColor : colorScheme.onSurfaceVariant,
      ),
    );
  }
}