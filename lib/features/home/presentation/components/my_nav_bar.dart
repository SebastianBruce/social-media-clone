import 'package:flutter/material.dart';

class MyCustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;

  const MyCustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 35, left: 24, right: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home_filled,
            selected: currentIndex == 0,
            onTap: () => onItemSelected(0),
          ),
          _NavItem(
            icon: Icons.explore_outlined,
            selectedIcon: Icons.explore,
            selected: currentIndex == 1,
            onTap: () => onItemSelected(1),
          ),
          _NavItem(
            icon: Icons.send_outlined,
            selectedIcon: Icons.send, // optional
            selected: currentIndex == 2,
            onTap: () => onItemSelected(2),
          ),
          _NavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            selected: currentIndex == 3,
            onTap: () => onItemSelected(3),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        selected ? selectedIcon : icon,
        size: 28,
        color: selected
            ? Theme.of(context).colorScheme.inversePrimary
            : Theme.of(context).colorScheme.inversePrimary,
      ),
    );
  }
}
