class RefreshTokenRequest {
  const RefreshTokenRequest(this.refreshToken);

  final String refreshToken;

  Map<String, Object?> toJson() {
    return <String, Object?>{'refreshToken': refreshToken};
  }
}
