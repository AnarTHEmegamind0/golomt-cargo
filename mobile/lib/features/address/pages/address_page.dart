import 'package:core/core/design_system/components/app_card.dart';
import 'package:core/core/design_system/components/cargo_backdrop.dart';
import 'package:core/core/design_system/components/copyable_text.dart';
import 'package:flutter/material.dart';

class AddressPage extends StatelessWidget {
  const AddressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CargoBackdrop(
        light: !isDark,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Хаяг холбох',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _AddressHeaderCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _AddressDetailsCard(),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressHeaderCard extends StatelessWidget {
  const _AddressHeaderCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Цагаан хуаран',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            'Яармаг',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFB7C2D4) : const Color(0xFF4A5568),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressDetailsCard extends StatelessWidget {
  const _AddressDetailsCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          CopyableText(
            label: 'Хүлээн авагч',
            text: '全球的',
            toastMessage: 'Хүлээн авагч хуулагдлаа',
          ),
          SizedBox(height: 10),
          CopyableText(
            label: 'Утас',
            text: '13214791668',
            toastMessage: 'Утасны дугаар хуулагдлаа',
          ),
          SizedBox(height: 10),
          CopyableText(
            label: 'Бүс нутаг',
            text: '内蒙古自治区 锡林郭勒盟 二连浩特市 社区建设管理局',
            toastMessage: 'Бүс нутаг хуулагдлаа',
          ),
          SizedBox(height: 10),
          CopyableText(
            label: 'Хаяг',
            text: '利众物流G2-8号办公室(Захиалагчийн нэр)(Утасны дугаар)',
            toastMessage: 'Хаяг хуулагдлаа',
          ),
        ],
      ),
    );
  }
}
