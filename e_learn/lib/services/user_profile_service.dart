import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('users').doc(_uid);

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchMyProfile() {
    return _doc.snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getMyProfile() {
    return _doc.get();
  }

  Future<void> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    await _doc.update({
      'displayName': displayName,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}