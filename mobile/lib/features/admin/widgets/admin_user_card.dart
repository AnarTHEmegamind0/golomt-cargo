import 'package:core/core/brand_palette.dart';
import 'package:core/features/admin/models/admin_user.dart';
import 'package:core/features/auth/models/user.dart';
import 'package:flutter/material.dart';

/// User card for admin user management
class AdminUserCard extends StatelessWidget {
  const AdminUserCard({
    super.key,
    required this.user,
    this.onRoleChange,
    this.onBan,
    this.onUnban,
    this.isProcessing = false,
  });

  final AdminUser user;
  final void Function(UserRole)? onRoleChange;
  final VoidCallback? onBan;
  final VoidCallback? onUnban;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: user.banned
              ? BrandPalette.errorRed.withValues(alpha: 0.3)
              : const Color(0xFFE5E9F2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _roleColor(user.role).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _initials(user.name ?? user.email),
                    style: TextStyle(
                      color: _roleColor(user.role),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and email
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? 'Нэргүй',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BrandPalette.primaryText,
                      ),
                    ),
                    Text(
                      user.email,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BrandPalette.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              // Role badge
              _RoleBadge(role: user.role),
            ],
          ),

          // Banned indicator
          if (user.banned) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BrandPalette.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.block_rounded,
                    color: BrandPalette.errorRed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Хориглогдсон',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: BrandPalette.errorRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (user.banReason != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '- ${user.banReason}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: BrandPalette.errorRed.withValues(alpha: 0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Actions
          const SizedBox(height: 12),
          Row(
            children: [
              // Role dropdown
              Expanded(
                child: _RoleDropdown(
                  currentRole: user.role,
                  onChanged: isProcessing ? null : onRoleChange,
                ),
              ),
              const SizedBox(width: 8),
              // Ban/Unban button
              if (user.banned)
                _ActionButton(
                  label: 'Хориг нээх',
                  icon: Icons.lock_open_rounded,
                  color: BrandPalette.successGreen,
                  onPressed: isProcessing ? null : onUnban,
                )
              else
                _ActionButton(
                  label: 'Хориглох',
                  icon: Icons.block_rounded,
                  color: BrandPalette.errorRed,
                  onPressed: isProcessing ? null : onBan,
                ),
            ],
          ),

          // Loading overlay - wrapped in ExcludeSemantics to avoid Flutter bug
          if (isProcessing) ...[
            const SizedBox(height: 8),
            const ExcludeSemantics(
              child: LinearProgressIndicator(
                backgroundColor: Color(0xFFE5E9F2),
                valueColor: AlwaysStoppedAnimation(BrandPalette.electricBlue),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _initials(String text) {
    final parts = text.split(RegExp(r'[\s@]'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return text.substring(0, 2).toUpperCase();
  }

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.admin => BrandPalette.logoOrange,
      UserRole.customer => BrandPalette.electricBlue,
    };
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = role == UserRole.admin
        ? BrandPalette.logoOrange
        : BrandPalette.electricBlue;
    final label = role == UserRole.admin ? 'Админ' : 'Хэрэглэгч';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _RoleDropdown extends StatelessWidget {
  const _RoleDropdown({required this.currentRole, this.onChanged});

  final UserRole currentRole;
  final void Function(UserRole)? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: BrandPalette.softBlueBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E9F2)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<UserRole>(
          value: currentRole,
          isExpanded: true,
          icon: const Icon(Icons.expand_more_rounded, size: 20),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: BrandPalette.primaryText,
            fontWeight: FontWeight.w600,
          ),
          items: UserRole.values.map((role) {
            return DropdownMenuItem(
              value: role,
              child: Text(role == UserRole.admin ? 'Админ' : 'Хэрэглэгч'),
            );
          }).toList(),
          onChanged: onChanged == null
              ? null
              : (role) {
                  if (role != null && role != currentRole) {
                    onChanged!(role);
                  }
                },
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
