import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<void> updateUserRole(String uid, String role);
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final FirebaseFirestore _firestore;

  UserRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> updateUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).update({'role': role});
  }
}
