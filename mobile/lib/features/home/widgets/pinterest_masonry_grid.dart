import 'package:core/features/home/models/pin_item.dart';
import 'package:core/features/home/widgets/pin_item_card.dart';
import 'package:flutter/material.dart';

class PinterestMasonryGrid extends StatelessWidget {
  const PinterestMasonryGrid({super.key, required this.items});

  final List<PinItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columnCount = width >= 1200
            ? 4
            : width >= 900
            ? 3
            : 2;

        final columns = _distributeItems(items, columnCount);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(columnCount, (index) {
            final columnItems = columns[index];

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: index == 0 ? 0 : 12),
                child: Column(
                  children: [
                    for (var i = 0; i < columnItems.length; i++) ...[
                      PinItemCard(item: columnItems[i]),
                      if (i != columnItems.length - 1)
                        const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            );
          }),
        );
      },
    );
  }

  List<List<PinItem>> _distributeItems(
    List<PinItem> allItems,
    int columnCount,
  ) {
    final columns = List.generate(columnCount, (_) => <PinItem>[]);
    final estimatedHeights = List<double>.filled(columnCount, 0);

    for (final item in allItems) {
      var targetColumn = 0;
      var minHeight = estimatedHeights[0];

      for (var index = 1; index < columnCount; index++) {
        if (estimatedHeights[index] < minHeight) {
          minHeight = estimatedHeights[index];
          targetColumn = index;
        }
      }

      columns[targetColumn].add(item);
      estimatedHeights[targetColumn] += (1 / item.aspectRatio) + 0.55;
    }

    return columns;
  }
}
