import '../../domain/entities/leave_request.dart';

class ReviewLeaveRequestPayload {
  const ReviewLeaveRequestPayload({required this.decision, this.reviewNote});

  final LeaveRequestDecision decision;
  final String? reviewNote;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'decision': decision.apiValue,
      'reviewNote': reviewNote,
    };
  }
}
