import '../../domain/entities/timetable_week.dart';
import 'timetable_slot_model.dart';

class TimetableDayModel {
  const TimetableDayModel({
    required this.dayOfWeek,
    required this.date,
    required this.slots,
  });

  final int dayOfWeek;
  final DateTime date;
  final List<TimetableSlotModel> slots;

  factory TimetableDayModel.fromJson(Map<String, dynamic> json) {
    final slotsJson = json['slots'];
    if (slotsJson is! List<dynamic>) {
      throw const FormatException('Timetable slots must be a list');
    }

    return TimetableDayModel(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      date: DateTime.parse(json['date'] as String),
      slots: slotsJson
          .map((item) {
            if (item is! Map<String, dynamic>) {
              throw const FormatException('Timetable slot must be an object');
            }
            return TimetableSlotModel.fromJson(item);
          })
          .toList(growable: false),
    );
  }

  TimetableDay toEntity() {
    return TimetableDay(
      dayOfWeek: dayOfWeek,
      date: date,
      slots: List<TimetableSlot>.unmodifiable(
        slots.map((slot) => slot.toEntity()),
      ),
    );
  }
}
