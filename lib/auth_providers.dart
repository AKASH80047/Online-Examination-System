import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_paper/auth_remote_ds.dart';
import 'package:exam_paper/auth_repository_impl.dart';
import 'package:exam_paper/auth_repository.dart';
import 'package:exam_paper/user_entity.dart';

final authDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource);
});

final authStateProvider = StreamProvider<UserEntity?>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
