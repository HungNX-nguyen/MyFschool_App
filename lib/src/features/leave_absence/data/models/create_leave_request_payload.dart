class CreateLeaveRequestPayload {
  const CreateLeaveRequestPayload({
    required this.fromDate,
    required this.toDate,
    required this.reason,
  });

  final DateTime fromDate;
  final DateTime toDate;
  final String reason;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'fromDate': _formatDate(fromDate),
      'toDate': _formatDate(toDate),
      'reason': reason,
    };
  }

  String _formatDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).toIso8601String().substring(0, 10);
  }
}
