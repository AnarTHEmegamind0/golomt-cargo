enum UserRole {
  customer,
  chinaStaff,
  mongoliaStaff,
  admin,
}

extension UserRoleParsing on UserRole {
  static UserRole fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'china_staff':
      case 'chinastaff':
        return UserRole.chinaStaff;
      case 'mongolia_staff':
      case 'mongoliastaff':
        return UserRole.mongoliaStaff;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  String get value {
    switch (this) {
      case UserRole.customer:
        return 'customer';
      case UserRole.chinaStaff:
        return 'china_staff';
      case UserRole.mongoliaStaff:
        return 'mongolia_staff';
      case UserRole.admin:
        return 'admin';
    }
  }

  String get label {
    switch (this) {
      case UserRole.customer:
        return 'Хэрэглэгч';
      case UserRole.chinaStaff:
        return 'Хятад ажилтан';
      case UserRole.mongoliaStaff:
        return 'Монгол ажилтан';
      case UserRole.admin:
        return 'Админ';
    }
  }

  bool get isStaff => this == UserRole.chinaStaff || this == UserRole.mongoliaStaff || this == UserRole.admin;
}

class User {
  const User({
    required this.id,
    required this.email,
    this.name,
    this.role = UserRole.customer,
  });

  final String id;
  final String email;
  final String? name;
  final UserRole role;
}
