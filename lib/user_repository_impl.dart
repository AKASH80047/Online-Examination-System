import 'package:exam_paper/user_entity.dart';
import 'package:exam_paper/user_repository.dart';
import 'package:exam_paper/user_remote_ds.dart';
// Import UserRemoteDataSource

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<UserEntity>> getAllUsers() async {
    final userModels = await remoteDataSource.getAllUsers();
    return userModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> updateUserRole(String uid, UserRole role) async {
    await remoteDataSource.updateUserRole(uid, role.name);
  }
}