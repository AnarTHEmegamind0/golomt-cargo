import 'package:core/core/brand_palette.dart';
import 'package:core/core/services/export_service.dart';
import 'package:core/features/admin/providers/admin_logs_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Admin activity logs page
class AdminLogsPage extends StatefulWidget {
  const AdminLogsPage({super.key});

  @override
  State<AdminLogsPage> createState() => _AdminLogsPageState();
}

class _AdminLogsPageState extends State<AdminLogsPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminLogsProvider>().loadLogs();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<AdminLogsProvider>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminLogsProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Үйлдлийн лог',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      try {
                        final result = await context
                            .read<ExportService>()
                            .exportAdminLogsXlsx();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(result.message)),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                error.toString().replaceFirst(
                                  'Exception: ',
                                  '',
                                ),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download_rounded),
                    tooltip: 'Excel export',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('Бүгд'),
                    selected: provider.actionFilter == null,
                    onSelected: (_) => provider.clearFilters(),
                  ),
                  FilterChip(
                    label: const Text('Үүсгэсэн'),
                    selected: provider.actionFilter == 'CREATE',
                    onSelected: (_) => provider.setActionFilter('CREATE'),
                  ),
                  FilterChip(
                    label: const Text('Шинэчилсэн'),
                    selected: provider.actionFilter == 'UPDATE',
                    onSelected: (_) => provider.setActionFilter('UPDATE'),
                  ),
                  FilterChip(
                    label: const Text('Төлөв'),
                    selected: provider.actionFilter == 'STATUS_CHANGE',
                    onSelected: (_) =>
                        provider.setActionFilter('STATUS_CHANGE'),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadLogs(forceRefresh: true),
            child: provider.isLoading && provider.logs.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.logs.isEmpty
                ? Center(
                    child: Text(
                      'Лог байхгүй',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount:
                        provider.logs.length + (provider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == provider.logs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      final log = provider.logs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E9F2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: BrandPalette.electricBlue.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  log.adminName.isNotEmpty
                                      ? log.adminName[0].toUpperCase()
                                      : 'A',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: BrandPalette.electricBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        log.adminName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        log.timeDisplay,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: BrandPalette.mutedText,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    log.description,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BrandPalette.electricBlue
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          log.actionLabel,
                                          style: const TextStyle(
                                            color: BrandPalette.electricBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: BrandPalette.navyBlue
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          log.targetTypeLabel,
                                          style: const TextStyle(
                                            color: BrandPalette.navyBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
