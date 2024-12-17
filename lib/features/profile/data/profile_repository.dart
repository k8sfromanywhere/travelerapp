import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore firestore;

  ProfileRepository({required this.firestore});

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final doc = await firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    await firestore.collection('users').doc(userId).update(data);
  }
}
