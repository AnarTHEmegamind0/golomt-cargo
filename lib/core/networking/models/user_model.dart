/// User model from API
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerified = false,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.role,
    this.banned = false,
    this.banReason,
    this.banExpires,
  });

  final String id;
  final String name;
  final String email;
  final bool emailVerified;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? role;
  final bool banned;
  final String? banReason;
  final DateTime? banExpires;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      role: json['role'] as String?,
      banned: json['banned'] as bool? ?? false,
      banReason: json['banReason'] as String?,
      banExpires: json['banExpires'] != null
          ? DateTime.parse(json['banExpires'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'emailVerified': emailVerified,
      if (image != null) 'image': image,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      if (role != null) 'role': role,
      'banned': banned,
      if (banReason != null) 'banReason': banReason,
      if (banExpires != null) 'banExpires': banExpires!.toIso8601String(),
    };
  }
}

/// Session model from API
class SessionModel {
  const SessionModel({
    required this.id,
    required this.token,
    required this.expiresAt,
    required this.userId,
    this.createdAt,
    this.updatedAt,
    this.ipAddress,
    this.userAgent,
  });

  final String id;
  final String token;
  final DateTime expiresAt;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? ipAddress;
  final String? userAgent;

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userId: json['userId'] as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      ipAddress: json['ipAddress'] as String?,
      userAgent: json['userAgent'] as String?,
    );
  }
}

/// Auth response with token and user
class AuthResponse {
  const AuthResponse({this.token, required this.user, this.redirect, this.url});

  final String? token;
  final UserModel user;
  final bool? redirect;
  final String? url;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      redirect: json['redirect'] as bool?,
      url: json['url'] as String?,
    );
  }
}

/// Session response
class SessionResponse {
  const SessionResponse({this.session, this.user});

  final SessionModel? session;
  final UserModel? user;

  bool get isAuthenticated => session != null && user != null;

  factory SessionResponse.fromJson(Map<String, dynamic> json) {
    final sessionRaw = json['session'];
    final userRaw = json['user'];

    return SessionResponse(
      session: sessionRaw is Map<String, dynamic>
          ? SessionModel.fromJson(sessionRaw)
          : null,
      user: userRaw is Map<String, dynamic>
          ? UserModel.fromJson(userRaw)
          : null,
    );
  }
}
