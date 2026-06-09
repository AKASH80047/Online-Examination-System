import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/auth_repository.dart';
import 'package:exam_paper/auth_remote_ds.dart';
import 'package:exam_paper/user_model.dart';
// Import UserModel for parseRole

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      return await _mapFirebaseUserToEntity(firebaseUser);
    });
  }

  @override
  Future<void> signInWithEmailAndPassword(
    String email,
    String password, [
    String? deviceId,
  ]) async {
    final credential = await remoteDataSource.signIn(email, password);
    final user = credential.user;

    if (user == null) {
      throw Exception('Sign-in failed: User not found after authentication.');
    }

    final profile = await remoteDataSource.getUserProfile(user.uid);
    final existingDeviceId = profile?['deviceId'];

    if (deviceId != null) {
      if (existingDeviceId != null && existingDeviceId != deviceId) {
        await remoteDataSource.signOut();
        throw Exception('This account is already logged into another device.');
      } else if (existingDeviceId == null || existingDeviceId != deviceId) {
        await remoteDataSource.createUserProfile(user.uid, {
          'deviceId': deviceId,
        });
      }
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? deviceId,
  }) async {
    final credential = await remoteDataSource.signUp(email, password);
    final user = credential.user;

    if (user == null) {
      throw Exception('Sign-up failed: User not found after registration.');
    }
    final uid = user.uid;

    final profileData = {
      'uid': uid,
      'email': email,
      'name': name,
      'role': 'user',
      'deviceId': deviceId,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await remoteDataSource.createUserProfile(uid, profileData);
  }

  @override
  Future<void> signOut() async {
    await remoteDataSource.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordReset(email);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    return await _mapFirebaseUserToEntity(firebaseUser);
  }

  Future<UserEntity> _mapFirebaseUserToEntity(User firebaseUser) async {
    final profile = await remoteDataSource.getUserProfile(firebaseUser.uid);

    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      name: profile?['name'] ?? 'User',
      role: UserModel.parseRole(profile?['role']),
      isEmailVerified: firebaseUser.emailVerified,
      deviceId: profile?['deviceId'],
    );
  }
}
