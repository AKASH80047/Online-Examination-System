import 'package:exam_paper/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  Future<void> signInWithEmailAndPassword(
    String email,
    String password, [
    String? deviceId,
  ]);
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? deviceId,
  });
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserEntity?> getCurrentUser();
}
