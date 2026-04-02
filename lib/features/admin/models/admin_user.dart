import 'package:core/features/auth/models/user.dart';

/// Extended user model for admin management
class AdminUser {
  const AdminUser({
    required this.id,
    required this.email,
    required this.role,
    this.name,
    this.banned = false,
    this.banReason,
    this.banExpiresAt,
    this.emailVerified = false,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String? name;
  final UserRole role;
  final bool banned;
  final String? banReason;
  final DateTime? banExpiresAt;
  final bool emailVerified;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String?,
      role: UserRoleParsing.fromString(json['role'] as String?),
      banned: json['banned'] as bool? ?? false,
      banReason: json['banReason'] as String?,
      banExpiresAt: json['banExpiresAt'] != null
          ? DateTime.tryParse(json['banExpiresAt'] as String)
          : null,
      emailVerified: json['emailVerified'] as bool? ?? false,
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  AdminUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    bool? banned,
    String? banReason,
    DateTime? banExpiresAt,
    bool? emailVerified,
    String? image,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdminUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      banned: banned ?? this.banned,
      banReason: banReason ?? this.banReason,
      banExpiresAt: banExpiresAt ?? this.banExpiresAt,
      emailVerified: emailVerified ?? this.emailVerified,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
