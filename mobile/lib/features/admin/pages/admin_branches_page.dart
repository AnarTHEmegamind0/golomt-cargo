import 'package:core/core/assets/ship_assets.dart';
import 'package:core/core/assets/ship_icon.dart';
import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/providers/admin_branches_provider.dart';
import 'package:core/features/branch/models/branch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin branch management page
class AdminBranchesPage extends StatefulWidget {
  const AdminBranchesPage({super.key});

  @override
  State<AdminBranchesPage> createState() => _AdminBranchesPageState();
}

class _AdminBranchesPageState extends State<AdminBranchesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminBranchesProvider>().loadBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminBranchesProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Салбарууд',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () => _showCreateDialog(context),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: BrandPalette.electricBlue,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadBranches(forceRefresh: true),
            child: provider.isLoading && provider.branches.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.branches.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShipIcon(
                          ShipAssets.locationMaps,
                          size: 64,
                          color: BrandPalette.mutedText.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Салбар байхгүй',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: BrandPalette.mutedText),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: provider.branches.length,
                    itemBuilder: (context, index) {
                      final branch = provider.branches[index];
                      return _BranchCard(
                        branch: branch,
                        isProcessing: provider.processingBranchId == branch.id,
                        onToggleActive: () => provider.toggleActive(branch.id),
                        onEdit: () => _showEditDialog(context, branch),
                        onDelete: () => _showDeleteConfirm(context, branch),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _showCreateDialog(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final chinaAddressController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Шинэ салбар'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Нэр'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Код'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Хаяг'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Утас'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chinaAddressController,
                decoration: const InputDecoration(labelText: 'Хятад хаяг'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              if (nameController.text.isEmpty || codeController.text.isEmpty)
                return;
              Navigator.pop(ctx);
              this.context.read<AdminBranchesProvider>().createBranch(
                name: nameController.text.trim(),
                code: codeController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                chinaAddress: chinaAddressController.text.trim(),
              );
            },
            child: const Text('Үүсгэх'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Branch branch) {
    final nameController = TextEditingController(text: branch.name);
    final addressController = TextEditingController(text: branch.address);
    final phoneController = TextEditingController(text: branch.phone);
    final chinaAddressController = TextEditingController(
      text: branch.chinaAddress,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Салбар засах'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Нэр'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Хаяг'),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Утас'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: chinaAddressController,
                decoration: const InputDecoration(labelText: 'Хятад хаяг'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              this.context.read<AdminBranchesProvider>().updateBranch(
                branchId: branch.id,
                name: nameController.text.trim(),
                address: addressController.text.trim(),
                phone: phoneController.text.trim(),
                chinaAddress: chinaAddressController.text.trim(),
              );
            },
            child: const Text('Хадгалах'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Branch branch) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Салбар устгах'),
        content: Text('${branch.name} салбарыг устгах уу?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Болих'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              this.context.read<AdminBranchesProvider>().deleteBranch(
                branch.id,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: BrandPalette.errorRed,
            ),
            child: const Text('Устгах'),
          ),
        ],
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({
    required this.branch,
    required this.isProcessing,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });
  final Branch branch;
  final bool isProcessing;
  final VoidCallback onToggleActive, onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: branch.isActive
              ? const Color(0xFFE5E9F2)
              : BrandPalette.errorRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: BrandPalette.electricBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: ShipIcon(
                    ShipAssets.locationMaps,
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
                      branch.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      branch.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      (branch.isActive
                              ? BrandPalette.successGreen
                              : BrandPalette.errorRed)
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  branch.isActive ? 'Идэвхтэй' : 'Идэвхгүй',
                  style: TextStyle(
                    color: branch.isActive
                        ? BrandPalette.successGreen
                        : BrandPalette.errorRed,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (branch.chinaAddress.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Хятад: ${branch.chinaAddress}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: BrandPalette.mutedText),
              maxLines: 2,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              if (branch.phone.isNotEmpty) ...[
                Icon(Icons.phone, size: 14, color: BrandPalette.mutedText),
                const SizedBox(width: 4),
                Text(
                  branch.phone,
                  style: const TextStyle(
                    fontSize: 12,
                    color: BrandPalette.mutedText,
                  ),
                ),
              ],
              const Spacer(),
              IconButton(
                onPressed: isProcessing ? null : onToggleActive,
                icon: Icon(
                  branch.isActive
                      ? Icons.pause_circle_outline
                      : Icons.play_circle_outline,
                ),
              ),
              IconButton(
                onPressed: isProcessing ? null : onEdit,
                icon: const Icon(Icons.edit),
                style: IconButton.styleFrom(
                  foregroundColor: BrandPalette.electricBlue,
                ),
              ),
              IconButton(
                onPressed: isProcessing ? null : onDelete,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  foregroundColor: BrandPalette.errorRed,
                ),
              ),
            ],
          ),
          if (isProcessing) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
