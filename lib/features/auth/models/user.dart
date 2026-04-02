enum UserRole { customer, admin }

extension UserRoleParsing on UserRole {
  static UserRole fromString(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }
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
