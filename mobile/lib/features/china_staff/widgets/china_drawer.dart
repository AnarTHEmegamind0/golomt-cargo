import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:flutter/material.dart';

/// China staff navigation drawer item
class ChinaDrawerItem {
  const ChinaDrawerItem({
    required this.index,
    required this.label,
    required this.assetPath,
  });

  final int index;
  final String label;
  final String assetPath;
}

/// China staff navigation drawer items
const chinaDrawerItems = [
  ChinaDrawerItem(index: 0, label: 'Тойм', assetPath: ShipAssets.clockAndHome),
  ChinaDrawerItem(
    index: 1,
    label: 'Бараа бүртгэл',
    assetPath: ShipAssets.boxReturn,
  ),
  ChinaDrawerItem(index: 2, label: 'Машин', assetPath: ShipAssets.car),
  ChinaDrawerItem(index: 3, label: 'Ачилт', assetPath: ShipAssets.truck),
];

/// China staff navigation drawer
class ChinaDrawer extends StatelessWidget {
  const ChinaDrawer({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
  });

  final int currentIndex;
  final void Function(int index) onItemSelected;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: BrandPalette.logoOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ShipIcon(
                      ShipAssets.handWithCare,
                      color: BrandPalette.logoOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Хятад агуулах',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: BrandPalette.primaryText,
                            ),
                      ),
                      Text(
                        'Голомт Карго',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrandPalette.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  for (final item in chinaDrawerItems)
                    _DrawerItem(
                      item: item,
                      isSelected: currentIndex == item.index,
                      onTap: () {
                        onItemSelected(item.index);
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: BrandPalette.mutedText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final ChinaDrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? BrandPalette.logoOrange.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                ShipIcon(
                  item.assetPath,
                  size: 22,
                  color: isSelected
                      ? BrandPalette.logoOrange
                      : BrandPalette.mutedText,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? BrandPalette.logoOrange
                        : BrandPalette.primaryText,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
