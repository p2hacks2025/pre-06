import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;

  //store and updata my profile
  Future<void> updateUserProfile(AppUser user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }

  //get my profile
  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.id, doc.data()!);
    }
    return null;
  }
}
