import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_paper/user_entity.dart'; // Corrected import
import 'package:exam_paper/user_model.dart'; // Corrected import
import 'package:exam_paper/user_remote_ds.dart'; // Corrected import
import 'package:exam_paper/user_repository.dart'; // Corrected import
import 'package:exam_paper/user_repository_impl.dart'; // Corrected import
// Needed for authStateProvider

/// Provider to fetch all users from Firestore (Admin only)
final allUsersProvider = FutureProvider<List<UserEntity>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection('users').get();
  return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSourceImpl();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userRemoteDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider to fetch a specific user profile
final userProfileProvider = FutureProvider.family<UserEntity?, String>((
  ref,
  uid,
) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (!doc.exists) return null;
  return UserModel.fromFirestore(doc);
});
