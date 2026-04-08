import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:flutter/material.dart';

/// Admin navigation drawer section
class AdminDrawerSection {
  const AdminDrawerSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<AdminDrawerItem> items;
}

/// Admin navigation drawer item
class AdminDrawerItem {
  const AdminDrawerItem({
    required this.index,
    required this.label,
    required this.assetPath,
  });

  final int index;
  final String label;
  final String assetPath;
}

/// Admin navigation drawer sections
final adminDrawerSections = [
  const AdminDrawerSection(
    title: 'Үйл ажиллагаа',
    items: [
      AdminDrawerItem(index: 0, label: 'Тойм', assetPath: ShipAssets.clockAndHome),
      AdminDrawerItem(index: 1, label: 'Бараа', assetPath: ShipAssets.boxReturn),
      AdminDrawerItem(index: 2, label: 'Ачилт', assetPath: ShipAssets.truck),
      AdminDrawerItem(index: 3, label: 'Машин', assetPath: ShipAssets.car),
    ],
  ),
  const AdminDrawerSection(
    title: 'Удирдлага',
    items: [
      AdminDrawerItem(
        index: 4,
        label: 'Хэрэглэгчид',
        assetPath: ShipAssets.manDeliveringPackage,
      ),
      AdminDrawerItem(
        index: 5,
        label: 'Салбар',
        assetPath: ShipAssets.locationMaps,
      ),
    ],
  ),
  const AdminDrawerSection(
    title: 'Тайлан',
    items: [
      AdminDrawerItem(index: 6, label: 'Санхүү', assetPath: ShipAssets.wallet),
      AdminDrawerItem(index: 7, label: 'Лог', assetPath: ShipAssets.bell),
    ],
  ),
];

/// Reusable admin drawer widget
class AdminDrawer extends StatelessWidget {
  const AdminDrawer({
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
                      color: BrandPalette.electricBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ShipIcon(
                      ShipAssets.handWithCare,
                      color: BrandPalette.electricBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Админ панел',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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

            // Navigation sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  for (final section in adminDrawerSections) ...[
                    _SectionHeader(title: section.title),
                    for (final item in section.items)
                      _DrawerItem(
                        item: item,
                        isSelected: currentIndex == item.index,
                        onTap: () {
                          onItemSelected(item.index);
                          Navigator.pop(context);
                        },
                      ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),

            // Footer
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'v1.0.0',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: BrandPalette.mutedText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: BrandPalette.mutedText,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
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

  final AdminDrawerItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected
            ? BrandPalette.electricBlue.withValues(alpha: 0.1)
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
                      ? BrandPalette.electricBlue
                      : BrandPalette.mutedText,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? BrandPalette.electricBlue
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
