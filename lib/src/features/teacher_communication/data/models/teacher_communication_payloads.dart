import '../../../school_event/domain/entities/school_event.dart';
import '../../domain/entities/teacher_communication.dart';

class SendClassNotificationPayload {
  const SendClassNotificationPayload({
    required this.title,
    required this.content,
    required this.audience,
  });

  final String title;
  final String content;
  final ClassNotificationAudience audience;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'title': title,
      'content': content,
      'recipientType': audience.apiValue,
    };
  }
}

class CreateClassEventPayload {
  const CreateClassEventPayload(this.event);

  final CreateTeacherClassEvent event;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'title': event.title,
      'description': event.description,
      'eventDate': _formatDate(event.eventDate),
      'allDay': event.isAllDay,
      'startTime': _formatTime(event.startTime),
      'endTime': _formatTime(event.endTime),
      'location': event.location,
      'participationType': event.participationType.apiValue,
      'publishNow': event.publishNow,
    };
  }

  String _formatDate(DateTime value) {
    final normalized = DateTime(value.year, value.month, value.day);
    return normalized.toIso8601String().substring(0, 10);
  }

  String? _formatTime(Duration? value) {
    if (value == null) {
      return null;
    }
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }
}
