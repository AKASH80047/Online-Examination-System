import 'package:exam_paper/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> getAllUsers();
  Future<void> updateUserRole(String uid, UserRole role);
  // Future<UserEntity> getUserById(String uid); // Future functionality
}
