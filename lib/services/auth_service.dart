import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> authState() => _auth.authStateChanges();

  Future<User> ensureAnonymousSignIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;

    final cred = await _auth.signInAnonymously();
    final user = cred.user!;
    await _ensureUserDoc(user.uid);
    return user;
  }

  Future<void> _ensureUserDoc(String uid) async {
    final ref = _db.collection('users').doc(uid);
    final snap = await ref.get();
    if (snap.exists) return;

    await ref.set({
      'nickname': 'ななし',
      'iconUrl': null,
      'visibility': 'postOnly',
      'snsLinks': {},
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
