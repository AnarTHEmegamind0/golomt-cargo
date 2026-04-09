import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/pricing_calculation.dart';
import 'package:core/features/admin/services/pricing_service.dart';
import 'package:core/features/orders/widgets/pricing_breakdown_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// User-facing pricing calculator page
class PricingCalculatorPage extends StatefulWidget {
  const PricingCalculatorPage({super.key});

  @override
  State<PricingCalculatorPage> createState() => _PricingCalculatorPageState();
}

class _PricingCalculatorPageState extends State<PricingCalculatorPage> {
  final _formKey = GlobalKey<FormState>();
  final _pricingService = const PricingService();

  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _widthController = TextEditingController();
  final _lengthController = TextEditingController();

  bool _isFragile = false;
  PricingCalculation? _calculation;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weightKg = double.tryParse(_weightController.text) ?? 0;
    final heightCm = int.tryParse(_heightController.text) ?? 0;
    final widthCm = int.tryParse(_widthController.text) ?? 0;
    final lengthCm = int.tryParse(_lengthController.text) ?? 0;

    final calculation = _pricingService.calculate(
      weightKg: weightKg,
      heightCm: heightCm,
      widthCm: widthCm,
      lengthCm: lengthCm,
      isFragile: _isFragile,
    );

    setState(() => _calculation = calculation);
  }

  void _reset() {
    _weightController.clear();
    _heightController.clear();
    _widthController.clear();
    _lengthController.clear();
    setState(() {
      _isFragile = false;
      _calculation = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandPalette.softBlueBackground,
      appBar: AppBar(
        title: const Text('Үнийн тооцоолуур'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_calculation != null)
            IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Дахин тооцох',
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info card
              _buildInfoCard(),
              const SizedBox(height: 20),

              // Pricing rates
              _buildRatesCard(),
              const SizedBox(height: 20),

              // Input form
              _buildInputForm(),
              const SizedBox(height: 24),

              // Calculate button
              FilledButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: const Text('Тооцоолох'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Result
              if (_calculation != null) ...[
                PricingBreakdownWidget(calculation: _calculation!),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            BrandPalette.electricBlue.withValues(alpha: 0.1),
            BrandPalette.skyBlue.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BrandPalette.electricBlue.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: BrandPalette.electricBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: ShipIcon(
                ShipAssets.wallet,
                color: BrandPalette.electricBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Урьдчилсан үнийн тооцоо',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: BrandPalette.electricBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Барааны жин, хэмжээс оруулж тээврийн төлбөрөө урьдчилан тооцоорой.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BrandPalette.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.price_change_outlined,
                color: BrandPalette.electricBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Үнийн тариф',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _RateRow(
            icon: Icons.scale,
            label: 'Жингээр',
            value: '${PricingRates.pricePerKg}₮/кг',
          ),
          const SizedBox(height: 8),
          _RateRow(
            icon: Icons.view_in_ar,
            label: 'Эзлэхүүнээр',
            value: '${PricingRates.pricePerCbm}₮/м³',
          ),
          const SizedBox(height: 8),
          _RateRow(
            icon: Icons.warning_amber,
            label: 'Эмзэг бараа',
            value: '${PricingRates.pricePerCbmFragile}₮/м³',
            color: BrandPalette.logoOrange,
          ),
          const SizedBox(height: 8),
          _RateRow(
            icon: Icons.info_outline,
            label: 'Доод хязгаар',
            value: '${PricingRates.minimumFee}₮',
          ),
        ],
      ),
    );
  }

  Widget _buildInputForm() {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Барааны мэдээлэл',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            // Weight input
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Жин (кг)',
                hintText: '0.5',
                prefixIcon: const Icon(Icons.scale_outlined),
                suffixText: 'кг',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Жин оруулна уу';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0) {
                  return 'Зөв жин оруулна уу';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dimensions header
            Row(
              children: [
                const Icon(
                  Icons.straighten,
                  size: 16,
                  color: BrandPalette.mutedText,
                ),
                const SizedBox(width: 6),
                Text(
                  'Хэмжээс (см)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BrandPalette.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dimensions row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Урт',
                      hintText: '30',
                      suffixText: 'см',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Оруулна уу';
                      final v = int.tryParse(value);
                      if (v == null || v <= 0) return 'Буруу';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Өргөн',
                      hintText: '20',
                      suffixText: 'см',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Оруулна уу';
                      final v = int.tryParse(value);
                      if (v == null || v <= 0) return 'Буруу';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'Өндөр',
                      hintText: '15',
                      suffixText: 'см',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Оруулна уу';
                      final v = int.tryParse(value);
                      if (v == null || v <= 0) return 'Буруу';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Fragile toggle
            Container(
              decoration: BoxDecoration(
                color: _isFragile
                    ? BrandPalette.logoOrange.withValues(alpha: 0.1)
                    : BrandPalette.softBlueBackground,
                borderRadius: BorderRadius.circular(12),
                border: _isFragile
                    ? Border.all(
                        color: BrandPalette.logoOrange.withValues(alpha: 0.3),
                      )
                    : null,
              ),
              child: SwitchListTile(
                title: const Text(
                  'Эмзэг бараа',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'Шил, цахилгаан бараа гэх мэт',
                  style: TextStyle(fontSize: 12),
                ),
                secondary: Icon(
                  Icons.warning_amber_rounded,
                  color: _isFragile
                      ? BrandPalette.logoOrange
                      : BrandPalette.mutedText,
                ),
                value: _isFragile,
                onChanged: (value) => setState(() => _isFragile = value),
                activeTrackColor: BrandPalette.logoOrange.withValues(
                  alpha: 0.5,
                ),
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? BrandPalette.logoOrange
                      : null,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color ?? BrandPalette.mutedText),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(color: BrandPalette.mutedText, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: color ?? BrandPalette.primaryText,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
