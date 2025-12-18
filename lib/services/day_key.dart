import 'package:intl/intl.dart';

class DayKey {
  /// 05:00を境界に、その日の枠キーを返す (Asia/Tokyo固定運用想定)
  static String fromNow({int boundaryHour = 5}) {
    final now = DateTime.now();
    final boundary = DateTime(now.year, now.month, now.day, boundaryHour);
    final slotDate = now.isBefore(boundary) ? now.subtract(const Duration(days: 1)) : now;
    return DateFormat('yyyy-MM-dd').format(slotDate);
  }

  static DateTime slotStart(String dayKey, {int boundaryHour = 5}) {
    final parts = dayKey.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2], boundaryHour);
  }

  static DateTime slotEnd(String dayKey, {int boundaryHour = 5}) {
    return slotStart(dayKey, boundaryHour: boundaryHour).add(const Duration(days: 1));
  }
}
