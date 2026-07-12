class ActiveRoleRequest {
  const ActiveRoleRequest(this.activeRole);

  final String activeRole;

  Map<String, Object?> toJson() {
    return <String, Object?>{'activeRole': activeRole};
  }
}
