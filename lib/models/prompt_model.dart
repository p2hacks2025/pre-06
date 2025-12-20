import 'package:cloud_firestore/cloud_firestore.dart';

class Prompt {
  final String dayKey;
  final String text;
  final DateTime? startsAt;
  final DateTime? endsAt;

  Prompt({required this.dayKey, required this.text, this.startsAt, this.endsAt});

  factory Prompt.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Prompt(
      dayKey: doc.id,
      text: (data['text'] ?? '') as String,
      startsAt: (data['startsAt'] as Timestamp?)?.toDate(),
      endsAt: (data['endsAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'text': text,
        'startsAt': startsAt,
        'endsAt': endsAt,
      };
}
