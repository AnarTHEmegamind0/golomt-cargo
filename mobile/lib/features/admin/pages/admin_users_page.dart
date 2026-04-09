import 'dart:async';

import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/providers/admin_users_provider.dart';
import 'package:core/features/admin/widgets/admin_user_card.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Shows an error dialog with the given message
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: const Icon(
        Icons.error_outline_rounded,
        color: BrandPalette.errorRed,
        size: 48,
      ),
      title: const Text('Алдаа гарлаа'),
      content: Text(
        message,
        style: Theme.of(dialogContext).textTheme.bodyMedium,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Ойлголоо'),
        ),
      ],
    ),
  );
}

/// Admin user management page
class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  final _searchController = TextEditingController();
  String? _lastShownError;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminUsersProvider>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    final provider = context.read<AdminUsersProvider>();
    if (query.trim().isEmpty) {
      provider.loadUsers(forceRefresh: true);
    } else {
      provider.searchUsers(query.trim());
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _debounce?.cancel();
    setState(() {});
    context.read<AdminUsersProvider>().loadUsers(forceRefresh: true);
  }

  void _checkAndShowError(AdminUsersProvider provider) {
    final error = provider.error;
    if (error != null && error != _lastShownError) {
      _lastShownError = error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showErrorDialog(context, error);
          provider.clearError();
        }
      });
    } else if (error == null) {
      _lastShownError = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminUsersProvider>();

    // Check for errors and show dialog
    _checkAndShowError(provider);

    return Column(
      children: [
        // Header with search
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Хэрэглэгчид',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: BrandPalette.primaryText,
                          ),
                    ),
                  ),
                  // Add user button
                  IconButton.filled(
                    onPressed: () => _showCreateUserDialog(context),
                    icon: const Icon(Icons.person_add_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: BrandPalette.electricBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Search bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Имэйл, нэрээр хайх...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: 'Цэвэрлэх',
                        ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () =>
                              _performSearch(_searchController.text),
                          icon: const Icon(Icons.search_rounded),
                          tooltip: 'Хайх',
                        ),
                    ],
                  ),
                  filled: true,
                  fillColor: BrandPalette.softBlueBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: _onSearchChanged,
                onSubmitted: _performSearch,
                textInputAction: TextInputAction.search,
              ),
            ],
          ),
        ),

        // User list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => provider.loadUsers(forceRefresh: true),
            child: provider.isLoading && provider.users.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.users.isEmpty
                ? _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: provider.users.length,
                    itemBuilder: (context, index) {
                      final user = provider.users[index];
                      return AdminUserCard(
                        user: user,
                        isProcessing: provider.isLoading,
                        onRoleChange: (role) => _onRoleChange(user.id, role),
                        onBan: () => _onBan(user.id),
                        onUnban: () => _onUnban(user.id),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _onRoleChange(String userId, UserRole role) {
    context.read<AdminUsersProvider>().setUserRole(userId, role);
  }

  void _onBan(String userId) {
    showDialog(
      context: context,
      builder: (context) => _BanUserDialog(
        onBan: (reason) {
          this.context.read<AdminUsersProvider>().banUser(
            userId,
            reason: reason,
          );
        },
      ),
    );
  }

  void _onUnban(String userId) {
    context.read<AdminUsersProvider>().unbanUser(userId);
  }

  void _showCreateUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _CreateUserDialog(
        onSubmit: (email, password, name, role) {
          this.context.read<AdminUsersProvider>().createUser(
            email: email,
            password: password,
            name: name,
            role: role,
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 64,
            color: BrandPalette.mutedText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Хэрэглэгч олдсонгүй',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: BrandPalette.mutedText),
          ),
        ],
      ),
    );
  }
}

class _BanUserDialog extends StatefulWidget {
  const _BanUserDialog({required this.onBan});

  final void Function(String? reason) onBan;

  @override
  State<_BanUserDialog> createState() => _BanUserDialogState();
}

class _BanUserDialogState extends State<_BanUserDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Хэрэглэгч хориглох'),
      content: TextField(
        controller: _reasonController,
        decoration: const InputDecoration(
          labelText: 'Шалтгаан (заавал биш)',
          hintText: 'Хориглосон шалтгаан...',
        ),
        maxLines: 2,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onBan(
              _reasonController.text.isNotEmpty ? _reasonController.text : null,
            );
          },
          style: FilledButton.styleFrom(backgroundColor: BrandPalette.errorRed),
          child: const Text('Хориглох'),
        ),
      ],
    );
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog({required this.onSubmit});

  final void Function(String email, String password, String name, UserRole role)
  onSubmit;

  @override
  State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  UserRole _selectedRole = UserRole.customer;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Шинэ хэрэглэгч'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Нэр'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Нэр оруулна уу' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Имэйл'),
              keyboardType: TextInputType.emailAddress,
              validator: (v) =>
                  v == null || !v.contains('@') ? 'Имэйл оруулна уу' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Нууц үг'),
              obscureText: true,
              validator: (v) =>
                  v == null || v.length < 6 ? '6+ тэмдэгт шаардлагатай' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<UserRole>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(labelText: 'Эрх'),
              items: UserRole.values.map((role) {
                return DropdownMenuItem(value: role, child: Text(role.label));
              }).toList(),
              onChanged: (role) {
                if (role != null) {
                  setState(() => _selectedRole = role);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Болих'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              Navigator.pop(context);
              widget.onSubmit(
                _emailController.text,
                _passwordController.text,
                _nameController.text,
                _selectedRole,
              );
            }
          },
          child: const Text('Үүсгэх'),
        ),
      ],
    );
  }
}
