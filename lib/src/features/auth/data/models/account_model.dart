import '../../domain/entities/account.dart';

class AccountModel {
  const AccountModel({
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

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String?,
      roles: (json['roles'] as List<dynamic>? ?? const <dynamic>[])
          .map((role) => role.toString())
          .toList(growable: false),
      activeRole: json['activeRole'] as String?,
      status: json['status'] as String,
      fullName: json['fullName'] as String?,
    );
  }

  Account toEntity() {
    return Account(
      id: id,
      username: username,
      roles: List<String>.unmodifiable(roles),
      activeRole: activeRole,
      status: status,
      fullName: fullName,
    );
  }
}
