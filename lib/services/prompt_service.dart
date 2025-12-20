import '../models/prompt_model.dart';
import 'day_key.dart';

class PromptService {
  Future<Prompt> getTodayPrompt() async {
    // UI確認用の疑似ロード
    await Future.delayed(const Duration(milliseconds: 300));

    final dayKey = DayKey.fromNow(boundaryHour: 5);
    final start = DayKey.slotStart(dayKey, boundaryHour: 5);
    final end = DayKey.slotEnd(dayKey, boundaryHour: 5);

    return Prompt(dayKey: dayKey, text: '小さな幸せ', startsAt: start, endsAt: end);
  }
}
