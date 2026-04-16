import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SkillService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _skillsRef =>
      _db.collection('users').doc(_uid).collection('skills');

  Future<void> addSkill({
    required String name,
    required String description,
    int currentLevel = 1,
    int maxLevel = 5,
  }) async {
    await _skillsRef.add({
      'name': name,
      'description': description,
      'currentLevel': currentLevel,
      'maxLevel': maxLevel,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getSkills() {
    return _skillsRef.orderBy('createdAt', descending: true).snapshots();
  }

  CollectionReference<Map<String, dynamic>> tasksRef(String skillId) {
    return _skillsRef.doc(skillId).collection('tasks');
  }

  Future<void> addTask({
    required String skillId,
    required String title,
    required String type,
    required String description,
    required int targetLevel,
  }) async {
    await tasksRef(skillId).add({
      'title': title,
      'type': type,
      'description': description,
      'targetLevel': targetLevel,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTasks(String skillId) {
    return tasksRef(skillId).orderBy('createdAt', descending: false).snapshots();
  }

  Future<void> completeTask({
    required String skillId,
    required String taskId,
  }) async {
    await tasksRef(skillId).doc(taskId).update({
      'isCompleted': true,
      'completedAt': FieldValue.serverTimestamp(),
    });

    await checkAndLevelUp(skillId: skillId);
  }

  Future<void> checkAndLevelUp({
    required String skillId,
  }) async {
    final skillRef = _skillsRef.doc(skillId);
    final skillSnap = await skillRef.get();
    final skillData = skillSnap.data();

    if (skillData == null) return;

    final int currentLevel = skillData['currentLevel'] ?? 1;
    final int maxLevel = skillData['maxLevel'] ?? 5;

    if (currentLevel >= maxLevel) return;

    final int nextLevel = currentLevel + 1;

    final tasksSnap = await tasksRef(skillId)
        .where('targetLevel', isEqualTo: nextLevel)
        .get();

    if (tasksSnap.docs.isEmpty) return;

    final bool allCompleted = tasksSnap.docs.every(
      (doc) => (doc.data()['isCompleted'] ?? false) == true,
    );

    if (allCompleted) {
      await skillRef.update({
        'currentLevel': nextLevel,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}