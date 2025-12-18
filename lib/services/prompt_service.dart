import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/prompt_model.dart';
import 'day_key.dart';

class PromptService {
  final _db = FirebaseFirestore.instance;

  Future<Prompt> getTodayPrompt() async {
    final dayKey = DayKey.fromNow(boundaryHour: 5);
    final ref = _db.collection('prompts').doc(dayKey);
    final snap = await ref.get();

    if (snap.exists) return Prompt.fromDoc(snap);

    // まだ管理側で入れてない時のフォールバック（仮お題）
    final start = DayKey.slotStart(dayKey, boundaryHour: 5);
    final end = DayKey.slotEnd(dayKey, boundaryHour: 5);

    final prompt = Prompt(dayKey: dayKey, text: '今日の余白', startsAt: start, endsAt: end);

    // 後から差し替えできるように一旦作っておく運用もあり
    await ref.set({
      'text': prompt.text,
      'startsAt': Timestamp.fromDate(start),
      'endsAt': Timestamp.fromDate(end),
    });

    return prompt;
  }
}
