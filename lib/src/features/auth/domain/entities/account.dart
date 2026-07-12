class Account {
  const Account({
    required this.id,
    required this.roles,
    required this.status,
    this.username,
    this.activeRole,
    this.fullName,
  });

  final int id;
  final String? username;
  final List<String> roles;
  final String? activeRole;
  final String status;
  final String? fullName;

  bool get requiresRoleSelection => roles.length > 1 && activeRole == null;
}
